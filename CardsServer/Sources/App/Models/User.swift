//import Authentication
//import FluentSQLite
//import Vapor
//import LoginModule
//
///// A registered user, capable of owning todo items.
//extension User: SQLiteModel {}
//
///// Allows users to be verified by basic / password auth middleware.
//extension User: PasswordAuthenticatable {
//    /// See `PasswordAuthenticatable`.
//    public static var usernameKey: WritableKeyPath<User, String> {
//        return \.email
//    }
//    
//    /// See `PasswordAuthenticatable`.
//    public static var passwordKey: WritableKeyPath<User, String> {
//        return \.passwordHash
//    }
//}
//
///// Allows users to be verified by bearer / token auth middleware.
//extension User: TokenAuthenticatable {
//    /// See `TokenAuthenticatable`.
//    public typealias TokenType = UserToken
//}
//
///// Allows `User` to be used as a Fluent migration.
//extension User: Migration {
//    /// See `Migration`.
//    public static func prepare(on conn: SQLiteConnection) -> Future<Void> {
//        return SQLiteDatabase.create(User.self, on: conn) { builder in
//            builder.field(for: \.id, isIdentifier: true)
//            builder.field(for: \.name)
//            builder.field(for: \.email)
//            builder.field(for: \.passwordHash)
//            builder.unique(on: \.email)
//        }
//    }
//}
//
///// Allows `User` to be encoded to and decoded from HTTP messages.
//extension User: Content { }
//
///// Allows `User` to be used as a dynamic parameter in route definitions.
//extension User: Parameter { }
