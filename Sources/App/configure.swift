import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(
  _ config: inout Config,
  _ env: inout Environment,
  _ services: inout Services
) throws {
  try registerProvider(for: &services)
  try configureRouter(for: &services)
  configureMiddleware(for: &services)
  configureDatabase(
    for: &env,
    services: &services
  )
  configureMigrations(for: &services)
  configureCommandConfig(for: &services)
}

private func registerProvider(for services: inout Services) throws {
  // Register providers first
  try services.register(FluentPostgreSQLProvider())
}

private func configureRouter(for services: inout Services) throws {
  // Register routes to the router
  let router = EngineRouter.default()
  try routes(router)
  services.register(router, as: Router.self)
}

private func configureMiddleware(for services: inout Services) {
  // Register middleware
  var middlewares = MiddlewareConfig() // Create _empty_ middleware config
  middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
  middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
  services.register(middlewares)
}

private func configureDatabase(
  for env: inout Environment,
  services: inout Services
) {
  // Configure a PostgreSQL database
  let postgreSQLConfig: PostgreSQLDatabaseConfig!

  if env == Environment.testing {
    postgreSQLConfig = PostgreSQLDatabaseConfig(
      hostname: "localhost",
      username: "test_user",
      database: "stockserver_test"
    )
  } else {
    if let url = Environment.get("DATABASE_URL") {
      postgreSQLConfig = PostgreSQLDatabaseConfig(url: url)
    } else {
      postgreSQLConfig = PostgreSQLDatabaseConfig(
        hostname: "localhost",
        username: "app_collection",
        database: "app_collection"
      )
    }
  }

  let postgreSQL = PostgreSQLDatabase(config: postgreSQLConfig)

  // Register the configured PostgreSQL database to the database config.
  var databases = DatabasesConfig()
  databases.add(database: postgreSQL, as: .psql)
  services.register(databases)
}

private func configureMigrations(for services: inout Services) {
  // Configure migrations
  var migrations = MigrationConfig()
  migrations.add(model: Stock.self, database: .psql)
  services.register(migrations)
}

private func configureCommandConfig(for services: inout Services) {
  // Configure CommandConfig
  var commandConfig = CommandConfig.default()
  commandConfig.useFluentCommands()
  services.register(commandConfig)
}
