// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Set",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "StudySet",
            targets: ["StudySet"]
        ),
    ],
    dependencies: [
        .package(path: "../CommonUI"),
        .package(path: "../Core"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.9.2")
    ],
    targets: [
        .target(
            name: "CommonSet",
            dependencies: [
                .product(name: "CommonUI", package: "CommonUI")
            ],
            path: "Sources/CommonSet"
        ),
        .target(
            name: "StudySet",
            dependencies: [
                .target(name: "CommonSet"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "CommonUI", package: "CommonUI"),
                .product(name: "Model", package: "Core")
            ],
            path: "Sources/StudySet"
        )
    ]
)
