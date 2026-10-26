// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LocalConsumerFixture",
    platforms: [.macOS(.v12)],
    dependencies: [.package(name: "shared-design-system", path: "../../..")],
    targets: [
        .executableTarget(
            name: "LocalConsumer",
            dependencies: [
                .product(name: "DesignTokens", package: "shared-design-system"),
                .product(name: "Strata", package: "shared-design-system")
            ]
        )
    ]
)
