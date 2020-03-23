//
//  Stock.swift
//  App
//
//  Created by Akshit Zaveri on 23/03/20.
//

import FluentSQLite
import Vapor

final class Stock {

  /// Unique ID of the Stock. Do not
  var id: Int?

  /// User facing name of the stock
  let name: String

  /// The price at which the stock currently trades
  var currentPrice: Float

  /// The price at which the stock previously closed.
  var previousClosingPrice: Float

  init(
    name: String,
    currentPrice: Float,
    previousClosingPrice: Float
  ) {
    self.name = name
    self.currentPrice = currentPrice
    self.previousClosingPrice = previousClosingPrice
  }
}

extension Stock: SQLiteModel { }

extension Stock: Codable { }

/// Allows `Stock` to be used as a dynamic migration.
extension Stock: Migration { }

/// Allows `Stock` to be encoded to and decoded from HTTP messages.
extension Stock: Content { }

/// Allows `Stock` to be used as a dynamic paramer in route definitions.
extension Stock: Parameter { }
