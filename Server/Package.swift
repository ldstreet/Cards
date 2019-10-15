// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "app",
    platforms: [.macOS(.v10_11)],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-alpha.2"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-alpha.2"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0-alpha.3"),
        .package(url: "https://github.com/weichsel/ZIPFoundation/", .upToNextMajor(from: "0.9.0")),
        .package(path: "../Models"),
    ],
    targets: [
        .target(name: "App", dependencies: ["Models", "Fluent", "Vapor", "ZIPFoundation", "FluentSQLiteDriver"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

