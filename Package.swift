// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "WS",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(name: "WS", targets: ["WS"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-beta.2"),
        .package(url: "https://github.com/vapor/websocket-kit.git", from: "2.0.0-beta.2")
    ],
    targets: [
        .target(name: "WS", dependencies: ["Vapor", "WebSocketKit"]),
        .testTarget(name: "WSTests", dependencies: ["WS", "WebSocketKit"]),
    ]
)
