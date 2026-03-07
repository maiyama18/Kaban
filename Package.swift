// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Kaban",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(
            name: "Kaban",
            targets: ["Kaban"]
        ),
    ],
    targets: [
        .target(
            name: "Kaban",
            resources: [.process("DesignSystem/Resources")]
        ),
        .testTarget(
            name: "KabanTests",
            dependencies: ["Kaban"]
        ),
    ]
)
