// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Model",
            targets: ["Model"]
        ),
        .library(
            name: "Util",
            targets: ["Util"]
        ),
        .library(
            name: "ErrorKit",
            targets: ["ErrorKit"]
        )
    ],
    targets: [
        .target(
            name: "Model",
            dependencies: [
                .target(name: "Util")
            ],
            path: "Sources/Model"
        ),
        .target(
            name: "Util",
            path: "Sources/Util"
        ),
        .target(
            name: "ErrorKit",
            path: "Sources/ErrorKit"
        )
    ]
)
