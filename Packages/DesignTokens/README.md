# DesignTokens — color and style data

Version `0.2.0` (immutable Git tag `v0.2.0` after release verification) of `@leepepe/design-tokens` / Swift `DesignTokens`. This version adds platform-neutral style data under [the additive specification](specs/002-style-foundations/spec.md); it supplies no UI components. `tokens/colors.json` is the editable source of truth; JSON Schema and deterministic generation produce JS/TS, scoped CSS, resolved JSON and Swift. Repository policy is owned by the containing repository's root agent contract.

## Start here

- [Version-matched AI task router](ai/README.md), [changelog](CHANGELOG.md)
- [Specification](specs/001-shared-colors/spec.md), [plan](specs/001-shared-colors/plan.md), [tasks](specs/001-shared-colors/tasks.md)
- [Constitution](docs/constitution.md), [provider technical context](docs/architecture/provider-tech-context.md)
- [Basalt baseline and public API audit](docs/upstream.md), [third-party notices](THIRD_PARTY_NOTICES.md)
- [Compatibility / upgrade / rollback / deferred work](docs/compatibility.md)

## Layers and units

| Layer | Purpose | Example |
|---|---|---|
| foundation | Version-pinned Basalt-derived primitives | `foundation.foreground` |
| brand | Explicit brand-specific accent choices | `brand.ocean.accent` |
| status | Generic communicative roles, paired on-colors | `status.warning`, `status.on-warning` |
| product | Independently namespaced reusable semantics | `product.text.primary`, `product.series.cobalt` |

`schemaVersion: "1.0.0"`, `colorSpace: "srgb"`; RGB channels are integers **0…255**, alpha **0…1**. Tokens have explicit light/dark values or same-mode references, stable IDs and provenance. Product `semanticId` equals `id`. References are validated as a DAG. Series cannot transitively depend on brand or status.

Nine declared opaque text/surface or on-color pairs are contrast-gated at >=4.5 in both modes. This is not a claim that all possible token combinations, chart hues or UI components meet accessibility requirements. Include labels/patterns where needed. No business meaning is inferred from hue.

## Web / TypeScript consumer

Install the tarball built from tag `v0.2.0` at an exact version; nothing is published to the npm registry. The runtime package has **zero dependencies**, including no React. Ajv/TypeScript are generator/test dev dependencies only.

```ts
import {color, brandColor, seriesColor, type SeriesID} from '@leepepe/design-tokens';
const foreground = color('product.text.primary', 'dark'); // {r:237,g:237,b:237,a:1}
const accent = brandColor('ocean', 'accent', 'light');
const bindings: Record<string, SeriesID> = { persistentKey: 'product.series.cobalt' };
const series = seriesColor('persistentKey', bindings, 'dark'); // {id, color}
```

Keep the identity -> series-ID binding in consumer-owned persisted data; never assign from sorted/filtered array indices. The example key is not a shared domain model. Both brand switches and rendering order leave series IDs unchanged. Invalid IDs/themes/brand roles or absent bindings throw; there is no default fallback.

```css
/* Import @leepepe/design-tokens/colors.css using your bundler. */
.example { color: var(--lp-product-text-primary); background: var(--lp-product-surface-canvas); }
```

Set `data-lp-theme="light"` or `"dark"` on the intended scope. Unattributed descendants inherit; nested light/dark scopes override normally. An explicit unsupported value (including `system`, empty or misspelled values) invalidates only this package's own variables at that boundary and through unattributed descendants; a valid nested scope restores them. CSS `var()` fallbacks then apply, rather than silently receiving the ancestor theme. Unrelated custom properties are untouched. No automatic `:root`, OS preference or Basalt CSS override is emitted. Basalt remains Web component/theme authority: pin `@nocoo/basalt@2.1.8`, use its actual public providers/styles, resolve `system` explicitly in any future adapter. This package does not pick a chart renderer and does not replace an existing ECharts contract.

