// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Kaban",
    products: [
        .library(
            name: "Kaban",
            targets: ["Kaban"]
        ),
    ],
    targets: [
        .target(
            name: "Kaban"
        ),
        .testTarget(
            name: "KabanTests",
            dependencies: ["Kaban"]
        ),
    ]
)
