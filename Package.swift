// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ios-environmental-conditions",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "EnvironmentalConditions",
            targets: ["EnvironmentalConditions"]
        ),
    ],
    targets: [
        .target(
            name: "EnvironmentalConditions",
            path: "Sources"
        )
    ]
)
