// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Clients",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "tcaAPI",
            targets: ["tcaAPI"]
        ),
    ],
    dependencies: [
        .package(path: "../DBKit"),
        .package(path: "../Core")
    ],
    targets: [
        .target(
            name: "tcaAPI",
            dependencies: [
                .product(name: "Model", package: "Core"),
                .product(name: "CoreDataKit", package: "DBKit")
            ],
            path: "Sources/tcaAPI"
        ),
    ]
)
