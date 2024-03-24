// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Huri",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Huri",
            targets: ["Huri"]
        ),
        .library(
            name: "HuriView",
            targets: ["Huri", "HuriView"]
        )
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Huri",
            path: "Sources/Huri"
        ),
        .target(
            name: "HuriView",
            path: "Sources/HuriView"
        ),
        .testTarget(
            name: "HuriTests",
            dependencies: ["Huri"]),
    ]
)
