// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LoginModule",
    products: [
        .library(
            name: "LoginModule",
            targets: ["LoginModule"]),
    ],
    dependencies: [
//        .package(path: "../LDSiOSKit"),
    ],
    targets: [
        .target(
            name: "LoginModule",
            dependencies: []),
        .testTarget(
            name: "LoginModuleTests",
            dependencies: ["LoginModule"]),
    ]
)
