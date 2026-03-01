// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ParentTime",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "ParentTime", targets: ["ParentTime"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-testing.git", from: "0.12.0"),
    ],
    targets: [
        .target(
            name: "ParentTime",
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),
        .testTarget(
            name: "ParentTimeTests",
            dependencies: [
                "ParentTime",
                .product(name: "Testing", package: "swift-testing"),
            ]
        ),
    ]
)
