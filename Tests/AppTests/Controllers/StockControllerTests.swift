//
//  StockControllerTests.swift
//  AppTests
//
//  Created by Akshit Zaveri on 23/03/20.
//

import XCTest
@testable import App
import Vapor
import FluentSQLite

class StockControllerTests: XCTestCase {

  var app: Application!
  var connection: SQLiteConnection!

  override func setUp() {
    super.setUp()

    app = try! Application.testable()
    connection = try! app.newConnection(to: .sqlite).wait()
  }

  override func tearDown() {
    super.tearDown()
    connection.close()
  }

  func test_WhenNewStockRequest_ThenStockIsAdded() throws {
    let stock = Stock(
      name: "SENSEX",
      currentPrice: 3424.2,
      previousClosingPrice: 23432.2
    )
    let newStockResponse = try app.sendRequest(
      to: "api/stocks",
      method: .POST,
      body: stock
    )
    let createdStock = try newStockResponse.content.decode(Stock.self).wait()

    XCTAssertEqual(createdStock.name, "SENSEX")

    let body: EmptyBody? = nil
    let getStocksResponse = try app.sendRequest(
      to: "api/stocks",
      method: HTTPMethod.GET,
      body: body
    )
    let retrievedStocks = try getStocksResponse.content.decode([Stock].self).wait()

    // then
    XCTAssertEqual(retrievedStocks.count, 1)
    XCTAssertEqual(retrievedStocks.first?.name, "SENSEX")
  }
}
