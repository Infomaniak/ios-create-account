// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InfomaniakCreateAccount",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "InfomaniakCreateAccount",
            targets: ["InfomaniakCreateAccount"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Infomaniak/ios-core", .upToNextMajor(from: "19.0.0")),
        .package(url: "https://github.com/Infomaniak/ios-core-ui", .upToNextMajor(from: "26.0.0"))
    ],
    targets: [
        .target(
            name: "InfomaniakCreateAccount",
            dependencies: [
                .product(name: "InfomaniakCore", package: "ios-core"),
                .product(name: "InfomaniakCoreSwiftUI", package: "ios-core-ui")
            ]
        ),
        .testTarget(
            name: "InfomaniakCreateAccountTests",
            dependencies: ["InfomaniakCreateAccount"]
        ),
    ]
)
