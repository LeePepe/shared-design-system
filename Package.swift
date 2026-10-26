// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Strata",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8)],
    products: [
        .library(name: "DesignTokens", targets: ["DesignTokens"]),
        .library(name: "Strata", targets: ["Strata"])
    ],
    targets: [
        .target(
            name: "DesignTokens",
            path: "Packages/DesignTokens/Sources/DesignTokens"
        ),
        .target(
            name: "Strata",
            dependencies: ["DesignTokens"]
        ),
        .testTarget(
            name: "StrataTests",
            dependencies: ["Strata", "DesignTokens"]
        ),
        .testTarget(
            name: "DesignTokensTests",
            dependencies: ["DesignTokens"],
            path: "Packages/DesignTokens/tests/DesignTokensTests"
        )
    ]
)
