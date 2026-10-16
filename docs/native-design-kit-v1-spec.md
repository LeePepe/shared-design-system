# NativeDesignKit v1 specification

Status: planning input v1

Issue: MY-1569

Planning base: `main@850fc34b36d495572fcc3634f4f4e3b4a5f6606c`

Repository: `LeePepe/shared-design-system` (`1380829390`)

Normative dependency: `shared-design-tokens` `0.1.1` at `234b7d0b058474f1aa3f0edeab1be6084ad7eca5`

## Intent

After this work, iOS 15+ and macOS 12+ consumers can compose a small set of SwiftUI presentation primitives from `NativeDesignKit` while continuing to obtain every color from the pinned `DesignTokens` package. The library supplies an explicit, throwing theme-resolution boundary; callers retain product data, state meaning, navigation, localization, controls, and chart rendering.

This document is a repository-native planning contract. It does not authorize implementation or release, does not initialize Spec Kit, and does not change `shared-design-tokens`.

## Existing behaviour

The released `NativeDesignKit` `0.1.0` surface contains one public resolver:

```swift
public enum NativeTokenColor {
    public static func resolve(_ id: String, theme: Theme) throws -> SwiftUI.Color
}
```

The current implementation and tests establish all of the following behaviour, which v1 preserves:

- the caller supplies `Theme` on every resolution;
- the library performs no system-theme lookup, fallback, defaulting, or cross-call cache;
- unknown IDs propagate the exact `TokenError` returned by `DesignTokens`;
- RGB channels are converted from encoded sRGB bytes by division by 255 and alpha is unchanged;
- both themes and all token IDs resolve, including a light → dark → light sequence with no stale reuse;
- asymmetric RGB and alpha fixtures prevent channel-order or opacity regressions;
- the package uses Swift tools 6.0, iOS 15, macOS 12, and an exact `shared-design-tokens` `0.1.1` dependency.

No shared component, showcase application, business model, chart engine, or component-level theme environment exists today.

## Terminology

| Term | Meaning |
|---|---|
| `Theme` | The caller-selected `DesignTokens.Theme` (`light` or `dark`). It is never inferred from the operating system. |
| resolved theme | An immutable `NativeDesignTheme` value produced for one explicit `Theme`. It contains only semantic render values needed by this library. |
| presentation primitive | A reusable SwiftUI view that lays out and styles caller-owned content without owning product behaviour. |
| semantic token | A named role from `DesignTokens`, not a local RGB value or a product business state. |
| content phase | One of loading, empty, error, or content, selected explicitly by the caller. |
| fixture | Sample-only iOS/macOS validation code with synthetic data; it is not a consumer application or shipped product flow. |

## Public interface contract

The following source-level shapes are normative. Implementation may vary generic type-parameter names and compiler-required internal details only; public type names, cases, initializer labels, required builders, overload availability, and argument types do not vary without a reviewed specification revision.

```swift
public struct NativeDesignTheme {
    public init(theme: Theme) throws
}

public struct NativeCard<Content: View>: View {
    public init(theme: NativeDesignTheme,
                @ViewBuilder content: () -> Content)
}

public struct NativeMetric<Label: View, Value: View, Supporting: View>: View {
    public init(theme: NativeDesignTheme,
                @ViewBuilder label: () -> Label,
                @ViewBuilder value: () -> Value,
                @ViewBuilder supporting: () -> Supporting)
}

public extension NativeMetric where Supporting == EmptyView {
    init(theme: NativeDesignTheme,
         @ViewBuilder label: () -> Label,
         @ViewBuilder value: () -> Value)
}

public enum NativeStatusTone {
    case info
    case warning
    case critical
}

public struct NativeStatusBadge<Label: View>: View {
    public init(theme: NativeDesignTheme,
                tone: NativeStatusTone,
                @ViewBuilder label: () -> Label)
}

public struct NativeChartContainer<Content: View>: View {
    public init(theme: NativeDesignTheme,
                @ViewBuilder content: () -> Content)
}

public enum NativeContentPhase {
    case loading
    case empty
    case error
    case content
}

public struct NativeContentStateView<Loading: View, Empty: View,
                                     Failure: View, Content: View>: View {
    public init(theme: NativeDesignTheme,
                phase: NativeContentPhase,
                @ViewBuilder loading: () -> Loading,
                @ViewBuilder empty: () -> Empty,
                @ViewBuilder error: () -> Failure,
                @ViewBuilder content: () -> Content)
}
```

All textual slots are generic `View` builders. There are no `String`, `Text`, or `LocalizedStringKey` convenience overloads in v1. Callers use `EmptyView` explicitly for any required phase they intentionally render as empty; only Metric has the stated no-supporting-content overload. Chart titles, legends, and controls are composed by the caller inside its single content builder rather than becoming library-owned slots.

