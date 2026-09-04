// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SixDoku",
    platforms: [.iOS(.v17), .watchOS(.v10), .macOS(.v14)],
    products: [
        .library(name: "SharedCore", targets: ["SharedCore"]),
        .library(name: "SharedServices", targets: ["SharedServices"]),
    ],
    targets: [
        .target(name: "SharedCore", path: "SharedCore"),
        .target(name: "SharedServices", dependencies: ["SharedCore"], path: "SharedServices"),
        .executableTarget(name: "SeedGenerator", dependencies: ["SharedCore"], path: "Tools/SeedGenerator"),
        .testTarget(name: "SixDokuTests", dependencies: ["SharedCore", "SharedServices"], path: "SixDokuTests"),
    ]
)
