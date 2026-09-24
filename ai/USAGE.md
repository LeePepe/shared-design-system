# NativeTokenColor usage

This is the descriptive contract for the T021-A color bridge working candidate, not the complete versioned-library AI contract. Dependency identity, exact Tokens version, scoped verification results, and remaining compatibility limits are recorded in [COMPATIBILITY.md](COMPATIBILITY.md).

## Current interface

The `NativeDesignKit` library exposes `public enum NativeTokenColor` with this static method (signature excerpt, not an executed example):

```swift
public static func resolve(_ id: String, theme: Theme) throws -> SwiftUI.Color
```

`Theme` is the top-level type imported from `DesignTokens`, with `.light` and `.dark` cases. It is not `DesignTokens.Theme`; the module and facade share the name `DesignTokens`. NativeDesignKit defines no replacement theme type, alias, or re-export contract. Consumer code that names Tokens types imports `DesignTokens` and declares a compatible direct dependency on that product.

## Conversion and errors

The resolver delegates lookup to `DesignTokens.color(_:theme:)`. `DesignTokens.ids` remains the authority for available IDs; this bridge contains no token table. The resulting RGBA uses encoded sRGB byte channels: each becomes `Double(channel) / 255` in an explicitly `.sRGB` SwiftUI color. The original `a` becomes opacity without premultiplication, clamping, or linearization.

Theme is required on every call. The returned value represents that explicit theme; it does not detect the environment or automatically track a later theme change. A caller resolves again with the new theme. The bridge has no theme cache or default theme.

Lookup errors propagate unchanged. An unknown ID throws `TokenError.unknownToken(id)` with the exact supplied string; no fallback color or error wrapping is provided. The internal RGBA conversion helper is shared by the resolver and tests, not a public conversion API.

## Scope

This slice provides color lookup and native conversion only. Components, typography, spacing, demos, style decisions, business series bindings, and product integration remain outside this interface. It adds no Web adapter or other-platform support. The Tokens dependency is pinned at exactly `0.1.0`; the manifest reference does not vendor its contents.