| Surface | Contract |
|---|---|
| `NativeDesignTheme` | Opaque immutable render value. `init(theme: Theme) throws` freshly resolves the required semantic tokens and propagates `TokenError` unchanged. There is no default initializer, ambient environment lookup, global storage, or memoization. |
| `NativeCard` | Generic caller-content container with raised-surface and primary-foreground styling. It does not imply tap, selection, navigation, or data behaviour. |
| `NativeMetric` | Presents caller-provided localizable label, value, and optional supporting content using system semantic typography. It owns no formatting, units, or metric model. |
| `NativeStatusTone` | Exactly `info`, `warning`, and `critical` in v1. It is a presentation vocabulary, not a product status enum. |
| `NativeStatusBadge` | Presents a caller-provided localizable label with one explicit `NativeStatusTone`, its paired semantic colors, and a non-color shape cue. |
| `NativeChartContainer` | Generic shell around one caller-owned visualization composition. Any title, legend, and controls are caller content. It owns no data, series mapping, persistence, or chart renderer. |
| `NativeContentPhase` | Exactly `loading`, `empty`, `error`, and `content`; it carries no business error or payload. |
| `NativeContentStateView` | Selects exactly one caller-supplied localizable phase view for the caller-supplied `NativeContentPhase`. Caller actions and retry semantics remain caller-owned. |

All presentation primitives require a `NativeDesignTheme` explicitly. They do not install or read a SwiftUI environment default. Constructing a new resolved theme is the only supported response to a caller theme change.

`NativeDesignTheme` is a short-lived value snapshot, not a lookup cache: each construction invokes `DesignTokens` afresh for every required role, no value is retained across constructions, and no automatic invalidation exists. Holding the already-resolved colors inside the value makes ordinary non-throwing SwiftUI `body` evaluation possible without suppressing token errors. If resolution fails, initialization fails before any component is rendered and the original error reaches the caller unchanged.

Production exposes no custom token-ID input on `NativeDesignTheme`. Tests use an internal resolver-injection initializer visible only through `@testable import NativeDesignKit`; it accepts the same `(id, Theme) throws -> SwiftUI.Color` operation and proves exact error identity and requested-role order. This is a test seam, not public API or a fallback. Fixture invalid-token evidence exercises the existing public `NativeTokenColor.resolve(invalidID, theme:)`, because the public theme initializer intentionally resolves only fixed valid semantic IDs.

`NativeTokenColor.resolve(_:theme:)` remains available and source/behaviour compatible. The new component API does not replace it.

## Token contract

The resolved theme uses only these semantic IDs from `DesignTokens` `0.1.1`, with exact component wiring:

| Component / slot | Token ID |
|---|---|
| `NativeCard` background | `product.surface.raised` |
| `NativeCard` inherited default foreground | `product.text.primary` |
| `NativeMetric` value | `product.text.primary` |
| `NativeMetric` label and supporting content | `product.text.secondary` |
| `NativeStatusBadge.info` background / foreground | `status.info` / `status.on-info` |
| `NativeStatusBadge.warning` background / foreground | `status.warning` / `status.on-warning` |
| `NativeStatusBadge.critical` background / foreground | `status.critical` / `status.on-critical` |
| `NativeChartContainer` background / inherited default foreground | `product.surface.raised` / `product.text.primary` |
| `NativeContentStateView` background / inherited default foreground | `product.surface.canvas` / `product.text.primary` |

`NativeDesignTheme` resolves exactly the ten unique IDs in this table and no unused role. Generic caller content may override inherited foreground styling only by using colors it obtains from the same pinned `DesignTokens` authority.

There is no `success` status pair in the pinned dependency, so v1 exposes no success tone and must not synthesize one. Chart series IDs remain available to callers through `DesignTokens`; `NativeChartContainer` does not assign or reinterpret them.

No implementation may add a local token table, RGB/hex literal, fallback color, platform color default, opacity-derived substitute, or second palette authority. The exact dependency version and resolved commit remain unchanged for v1 implementation unless a separately approved dependency change revises this specification.

## Component behaviour

### Layout and typography

- [Strata v0.2](strata-theme-v0.2.md) records the accepted visual direction and rounded Glass reference. It supplements visual review without changing this specification's API, exact dependency, platform floors, or task authorization. Web calibration values are not an implemented native token contract.
- Components use SwiftUI semantic text styles and platform-native layout primitives so Dynamic Type can scale them.
- Because the token dependency defines colors but not spacing, radius, or typography metrics, v1 uses small internal layout constants and system semantic typography. Those constants are implementation details, not new design tokens or public API.
- The acceptance oracle is semantic hierarchy, readability, lack of clipping/overlap, and native interaction at the declared matrix; v1 has no pixel-match baseline.
- Containers preserve the identity, focus, gestures, and accessibility of controls supplied by the caller. They do not add implicit buttons or focus targets.

