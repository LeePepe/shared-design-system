# watchOS boundary

The root package declares watchOS 8 for the data-only `DesignTokens` product.
`Strata` remains iOS 15/macOS 12 SwiftUI-only and is unavailable on watchOS;
its compile guard emits the stable diagnostic before any component can be used.

For watchOS consumers, depend on the repository-local `DesignTokens` product
only and resolve token data without importing `Strata`. No Strata component
implementation, watchOS rendering behavior, or watchOS UI compatibility is
claimed. The boundary is verified by
`python3 Tests/Fixtures/PlatformBoundary/verify.py`.
