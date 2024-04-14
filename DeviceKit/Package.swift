// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DeviceKit",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "OCRKit",
            targets: ["OCRKit"]
        ),
        .library(
            name: "PasteBoardKit",
            targets: ["PasteBoardKit"]
        )
    ],
    dependencies: [
        .package(path: "../Core")
    ],
    targets: [
        .target(
            name: "OCRKit",
            dependencies: [
                .product(name: "ErrorKit", package: "Core"),
                .product(name: "Model", package: "Core"),
            ],
            path: "Sources/OCRKit"
        ),
        .target(
            name: "PasteBoardKit",
            dependencies: [
                .product(name: "ErrorKit", package: "Core"),
                .product(name: "Model", package: "Core"),
            ],
            path: "Sources/PasteBoardKit"
        )
    ]
)
