// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InfomaniakCreateAccount",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "InfomaniakCreateAccount",
            targets: ["InfomaniakCreateAccount"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Infomaniak/ios-core", .upToNextMajor(from: "10.0.0")),
        .package(url: "https://github.com/Infomaniak/ios-core-ui", .upToNextMajor(from: "8.0.0")),
    ],
    targets: [
        .target(
            name: "InfomaniakCreateAccount",
            dependencies: [
                .product(name: "InfomaniakCore", package: "ios-core"),
                .product(name: "InfomaniakCoreUI", package: "ios-core-ui")
            ]
        )
    ]
)
