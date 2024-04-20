// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CommonUI",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "CommonUI",
            targets: ["CommonUI"]
        ),
        .library(
            name: "SideBar",
            targets: ["SideBar"]
        ),
        .library(
            name: "Cells",
            targets: ["Cells"]
        ),
        .library(
            name: "AdView",
            targets: ["AdView"]
        )
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads", .upToNextMajor(from: "11.3.0"))
    ],
    targets: [
        .target(
            name: "CommonUI",
            path: "Sources/CommonUI"
        ),
        .target(
            name: "SideBar",
            path: "Sources/SideBar"
        ),
        .target(
            name: "Cells",
            dependencies: [
                .target(name: "CommonUI"),
                .product(name: "Model", package: "Core")
            ],
            path: "Sources/Cells"
        ),
        .target(
            name: "AdView",
            dependencies: [
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
            ],
            path: "Sources/AdView"
        )
    ]
)
