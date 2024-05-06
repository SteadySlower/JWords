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
    targets: [
        .target(
            name: "Common",
            path: "Sources/Common"
        ),
        .target(
            name: "StudySet",
            dependencies: [
                .target(name: "Common")
            ],
            path: "Sources/StudySet"
        )
    ]
)
