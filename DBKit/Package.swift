// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DBKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "CoreDataKit",
            targets: ["CoreDataKit"]
        ),
        .library(
            name: "UserDefaultKit",
            targets: ["UserDefaultKit"]
        ),
        .library(
            name: "KanjiWiki",
            targets: ["KanjiWiki"]
        ),
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../HuriKit")
    ],
    targets: [
        .target(
            name: "CoreDataKit",
            dependencies: [
                .product(name: "ErrorKit", package: "Core"),
                .product(name: "HuriConverter", package: "HuriKit"),
                .target(name: "KanjiWiki"),
                .product(name: "Model", package: "Core"),
            ],
            path: "Sources/CoreDataKit"
        ),
        .target(
            name: "UserDefaultKit",
            path: "Sources/UserDefaultKit"
        ),
        .target(
            name: "KanjiWiki",
            dependencies: [
                .product(name: "ErrorKit", package: "Core"),
            ],
            path: "Sources/KanjiWiki",
            resources: [.process("Resources")]
        ),
    ]
)
