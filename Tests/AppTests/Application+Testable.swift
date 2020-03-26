//
//  Application+Testable.swift
//  App
//
//  Created by Akshit Zaveri on 23/03/20.
//

@testable import App
import Vapor
import FluentPostgreSQL

extension Application {

  static func testable(envArgs: [String]? = nil) throws -> Application {
    
    var config = Config.default()
    var services = Services.default()
    var env = Environment.testing

    if let args = envArgs { env.arguments = args }

    try App.configure(
      &config,
      &env,
      &services
    )
    let app = try Application(
      config: config,
      environment: env,
      services: services
    )
    try App.boot(app)

    return app
  }

  static func reset() throws {
    let revertEnvironment = ["vapor", "revert", "--all", "-y"]
    let revertionApp = try Application.testable(envArgs: revertEnvironment)
    try revertionApp.asyncRun().wait()
//    try app1.syncShutdownGracefully()

    let migrateEnvironment = ["vapor", "migrate", "-y"]
    let migrationApp = try Application.testable(envArgs: migrateEnvironment)
    try migrationApp.asyncRun().wait()
//    try app2.syncShutdownGracefully()
  }
}

extension Application {

  func sendRequest<Body>(
    to path: String,
    method: HTTPMethod,
    headers: HTTPHeaders = .init(),
    body: Body?
  ) throws -> Response where Body: Content {

    let httpRequest = HTTPRequest(
      method: method,
      url: URL(string: path)!,
      headers: headers)
    let request = Request(
      http: httpRequest,
      using: self
    )

    if let body = body { try request.content.encode(body) }

    let responder = try make(Responder.self)

    return try responder.respond(to: request).wait()
  }
}

struct EmptyBody: Content { }
