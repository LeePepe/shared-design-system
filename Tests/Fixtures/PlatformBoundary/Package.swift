// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PlatformBoundaryFixture",
    platforms: [.watchOS(.v8)],
    dependencies: [.package(name: "shared-design-system", path: "../../..")],
    targets: [
        .executableTarget(
            name: "DesignTokensWatchConsumer",
            dependencies: [
                .product(name: "DesignTokens", package: "shared-design-system")
            ]
        ),
        .executableTarget(
            name: "StrataWatchConsumer",
            dependencies: [
                .product(name: "Strata", package: "shared-design-system")
            ]
        )
    ]
)
