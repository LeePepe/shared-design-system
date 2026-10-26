// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LocalConsumerFixture",
    platforms: [.macOS(.v12)],
    dependencies: [.package(path: "../../..")],
    targets: [
        .executableTarget(
            name: "LocalConsumer",
            dependencies: [
                .product(name: "DesignTokens", package: "strata-catalog-rename"),
                .product(name: "Strata", package: "strata-catalog-rename")
            ]
        )
    ]
)
