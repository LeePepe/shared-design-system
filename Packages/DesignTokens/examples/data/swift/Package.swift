// swift-tools-version: 6.0
import PackageDescription
import Foundation

// Executed by the consolidation harness against the nested package path.
guard let packagePath = ProcessInfo.processInfo.environment["TOKENS_PACKAGE_PATH"],
      packagePath.hasPrefix("/") else {
    fatalError("Supply an absolute TOKENS_PACKAGE_PATH")
}
let package = Package(
    name: "TokenExample",
    platforms: [.macOS(.v12)],
    dependencies: [.package(path: packagePath)],
    targets: [.executableTarget(name: "TokenExample", dependencies: [
        .product(name: "DesignTokens", package: "DesignTokens")
    ])]
)
