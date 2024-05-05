// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StudySet",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "StudySet",
            targets: ["StudySet"]
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
            name: "StudySet",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "CommonUI", package: "CommonUI")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "StudySetTests",
            dependencies: ["StudySet"]
        ),
    ]
)
