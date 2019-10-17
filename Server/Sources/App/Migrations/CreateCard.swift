import Fluent

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
