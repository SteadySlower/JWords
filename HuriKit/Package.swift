// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HuriKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "HuriView",
            targets: ["HuriView"]
        ),
        .library(
            name: "HuriConverter",
            targets: ["HuriConverter"]
        )
    ],
    targets: [
        .target(
            name: "HuriView",
            dependencies: [.target(name: "HuriConverter")],
            path: "Sources/HuriView"
        ),
        .target(
            name: "HuriConverter",
            path: "Sources/HuriConverter"
        )
    ]
)
