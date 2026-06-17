// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "OpenSnap",
    platforms: [
        .macOS(.v27)
    ],
    products: [
        .executable(name: "OpenSnap", targets: ["OpenSnap"])
    ],
    targets: [
        .executableTarget(
            name: "OpenSnap",
            path: "OpenSnap",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "OpenSnapTests",
            dependencies: ["OpenSnap"],
            path: "Tests"
        )
    ]
)
