// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "CardsServer",
    platforms: [.macOS(.v10_11)],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.3.1"),
        
        // 🖋🐘 Swift ORM (queries, models, relations, etc) built on PostgreSQL.
        .package(url: "https://github.com/vapor/fluent-postgres-driver", from: "1.0.0"),
        
        // 👤 Authentication and Authorization layer for Fluent.
//        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
        
        .package(url: "https://github.com/weichsel/ZIPFoundation/", .upToNextMajor(from: "0.9.0")),
        
//        .package(url: "https://github.com/vapor/open-crypto", from: "3.3.0"),
        
        .package(path: "../Models"),
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor", "Models", "ZIPFoundation"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

