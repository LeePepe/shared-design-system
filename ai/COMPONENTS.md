# Strata components

The component API in this checkout is **unreleased** from the 0.3.0 color-only
release. Evaluate these components using an explicitly reviewed immutable
revision. `Package.swift` builds the in-repository `Packages/DesignTokens`
target, and the unreleased Strata foundation consumes public exact DesignTokens
0.2.0 at
`87bef8fbab5bf67a748815d7ed04d7ae199f760a`; platform floors remain unchanged.
The provider release does not release the native foundation or components.

The current rebuild replaces the old unmerged component implementations and
old v1 component scope following the Owner's request. Only the
`Foundations` / `Controls` / `Components` / `Patterns` internal source hierarchy
is retained within the single `Strata` layer. The historical v1
specification, plan and tasks are superseded for this rebuild. Component
names are informed by the HeroUI catalogue; implementation is native SwiftUI
and follows [Strata v0.2](https://github.com/LeePepe/shared-design-system/blob/48cea0a3f0920d5ebc7797a7d4d848dd060f0f42/docs/strata-theme-v0.2.md), without copying HeroUI
implementation or introducing its runtime.

## Explicit theme

```swift
import DesignTokens
import Strata

let theme = try StrataTheme(theme: .light, brand: "ocean")
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

`StrataSurfaceStyle` has exactly `.solid` and `.glass`. Components that expose
this choice use one native SwiftUI material layer for suitable outer surfaces.
Reduce Transparency uses the same theme's solid surface. Material selection
never changes brand or light/dark mode. Main actions and reading content retain
opaque semantic colors. No Liquid Glass or minimum-OS visual parity is claimed.

The public `StrataSurfaceModifier` and
`View.strataSurface(theme:style:cornerRadius:role:)` APIs require an explicit
`theme: StrataTheme` on every call.

Component-specific contracts are added under `components/` by their PRs.
`StrataStickySectionHeader`, `StrataTabularRowMetrics`,
`StrataComponentMetrics`, `StrataNumberSlotConfiguration`,
`StrataNumericKeypad`, and `StrataSnackbar` resolve DesignTokens-backed metrics
in throwing initializers; use `try` when constructing them.

## Apple-Native First boundary & retired wrappers

Standard controls use pure Apple Native SwiftUI APIs (`Button`, `TextField`,
`Toggle`, `Picker`, `Slider`, `Menu`, `List`, `ContentUnavailableView`,
`.alert`/`.sheet`, and `.searchable`) paired with `StrataTheme` or a
project-local `<80`-line `AppTheme.swift`. Redundant 1:1 basic wrappers were
retired under the Apple-Native First boundary:

| Retired wrapper | Apple-Native SwiftUI replacement |
| --- | --- |
| `StrataButton` | `Button` + `.buttonStyle` / `theme.interactiveAccent` & `theme.onInteractiveAccent` |
| `StrataTextField` | `TextField` + `.strataInputBaseline` |
| `StrataSwitch` / `StrataCheckbox` | `Toggle` (`.switch` / `.checkbox`) |
| `StrataRadioGroup` / `StrataSegmentedBar` | `Picker` (`.radioGroup` / `.segmented`) |
| `StrataSlider` | `Slider` |
| `StrataMenu` | `Menu` (`StrataComponentMetrics` & alignment guides live in `StrataTabularLayout`) |
| `StrataSearchField` | `.searchable` |
| `StrataAvatar` | `Image` / `AsyncImage` + `.clipShape(Circle())` |
| `StrataCard` | View composition with `.strataSurface(theme:style:cornerRadius:role: .card)` |
| `StrataList` | `List` / `LazyVStack` |
| `StrataStateView` | `ContentUnavailableView` |
| `StrataDialog` / `StrataAlertDialog` | `.sheet` / `.alert` / `.confirmationDialog` + `.strataModalPresented(_:)` |

## Shared geometry and alignment

`StrataComponentMetrics.compactCellRadius` is resolved from
`StyleTokens.radius("radius.small")` and is the shared dense-cell radius
for compact collections and custom keyboards. Controls expose
`.strataControlCenter` and `.strataInputBaseline` alignment guides on their
44pt input/button boxes, so labels and summaries outside those boxes cannot
skew same-row alignment. List icons align with copy using
`HStack(alignment: .firstTextBaseline)`.

| Component | Contract |
| --- | --- |
| ActionCardRow | [StrataActionCardRow](components/action-card-row.md) |
| BentoCard / MetricRow | [StrataBentoCard](components/bento-card.md) / [StrataMetricRow](components/metric-row.md) |
| Chip / FilterBar | [StrataChip](components/chip.md) / [StrataFilterBar](components/filter-bar.md) |
| DockedBar | [StrataDockedBar](components/docked-bar.md) |
| IndexRail | [StrataIndexRail](components/index-rail.md) |
| NumberSlot | [StrataNumberSlot](components/number-slot.md) |
| NumericKeypad | [StrataNumericKeypad](components/numeric-keypad.md) |
| ProgressBar / StatusMetricBadge | [StrataProgressBar](components/progress-bar.md) / [StrataStatusMetricBadge](components/status-metric-badge.md) |
| SectionHeader / StickySectionHeader | [StrataSectionHeader](components/section-header.md) / [StrataStickySectionHeader](components/sticky-section-header.md) |
| Snackbar | [StrataSnackbar](components/snackbar.md) |
| TabularLayout | [StrataTabularLayout](components/tabular-layout.md) |
