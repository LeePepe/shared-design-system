// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NativeDesignConsumer",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [.library(name: "SamplePalette", targets: ["SamplePalette"])],
    dependencies: [
        .package(url: "https://github.com/LeePepe/shared-design-system.git", revision: "4047860fe20c10342895ffd2b9d4057ec1cbcaae"), // candidate pin replaced by runner
        .package(url: "https://github.com/LeePepe/shared-design-tokens.git", exact: "0.1.0")
    ],
    targets: [
        .target(name: "SamplePalette", dependencies: [
            .product(name: "NativeDesignKit", package: "shared-design-system"),
            .product(name: "DesignTokens", package: "shared-design-tokens")
        ]),
        .testTarget(name: "SamplePaletteTests", dependencies: [
            "SamplePalette",
            .product(name: "DesignTokens", package: "shared-design-tokens")
        ])
    ]
)
