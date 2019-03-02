// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "CardsServer",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        
        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0"),
        
        // 👤 Authentication and Authorization layer for Fluent.
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
        
        .package(url: "https://github.com/weichsel/ZIPFoundation/", .upToNextMajor(from: "0.9.0")),
        
        .package(url: "https://github.com/IBM-Swift/OpenSSL.git", from: "2.2.2"),
        
        .package(path: "../CardsKit"),
        
        .package(path: "../LoginModule"),
    ],
    targets: [
        .target(name: "App", dependencies: ["Authentication", "FluentSQLite", "Vapor", "CardsKit", "LoginModule", "ZIPFoundation", "OpenSSL"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

