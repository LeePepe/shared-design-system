// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NativeDesignConsumer",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [.library(name: "SamplePalette", targets: ["SamplePalette"])],
    dependencies: [
        .package(url: "https://github.com/LeePepe/shared-design-system.git", exact: "0.1.0") // runner substitutes the requested revision/version
    ],
    targets: [
        .target(name: "SamplePalette", dependencies: [
            .product(name: "NativeDesignKit", package: "shared-design-system"),
            .product(name: "DesignTokens", package: "shared-design-system")
        ]),
        .testTarget(name: "SamplePaletteTests", dependencies: [
            "SamplePalette",
            .product(name: "DesignTokens", package: "shared-design-system")
        ])
    ]
)
