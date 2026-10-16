# Unreleased Strata components

The component API in this checkout is **unreleased**. NativeDesignKit 0.1.0
contains only `NativeTokenColor`; it does not contain these components. Evaluate
this work using an explicitly reviewed immutable revision until a component
release is published. The existing exact DesignTokens 0.1.1 pin and platform
floors remain unchanged.

The current rebuild replaces the old unmerged component implementations and
old v1 component scope following the Owner's request. Only the
`Foundations` / `Controls` / `Components` / `Patterns` internal source hierarchy
is retained within the single `NativeDesignKit` layer. The historical v1
specification, plan and tasks are superseded for this
[rebuild](https://github.com/LeePepe/shared-design-system/blob/730e1700e7a5f22d99cb6509ca3381e009be8a61/docs/strata-component-rebuild.md). Component
names are informed by the HeroUI catalogue; implementation is native SwiftUI
and follows [Strata v0.2](https://github.com/LeePepe/shared-design-system/blob/48cea0a3f0920d5ebc7797a7d4d848dd060f0f42/docs/strata-theme-v0.2.md), without copying HeroUI
implementation or introducing its runtime.

## Explicit theme

```swift
import DesignTokens
import NativeDesignKit

let theme = try NativeDesignTheme(theme: .light, brand: "ocean")
```

Both arguments are required. `Theme` comes from `DesignTokens`; this library
does not re-export it. Provider-supported brands are `ocean` and `graphite`.
An unknown brand throws the provider's exact `TokenError.unknownBrand`.
Every construction resolves the required colors afresh and propagates any
provider error unchanged. Reconstruct when the caller changes theme or brand.
There is no default brand, environment theme lookup, fallback palette or cache.

Public immutable properties are `mode: Theme` and SwiftUI colors `canvas`,
`surface`, `foreground`, `secondaryForeground`, `accent`, `onAccent`, `critical`
and `onCritical`. The first four come from `product.surface.canvas`,
`product.surface.raised`, `product.text.primary`, and `product.text.secondary`;
the accent pair uses `DesignTokens.brandColor` and the critical pair uses
`status.critical` / `status.on-critical`. No further brand colors are invented;
the five-color Strata direction remains a provider gap.

`NativeSurfaceStyle` has exactly `.solid` and `.glass`. Components that expose
this choice use one native SwiftUI material layer for suitable outer surfaces.
Reduce Transparency uses the same theme's solid surface. Material selection
never changes brand or light/dark mode. Main actions and reading content retain
opaque semantic colors. No Liquid Glass or minimum-OS visual parity is claimed.

Component-specific contracts are added under `components/` by their PRs.

| Component | Contract |
| --- | --- |
| Button | [NativeButton](components/button.md) |
| Card | Planned separate component PR; unavailable in this candidate |
| TextField | Planned separate component PR; unavailable in this candidate |
| Switch | Planned separate component PR; unavailable in this candidate |
| Checkbox | Planned separate component PR; unavailable in this candidate |
| RadioGroup | Planned separate component PR; unavailable in this candidate |
| Slider | Planned separate component PR; unavailable in this candidate |
| ProgressBar | Planned separate component PR; unavailable in this candidate |
| Avatar | Planned separate component PR; unavailable in this candidate |
| Chip | Planned separate component PR; unavailable in this candidate |
