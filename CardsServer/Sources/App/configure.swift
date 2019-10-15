//import Authentication
import FluentPostgresDriver
import Vapor
//import LoginModule

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())
//    try services.register(AuthenticationProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(SessionsMiddleware.self) // Enables sessions.
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a SQLite database
    let psql: PostgreSQLDatabase
    switch try Environment.detect() {
    case .production:
        psql = PostgreSQLDatabase(config: .init(hostname: "database.v2.vapor.cloud", port: 30001, username: "u87171f1305bdd96d7b190265880cfaf", database: "d61289b66d664c44", password: "p6df6b8e092ba52d3c07aa8bef15a197", transport: .standardTLS))
    default:
        psql = PostgreSQLDatabase(config: try .default())
    }
    
    

    // Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.enableLogging(on: .psql)
    databases.add(database: psql, as: .psql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.prepareCache(for: .psql)
//    migrations.add(model: User.self, database: .sqlite)
//    migrations.add(model: UserToken.self, database: .sqlite)
//    migrations.add(model: Todo.self, database: .sqlite)
    services.register(migrations)

}
