// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "NativeDesignKit",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "NativeDesignKit", targets: ["NativeDesignKit"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/LeePepe/shared-design-tokens.git",
            revision: "1db868db3be99ce9904304fdf1ec81acaf44605a"
        )
    ],
    targets: [
        .target(
            name: "NativeDesignKit",
            dependencies: [
                .product(name: "DesignTokens", package: "shared-design-tokens")
            ]
        ),
        .testTarget(
            name: "NativeDesignKitTests",
            dependencies: [
                "NativeDesignKit",
                .product(name: "DesignTokens", package: "shared-design-tokens")
            ]
        )
    ]
)
