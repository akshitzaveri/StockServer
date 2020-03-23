//
//  StockController.swift
//  App
//
//  Created by Akshit Zaveri on 23/03/20.
//

import Vapor

final class StockController {

  func get(_ req: Request) throws -> Future<[Stock]> {
    Stock.query(on: req).all()
  }

  func create(req: Request) throws -> Future<Stock> {
    try req.content.decode(Stock.self).flatMap({ $0.save(on: req) })
  }
}

extension StockController: RouteCollection {

  func boot(router: Router) throws {
    
    let route = router.grouped("api", "stocks")

    /// To get all stocks
    route.get(use: get)

    /// Add a new stock
    route.post(use: create)
  }
}
