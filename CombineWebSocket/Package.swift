// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "CombineWebSocket",
    platforms: [
        .iOS(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v6)
    ],
    products: [
        .library(name: "CombineWebSocket", targets: ["CombineWebSocket"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "CombineWebSocket", dependencies: []),
        .testTarget(name: "CombineWebSocketTests", dependencies: ["CombineWebSocket"])
    ]
)
