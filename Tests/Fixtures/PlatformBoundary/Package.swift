// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PlatformBoundaryFixture",
    platforms: [.watchOS(.v8)],
    dependencies: [.package(path: "../../..")],
    targets: [
        .executableTarget(
            name: "DesignTokensWatchConsumer",
            dependencies: [
                .product(name: "DesignTokens", package: "shared-design-system")
            ]
        ),
        .executableTarget(
            name: "NativeDesignKitWatchConsumer",
            dependencies: [
                .product(name: "NativeDesignKit", package: "shared-design-system")
            ]
        )
    ]
)
