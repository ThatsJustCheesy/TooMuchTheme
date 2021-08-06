// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TooMuchTheme",
    products: [
        .library(
            name: "TooMuchTheme",
            targets: ["TooMuchTheme"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/kareman/FootlessParser", .upToNextMinor(from: "0.5.2"))
    ],
    targets: [
        .target(
            name: "TooMuchTheme",
            dependencies: ["FootlessParser"]
        ),
        .testTarget(
            name: "TooMuchThemeTests",
            dependencies: ["TooMuchTheme"]
        ),
    ]
)
