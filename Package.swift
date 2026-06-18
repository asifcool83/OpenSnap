// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "OpenSnap",
    platforms: [
        .macOS(.v27)
    ],
    products: [
        .library(name: "OpenSnapCore", targets: ["OpenSnapCore"]),
        .executable(name: "OpenSnap", targets: ["OpenSnap"])
    ],
    targets: [
        .target(
            name: "OpenSnapCore",
            path: "OpenSnapCore"
        ),
        .executableTarget(
            name: "OpenSnap",
            dependencies: ["OpenSnapCore"],
            path: "OpenSnap",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "OpenSnapTests",
            dependencies: ["OpenSnapCore", "OpenSnap"],
            path: "Tests"
        )
    ]
)
