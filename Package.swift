// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "xoodoo-swift",
    products: [
        .library(
            name: "Xoodoo",
            targets: ["Xoodoo"]),
    ],
    targets: [
        .target(
            name: "Xoodoo"),
        .testTarget(
            name: "XoodooTests",
            dependencies: ["Xoodoo"]),
    ]
)
