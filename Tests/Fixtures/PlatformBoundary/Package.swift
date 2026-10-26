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
                .product(name: "DesignTokens", package: "strata-catalog-rename")
            ]
        ),
        .executableTarget(
            name: "StrataWatchConsumer",
            dependencies: [
                .product(name: "Strata", package: "strata-catalog-rename")
            ]
        )
    ]
)
