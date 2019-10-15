// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "CardsServer",
    platforms: [.macOS(.v10_11)],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-alpha.3.2"),

        .package(url: "https://github.com/vapor/fluent-postgres-driver", from: "2.0.0-alpha.3"),
        
        .package(url: "https://github.com/weichsel/ZIPFoundation/", .upToNextMajor(from: "0.9.0")),
        
        .package(path: "../Models"),
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgresDriver", "Vapor", "Models", "ZIPFoundation"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

