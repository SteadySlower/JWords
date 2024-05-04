// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Clients",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "HuriganaClient",
            targets: ["HuriganaClient"]
        ),
        .library(
            name: "KanjiClient",
            targets: ["KanjiClient"]
        ),
        .library(
            name: "KanjiSetClient",
            targets: ["KanjiSetClient"]
        ),
        .library(
            name: "OCRClient",
            targets: ["OCRClient"]
        ),
        .library(
            name: "PasteBoardClient",
            targets: ["PasteBoardClient"]
        ),
        .library(
            name: "ScheduleClient",
            targets: ["ScheduleClient"]
        ),
        .library(
            name: "StudySetClient",
            targets: ["StudySetClient"]
        ),
        .library(
            name: "StudyUnitClient",
            targets: ["StudyUnitClient"]
        ),
        .library(
            name: "UtilClient",
            targets: ["UtilClient"]
        ),
        .library(
            name: "WritingKanjiClient",
            targets: ["WritingKanjiClient"]
        ),
    ],
    dependencies: [
        .package(path: "../DBKit"),
        .package(path: "../Core"),
        .package(path: "../HuriKit"),
        .package(path: "../DeviceKit"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.9.2")
    ],
    targets: [
        .target(
            name: "HuriganaClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "HuriConverter", package: "HuriKit")
            ],
            path: "Sources/HuriganaClient"
        ),
        .target(
            name: "KanjiClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Model", package: "Core"),
                .product(name: "CoreDataKit", package: "DBKit")
            ],
            path: "Sources/KanjiClient"
        ),
        .target(
            name: "KanjiSetClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Model", package: "Core"),
                .product(name: "CoreDataKit", package: "DBKit")
            ],
            path: "Sources/KanjiSetClient"
        ),
        .target(
            name: "OCRClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Model", package: "Core"),
                .product(name: "OCRKit", package: "DeviceKit")
            ],
            path: "Sources/OCRClient"
        ),
        .target(
            name: "PasteBoardClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Model", package: "Core"),
                .product(name: "PasteBoardKit", package: "DeviceKit")
            ],
            path: "Sources/PasteBoardClient"
        ),
        .target(
            name: "ScheduleClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Model", package: "Core"),
                .product(name: "UserDefaultKit", package: "DBKit")
            ],
            path: "Sources/ScheduleClient"
        ),
        .target(
            name: "StudySetClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Model", package: "Core"),
                .product(name: "CoreDataKit", package: "DBKit")
            ],
            path: "Sources/StudySetClient"
        ),
        .target(
            name: "StudyUnitClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Model", package: "Core"),
                .product(name: "CoreDataKit", package: "DBKit")
            ],
            path: "Sources/StudyUnitClient"
        ),
        .target(
            name: "UtilClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Model", package: "Core"),
            ],
            path: "Sources/UtilClient"
        ),
        .target(
            name: "WritingKanjiClient",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Model", package: "Core"),
                .product(name: "CoreDataKit", package: "DBKit")
            ],
            path: "Sources/WritingKanjiClient"
        ),
    ]
)
