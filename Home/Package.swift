// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Home",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Home",
            targets: [
                "HomeView",
                "HomeReducer"
            ]
        ),
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../Clients"),
        .package(path: "../CommonUI"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.9.2")
    ],
    targets: [
        .target(
            name: "HomeView",
            dependencies: [
                .target(name: "HomeReducer"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "CommonUI", package: "CommonUI"),
                .product(name: "Cells", package: "CommonUI"),
                .product(name: "AdView", package: "CommonUI")
            ],
            path: "Sources/View"
        ),
        .target(
            name: "HomeReducer",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Model", package: "Core"),
                .product(name: "StudySetClient", package: "Clients"),
                .product(name: "StudyUnitClient", package: "Clients")
            ],
            path: "Sources/Reducer"
        ),
        .testTarget(
            name: "HomeTests",
            dependencies: [
                .target(name: "HomeReducer")
            ]
        ),
    ]
)