### Card

`NativeCard` provides one raised semantic surface around generic content. It may group child accessibility content but must not hide an interactive descendant or invent an activation action. It contains no header, metric, or product-specific composition requirement.

### Metric

`NativeMetric` reads in label → value → supporting-content order. The caller supplies already-localizable SwiftUI content and owns number/date/unit formatting. The value remains readable at accessibility text sizes without forcing one line.

### Status badge

The caller selects a tone explicitly and supplies label content that states the status in words. The component uses the exact paired foreground/background tokens and the following platform-available SF Symbol cue: info → `info.circle.fill`, warning → `exclamationmark.triangle.fill`, critical → `exclamationmark.octagon.fill`. Color alone is never the only distinction. The symbol is decorative to VoiceOver when the supplied label already conveys the state; tests and the fixture prove each symbol on iOS 15/macOS 12.

### Chart container

`NativeChartContainer` styles and lays out one generic visualization composition. Callers place any title, legend, controls, and renderer inside that content builder. It does not depend on Swift Charts because Swift Charts would raise the current iOS 15/macOS 12 platform floor. Caller content can use any compatible renderer and owns axes, data, series colors, selection, legends, empty-data meaning, and interaction.

### Content states

For each explicit phase, `NativeContentStateView` places only the matching caller-supplied branch in the rendered and accessibility hierarchy. After a phase update, no prior-phase branch remains visible or accessible. SwiftUI body/closure evaluation counts and caller child-state identity/reset behaviour remain framework- and caller-owned; v1 makes no lifecycle promise about them. The library does not convert `TokenError` or any product error into a content phase. Loading has no timing or network semantics; retry controls and actions are caller content.

## Accessibility and platform behaviour

The validation fixture and automated tests must demonstrate:

- iOS at 320 pt and 430 pt representative widths in light and dark themes;
- macOS at 480 × 320 and 1000 × 700 representative window sizes in light and dark themes;
- default, `extraExtraExtraLarge`, and an accessibility Dynamic Type size without clipped or overlapping required content;
- intentional VoiceOver labels and reading order, with status meaning available without color;
- caller-injected buttons retain iOS touch behaviour and macOS keyboard focus/activation;
- containers do not steal gestures or focus and remain useful during window resizing;
- loading, empty, error, content, and a `NativeTokenColor.resolve` invalid-ID negative path have reproducible evidence.

Unit tests require no new inspection dependency: internal pure role/symbol/phase-routing models and the internal resolver seam cover mappings and failure; rendered builder selection, hierarchy, focus, gestures, and actions are verified by the fixture UI-test targets.

Screenshots prove the exact rendered build and review coverage; they are not a fabricated visual score. A named independent reviewer must inspect them against the objective matrix above (required content present, readable, non-overlapping, non-clipped, correct theme/phase/size) before `AC-A11Y-01`, `AC-PLATFORM-01`, `AC-FIXTURE-01`, or final handoff can pass. If that review is unavailable, evidence says `visual review: not reviewed` and the affected acceptance criteria remain unverified.

## Fixture contract

The fixture is a separate, sample-only dual-platform application under `Tests/Fixtures/NativeDesignKitShowcase/**`. Its checked-in Xcode project uses a portable relative local-package reference to the repository root and public imports only; `@testable` imports, absolute paths, and home-directory paths are forbidden. It uses synthetic, visibly labelled sample data. Remote pushed-SHA resolution remains the responsibility of the existing external-consumer runner, not the showcase. The fixture must not install, start, or read data from an existing business application.

The current repository has no fixture scheme or screenshot runner. Implementation therefore includes an explicit Owner-reviewed fixture project/scheme and deterministic command before fixture acceptance can pass. Any necessary `scripts/ci/**` or `docs/architecture/**` adjustment is a protected repository-contract change and must be reviewed as such; silently claiming that the existing package-only iOS gate covers the fixture is forbidden.

## Compatibility, versioning, and rollback

- Target release: additive `0.2.0` candidate. Tagging or publishing is outside this planning issue and remains a later release workflow.
- Source compatibility: existing `NativeTokenColor` callers require no change.
- Platform compatibility: Swift 6, iOS 15+, and macOS 12+ remain unchanged.
- Dependency compatibility: `shared-design-tokens` remains exact `0.1.1` / `234b7d0b058474f1aa3f0edeab1be6084ad7eca5`.
- Fixed-version consumption: consumers select an exact `NativeDesignKit` release and follow shipped `ai/` integration documentation.
- Rollback: consumers can return to `0.1.0`; no data or configuration migration is required. Code using new component types must first be removed or conditionally excluded.
- Existing product adoption and replacement of business UI are separate work.

