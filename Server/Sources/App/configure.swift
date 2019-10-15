import Fluent
import FluentSQLiteDriver
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
    


    s.register(SQLiteConfiguration.self) { c in
//        return .init(hostname: "localhost", port: 5432, username: "ldstreet", password: "", database: "postgres",s tlsConfiguration: .none)
//        return .init(hostname: "localhost", username: "ldstreet", password: "")
        return .init(storage: .connection(.file(path: "./server.sqlite")))
    }

    s.register(Database.self) { c in
        return try c.make(Databases.self).database(.sqlite)!
    }
    
    s.extend(Databases.self) { dbs, c in
//        try dbs.postgres(config: c.make())
        try dbs.sqlite(
            configuration: c.make(),
            threadPool: c.application.threadPool
        )
    }
    
    s.register(Migrations.self) { c in
        var migrations = Migrations()
        migrations.add(CreateCard(), to: .sqlite)
        migrations.add(CreateTodo(), to: .sqlite)
        return migrations
    }
}
