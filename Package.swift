// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ClaudeRadar",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "ClaudeRadar",
            targets: ["ClaudeRadar"]
        ),
    ],
    dependencies: [
        // Add any external dependencies here if needed
    ],
    targets: [
        .executableTarget(
            name: "ClaudeRadar",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "ClaudeRadarTests",
            dependencies: ["ClaudeRadar"],
            path: "Tests"
        ),
    ]
)