Removed behaviour: **none**. No test, assertion, gate, policy, platform, token, API, or support promise may be removed or weakened by this work without a separately approved specification revision.

## Boundaries and red lines

In scope:

- `NativeDesignKit` source and tests;
- the same-revision shipped `ai/` public contract, registry/schema, examples, compatibility, and migration guidance;
- a sample-only fixture and the minimum reviewed verification wiring needed to run it;
- changelog and exact-SHA verification evidence.

Out of scope:

- edits to `shared-design-tokens`, token data, schema, generator, or palette values;
- UIKit/AppKit production UI, React/Basalt/Web runtimes, or Swift Charts as a package dependency;
- business status models, data access, networking, persistence, analytics, navigation, or product pages;
- automatic system-theme detection, a default theme, fallback colors, or cached token lookup;
- watchOS support changes, consumer application migration, package publication, or release tagging;
- repository settings, credentials, rulesets, bypasses, global agent/runtime configuration, or existing business application launch.

## Acceptance criteria

| ID | Normative acceptance | Required evidence |
|---|---|---|
| `AC-BASE-01` | Preserve all `NativeTokenColor` 0.1.0 API and semantics, Swift/platform floors, and the exact Tokens 0.1.1 pin/commit. | Existing regression tests plus manifest/lock diff inspection and external-consumer test. |
| `AC-BOUNDARY-01` | Remain SwiftUI-only and presentation-only; add no local palette, fallback/default theme, Web runtime, business/data/navigation concern, or consumer migration. | Source/manifest review, dependency inspection, negative contract tests. |
| `AC-THEME-01` | Resolve an explicit caller-selected theme through a throwing `NativeDesignTheme`; no OS inference or cross-construction cache; propagate token errors unchanged and recreate on theme change. | Unit tests for both themes, alternating reconstruction, exact error equality through the internal resolver seam, requested-role order, and no-default public API inspection. |
| `AC-CARD-01` | Render generic caller content on semantic raised/foreground roles without implicit interaction. | Unit/inspection tests and fixture focus/gesture evidence. |
| `AC-METRIC-01` | Render caller-localized label/value/supporting content in stable reading order with scalable system typography. | Unit/accessibility inspection and Dynamic Type fixture evidence. |
| `AC-BADGE-01` | Support only info/warning/critical with exact paired tokens, caller-localized labels, and non-color cues. | Exhaustive tone tests, token-role assertions, VoiceOver and screenshot evidence. |
| `AC-CHART-01` | Provide a generic visualization shell while callers retain renderer, data, series, legend, and interaction ownership. | Generic-content tests, dependency inspection, interactive fixture content. |
| `AC-STATE-01` | Render exactly one caller-provided loading/empty/error/content view for an explicit phase without stale state or product-error mapping. | Exhaustive phase/transition tests and negative/error fixture evidence. |
| `AC-A11Y-01` | Preserve intentional VoiceOver semantics and support declared Dynamic Type sizes without required-content clipping/overlap. | Fixture UI tests plus recorded manual matrix and named independent objective-checklist review. |
| `AC-PLATFORM-01` | Preserve caller controls, iOS touch, macOS focus/activation, and adaptive window/size behaviour. | Dual-platform fixture UI tests, recorded interaction matrix, and named independent review. |
| `AC-FIXTURE-01` | Supply a separate synthetic-data iOS/macOS fixture, exact command, and light/dark exact-SHA screenshots without using a business app. | Portable relative package reference, public-import check, fixture source/schemes, command logs, screenshot manifest, and passing independent review. |
| `AC-CONTRACT-01` | Ship matching `ai/`, registry/schema, examples, SemVer, fixed-version integration, compatibility, upgrade/rollback, and `removed behaviour: none` in the same public-API revisions. | Contract checker/tests and documentation review. |
| `AC-VERIFY-01` | Pass host build/test, iOS simulator build/test, contract positive/negative tests, fixture commands, full gate, and pushed-SHA external consumer checks. Online CI must conclude on that exact PR head, every effectively required check must pass, and checks that ran but are not enforced must be reported separately; skipped/cancelled work is not success. | Exact commands, exit codes, test counts, tested SHA, local/remote/PR SHA equality; exact-head check names, conclusions, URLs/run IDs, and head SHA; read-only effective ruleset/branch-protection evidence naming the actually required contexts and any present-but-unenforced checks. Workflow-file presence or an expected target configuration is not enforcement proof; unavailable server-side evidence is reported as unverified and blocks this AC without changing repository settings. |

Every acceptance ID is mapped to implementation work and verification in `docs/native-design-kit-v1-tasks.md`. Any normative change requires an updated reviewed planning revision before implementation proceeds.
