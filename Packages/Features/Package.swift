// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Features",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "Features",
            targets: ["Features"]),
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../Core")
    ],
    targets: [
        .target(
            name: "Features",
            dependencies: [
                .product(name: "Domain", package: "Domain"),
                .product(name: "Core", package: "Core")
            ]
        ),
        .testTarget(
            name: "FeaturesTests",
            dependencies: ["Features"]),
    ]
)
