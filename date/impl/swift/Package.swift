// swift-tools-version: 6.0

import PackageDescription

// The swift-testing package dependency is required because the built-in Testing
// framework needs a deployment target newer than macOS 13. On Swift 6.2+ this
// produces deprecation warnings — they are expected and harmless.
let package = Package(
    name: "SayableDate",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "SayableDate", targets: ["SayableDate"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-testing.git", from: "0.12.0"),
    ],
    targets: [
        .target(
            name: "SayableDate",
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),
        .testTarget(
            name: "SayableDateTests",
            dependencies: [
                "SayableDate",
                .product(name: "Testing", package: "swift-testing"),
            ]
        ),
    ]
)
