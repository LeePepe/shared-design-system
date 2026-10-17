# Unreleased Strata components

The component API in this checkout is **unreleased**. NativeDesignKit 0.1.0
contains only `NativeTokenColor`; it does not contain these components. Evaluate
this work using an explicitly reviewed immutable revision until a component
release is published. The unreleased Strata foundation consumes public exact DesignTokens 0.2.0 at
`87bef8fbab5bf67a748815d7ed04d7ae199f760a`; platform floors remain unchanged.
The provider release does not release the native foundation or components.

The current rebuild replaces the old unmerged component implementations and
old v1 component scope following the Owner's request. Only the
`Foundations` / `Controls` / `Components` / `Patterns` internal source hierarchy
is retained within the single `NativeDesignKit` layer. The historical v1
specification, plan and tasks are superseded for this rebuild. Component
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
does not re-export it. Provider brands include legacy `ocean`/`graphite` and explicit `strata-blue`,
`strata-green`, `strata-pink`, `strata-yellow`, `strata-purple`.
An unknown brand throws the provider's exact `TokenError.unknownBrand`.
Every construction resolves the required colors afresh and propagates any
provider error unchanged. Reconstruct when the caller changes theme or brand.
There is no default brand, environment theme lookup, fallback palette or cache.

Public immutable properties are `mode: Theme` and SwiftUI colors `canvas`,
`surface`, `foreground`, `secondaryForeground`, `accent`, `onAccent`, `critical`
and `onCritical`. The first four come from `product.surface.canvas`,
`product.surface.raised`, `product.text.primary`, and `product.text.secondary`;
the accent pair uses `DesignTokens.brandColor` and the critical pair uses
`status.critical` / `status.on-critical`. For Strata families, the named page/card/text/error roles replace those legacy
roles. Additive brand-state colors and neutral surface roles are documented in
[Usage](USAGE.md#strata-foundation-candidate-unreleased). No local palette is introduced.

`NativeSurfaceStyle` has exactly `.solid` and `.glass`. Components that expose
this choice use one native SwiftUI material layer for suitable outer surfaces.
Reduce Transparency uses the same theme's solid surface. Material selection
never changes brand or light/dark mode. Main actions and reading content retain
opaque semantic colors. No Liquid Glass or minimum-OS visual parity is claimed.

Component-specific contracts are added under `components/` by their PRs.

| Component | Contract |
| --- | --- |
| Button | [NativeButton](components/button.md) |
| Card | [NativeCard](components/card.md) |
| List | [NativeList](components/list.md) |
| TextField | [NativeTextField](components/textfield.md) |
| Switch | [NativeSwitch](components/switch.md) |
| Checkbox | [NativeCheckbox](components/checkbox.md) |
| RadioGroup | [NativeRadioGroup](components/radio-group.md) |
| Slider | [NativeSlider](components/slider.md) |
| ProgressBar | [NativeProgressBar](components/progress-bar.md) |
| Avatar | [NativeAvatar](components/avatar.md) |
| Chip | [NativeChip](components/chip.md) |
