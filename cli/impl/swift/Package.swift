// swift-tools-version: 6.0

import PackageDescription

// SPM uses directory names as package identities for local path dependencies.
// All four component libraries live in directories named "swift", which would
// cause identity conflicts. We work around this by using symlinks with unique
// names (created by the wrapper script) pointing to the actual package dirs.
let package = Package(
    name: "SayableCli",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(path: ".deps/SayableAge"),
        .package(path: ".deps/SayableDate"),
        .package(path: ".deps/SayableTime"),
        .package(path: ".deps/SayableDuration"),
    ],
    targets: [
        .executableTarget(
            name: "SayableCli",
            dependencies: [
                .product(name: "SayableAge", package: "SayableAge"),
                .product(name: "SayableDate", package: "SayableDate"),
                .product(name: "SayableTime", package: "SayableTime"),
                .product(name: "SayableDuration", package: "SayableDuration"),
            ]
        ),
    ]
)
