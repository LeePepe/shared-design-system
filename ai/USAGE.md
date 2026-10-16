# NativeDesignKit usage

This is the public API contract for the NativeDesignKit 0.2.0 unreleased candidate. Start with [README.md](README.md) for integration, executable examples and migration routes. Dependency identity, exact Tokens version and remaining compatibility limits are recorded in [COMPATIBILITY.md](COMPATIBILITY.md).

## Public interface

The `NativeDesignKit` library exposes these public types:

```swift
public enum NativeTokenColor {
    public static func resolve(_ id: String, theme: Theme) throws -> SwiftUI.Color
}

public struct NativeDesignTheme {
    public init(theme: Theme) throws
}

public struct NativeCard<Content: View>: View {
    public init(theme: NativeDesignTheme,
                @ViewBuilder content: () -> Content)
}
```

`Theme` is the top-level type imported from `DesignTokens`, with `.light` and `.dark` cases. It is not `DesignTokens.Theme`; the module and facade share the name `DesignTokens`. NativeDesignKit defines no replacement theme type, alias, or re-export contract. Consumer code that names Tokens types imports `DesignTokens` and declares a compatible direct dependency on that product.

## Theme resolution and errors

`NativeDesignTheme.init(theme:) throws` establishes an explicit, throwing resolution boundary before view rendering. It freshly resolves all ten required semantic tokens from `DesignTokens` for the explicit theme:

1. `product.surface.raised` (used by `NativeCard` background)
2. `product.text.primary` (used by `NativeCard` inherited default foreground)
3. `product.text.secondary`
4. `status.info`
5. `status.on-info`
6. `status.warning`
7. `status.on-warning`
8. `status.critical`
9. `status.on-critical`
10. `product.surface.canvas`

In S1, `NativeCard` consumes `product.surface.raised` and `product.text.primary`; the remaining eight roles are resolved atomically as part of the theme snapshot for upcoming primitive wiring.

Theme is required on every construction. The resulting `NativeDesignTheme` is an immutable snapshot; it does not detect the system environment or automatically track later theme changes. When the caller switches between light and dark, it constructs a new `NativeDesignTheme` value. The library maintains no global cache, memoization, or default theme.

Lookup errors propagate unchanged. If token resolution fails, `init(theme:)` throws the exact `TokenError` returned by `DesignTokens`. The library provides no fallback color or error wrapping.

## NativeCard container

`NativeCard` provides raised semantic surface styling around caller-owned `@ViewBuilder` content. It inherits primary text foreground styling and applies platform-native padding and continuous corner radius. It preserves caller child controls, focus, and gestures without adding implicit buttons or navigation semantics.

## NativeTokenColor bridge

`NativeTokenColor.resolve(_:theme:)` remains available for direct individual token color lookup, delegating to `DesignTokens.color(_:theme:)` with encoded sRGB byte conversion and unmodified alpha.

## Scope

This library provides SwiftUI presentation primitives and explicit theme resolution. Business models, networking, persistence, and product workflows remain outside this interface. The Tokens dependency is pinned at exactly `0.1.1`.

## Foundation adaptations

The additive [foundation API contract](FOUNDATIONS.md) covers explicit typography/metrics, native surfaces and Liquid Glass, layouts, focus, interpolation, replay/cancellation and accessibility motion policy.
