# NativeTokenColor usage

This is the public API contract for the NativeDesignKit 0.1.0 color-bridge release. Start with [README.md](README.md) for integration, executable examples and migration routes. Dependency identity, exact Tokens version and remaining compatibility limits are recorded in [COMPATIBILITY.md](COMPATIBILITY.md).

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

This slice provides color lookup and native conversion only. Components, typography, spacing, demos, style decisions, business series bindings, and product integration remain outside this interface. It adds no Web adapter or other-platform support. Released NativeDesignKit `0.1.0` pins Tokens at exactly `0.1.1`. The current unreleased checkout pins Tokens at exactly `0.2.0`; see [COMPATIBILITY.md](COMPATIBILITY.md) for its public revision. Neither manifest reference vendors the dependency.

## Strata foundation candidate (unreleased)

`NativeDesignTheme(theme:brand:)` additionally resolves explicit provider brands
`strata-blue`, `strata-green`, `strata-pink`, `strata-yellow`, `strata-purple` from
the public DesignTokens 0.2.0 release at
`87bef8fbab5bf67a748815d7ed04d7ae199f760a`. They do not alias ocean or graphite.
Legacy brands keep their original lookup behavior. This native foundation is
unreleased; the separately published provider does not establish a
NativeDesignKit release.

Additive immutable color properties are `brandSeed`, `brandSeedInk`, `brandText`,
`accentHover`, `accentActive`, `accentSubtle`. `NativeSurfaceRole` has `region`,
`card`, `inset`, `hover`, `selected`; `theme.surface(role)` returns its opaque
provider color. Existing `canvas` is page and `surface` is card for Strata.
The semantic foreground pair and critical/error pair come from Strata roles.
All values resolve afresh; provider errors propagate unchanged.

Internal component material composition distinguishes outer regions and dense
reading planes, shares one native blur through nested surfaces, and removes
material decorations on solid/Reduce Transparency paths. No environment theme,
default brand, fallback palette, native color literals or cache is introduced.

`success`, `successSurface`, and `chartPrimary` expose brand-independent provider
roles `status.strata.success`, `status.strata.success-surface`, and
`product.strata.chart.primary` for caller-owned synthetic composition. These
meanings remain independent of brand; chart color does not imply status.
