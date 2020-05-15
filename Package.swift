// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CombineWebSocket",
    platforms: [
        .iOS(.v13), .tvOS(.v13), .macOS(.v10_15), .watchOS(.v6)
    ],
    products: [
        .library(name: "CombineWebSocket", type: .dynamic, targets: ["CombineWebSocket"])
    ],
    dependencies: [
        .package(url: "https://github.com/CombineCommunity/CombineExt.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "CombineWebSocket", dependencies: ["CombineExt"]),
        .testTarget(name: "CombineWebSocketTests", dependencies: ["CombineWebSocket"])
    ]
)
