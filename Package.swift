// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NativeDesignKit",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8)],
    products: [
        .library(name: "DesignTokens", targets: ["DesignTokens"]),
        .library(name: "NativeDesignKit", targets: ["NativeDesignKit"])
    ],
    targets: [
        .target(
            name: "DesignTokens",
            path: "Packages/DesignTokens/Sources/DesignTokens"
        ),
        .target(
            name: "NativeDesignKit",
            dependencies: ["DesignTokens"]
        ),
        .testTarget(
            name: "NativeDesignKitTests",
            dependencies: ["NativeDesignKit", "DesignTokens"]
        ),
        .testTarget(
            name: "DesignTokensTests",
            dependencies: ["DesignTokens"],
            path: "Packages/DesignTokens/tests/DesignTokensTests"
        )
    ]
)
