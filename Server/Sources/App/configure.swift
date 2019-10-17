import Fluent
import FluentPostgresDriver
import Vapor

/// Called before your application initializes.
func configure(_ s: inout Services) {
    /// Register providers first
    s.provider(FluentProvider())

    /// Register routes
    s.extend(Routes.self) { r, c in
        try routes(r, c)
    }

    /// Register middleware
    s.register(MiddlewareConfiguration.self) { c in
        // Create _empty_ middleware config
        var middlewares = MiddlewareConfiguration()
        
        // Serves files from `Public/` directory
        /// middlewares.use(FileMiddleware.self)
        
        // Catches errors and converts to HTTP response
        try middlewares.use(c.make(ErrorMiddleware.self))
        
        return middlewares
    }
    


    s.register(PostgresConfiguration.self) { c in
        #if DEBUG
        return .init(hostname: "localhost", username: "ldstreet", password: "")
        #else
        return .init(
            hostname: "database.v2.vapor.cloud",
            port: 30001,
            username: "u87171f1305bdd96d7b190265880cfaf",
            password: "p6df6b8e092ba52d3c07aa8bef15a197",
            database: "d61289b66d664c44"
        )
        #endif
//        return .init(storage: .connection(.file(path: "./server.sqlite")))
    }

    s.register(Database.self) { c in
        return try c.make(Databases.self).database(.psql)!
    }
    
    s.extend(Databases.self) { dbs, c in
        try dbs.postgres(config: c.make())
//        try dbs.sqlite(
//            configuration: c.make(),
//            threadPool: c.application.threadPool
//        )
    }
    
    s.register(Migrations.self) { c in
        var migrations = Migrations()
        migrations.add(CreateCard(), to: .psql)
        migrations.add(CreateTodo(), to: .psql)
        return migrations
    }
}
