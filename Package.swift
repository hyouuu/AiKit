// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AiKit",
    platforms: [
        .macOS(.v13),
        .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AiKit",
            targets: ["AiKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.13.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AiKit",
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
            ]
        ),
        .testTarget(
            name: "AiKitTests",
            dependencies: ["AiKit"],
            resources: [
                .copy("Resources/logo.png"),
                .copy("Resources/example.jsonl"),
                .copy("Resources/9000.mp3"),
                .copy("Resources/cena.mp3"),
            ]
        ),
    ]
)
