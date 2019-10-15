import Fluent

struct CreateTodo: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database
            .schema("todos")
            .field("id", .int, .identifier(auto: true))
            .field("title", .string, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("todos").delete()
    }
}

struct CreateCard: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("cards")
            .field("id", .uuid, .identifier(auto: false))
            .field("card", .data, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("cards").delete()
    }
}