Public exports: root ESM + `.d.ts`, `/colors.css`, `/resolved.json`, `/source.json`, `/schema.json`. `dist/colors.ts` is also pregenerated and compile-tested as a readable immutable data artifact, not an extra public export. Upstream audit snapshots are not public exports.

## Swift data consumer

Pin the containing package at a reviewed exact revision:
`.package(url: "https://github.com/LeePepe/shared-design-system.git",
revision: "<40-character SHA>")`, then consume
`.product(name: "DesignTokens", package: "shared-design-system")`. The module and
public API remain `DesignTokens`; only the repository/package identity changes.
See [Swift integration](ai/INTEGRATION.md#swift-revision).

```swift
import DesignTokens
let color = try DesignTokens.color("product.text.primary", theme: .dark)
// Encoded sRGB bytes, not native Color objects:
let red = Double(color.r) / 255.0
let series = try DesignTokens.seriesColor(
    "persistentKey", bindings: ["persistentKey": "product.series.cobalt"], theme: .light
)
let ratio = try color.contrast(with: DesignTokens.color("product.surface.canvas", theme: .dark))
```

`Theme`, `BrandRole`, `RGBA`, `SeriesColor`, `TokenError` and `DesignTokens` are public immutable/Sendable data APIs. `RGBA(red:green:blue:alpha:)` rejects out-of-range/nonfinite inputs; `relativeLuminance` implements WCAG sRGB math; `contrast(with:)` rejects translucent colors instead of guessing a compositing surface. No HSB API or placeholder non-AppKit values exist.

The containing root `Package.swift` publishes both `DesignTokens` and
`Strata`; Strata depends on this local target. DesignTokens is
UI-free and supports iOS 15, macOS 12 and watchOS 8. Strata remains an
iOS/macOS component product and is unavailable on watchOS.

## Reproduce

```sh
npm ci --ignore-scripts --no-audit --no-fund
npm test # requires Chrome/Chromium; includes test:browser
npm run generate:check
npm run test:consumer
npm run test:pack
npm run check:ai
npm run test:contract
swift build
swift test
# The containing repository's required CI verifies its pushed exact revision.
```

Browser tests use Node standard library to launch an isolated, short-lived headless Chrome/Chromium, load the delivered CSS and compare computed sRGB RGBA for every token in both themes, inheritance, nesting and invalid boundaries. A duplicate wrong declaration proves the gate detects winning overrides. Set `CHROME_BIN` to an executable, or use standard Chrome/Chromium commands on PATH / the standard macOS application location (Windows installation paths are also searched, not locally verified). Missing browsers and invalid explicit overrides fail, never skip. `npm run test:browser` runs this suite alone; `test:pack` also checks the CSS exported by the actually installed tarball. No UI framework, server or screenshot test is used.

After intentional source changes: `npm run generate`, then repeat the gates. Generator supports `--check`, `--source <color-file>`, `--styles-source <style-file>`, `--out <directory>`; `--check` never repairs files. Tests regenerate into an empty temporary directory, compare every output byte, and prove missing/drifted/invalid input exits nonzero. npm packing installs into an isolated consumer, type-checks positive and negative APIs and runs actual emitted JS.

CI has read-only permissions and no provider credentials. Its presence does not establish required checks or prove a hosted run. All current execution evidence is from the local host, not iOS/macOS UI validation.

## Style foundations (0.2.0)

`tokens/styles.json` is the editable non-color style authority. Its schema validates finite values, units, complete categories, provenance and semantic shadow-color references. The same deterministic generator writes `dist/styles.js`, `dist/styles.d.ts`, `dist/styles.resolved.json` and `Sources/DesignTokens/GeneratedStyles.swift`. Existing color outputs remain byte-identical.

The additive `/styles` subpath and Swift `StyleTokens` expose throwing category lookups, with no fallback. Read [style usage](ai/USAGE.md#style-foundations-020) for signatures and units. Version 0.2.0 includes these APIs and five Strata color families. Verify immutable tag availability and release-note evidence before consumer adoption. Local exact-commit candidate tests do not establish released remote resolution.
