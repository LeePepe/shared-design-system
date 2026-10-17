# NativeDesignKit compatibility

NativeDesignKit 0.1.0 is the first release (Git tag `v0.1.0`). [USAGE.md](USAGE.md) describes its interface and conversion semantics. The [contract entry](README.md) and [external fixture](EXAMPLES.md) travel with the release source revision; tag-time validation results are recorded in the GitHub release notes.

## Fixed dependency

The current unreleased manifest consumes `https://github.com/LeePepe/shared-design-tokens.git` at exact `0.2.0` (public immutable tag `v0.2.0`, revision `87bef8fbab5bf67a748815d7ed04d7ae199f760a` as recorded in `Package.resolved`). NativeDesignKit v0.1.0 retains its historical exact `0.1.1` requirement. Its SPM identity is `shared-design-tokens`; its exported product and module are `DesignTokens`. The dependency's package display name `DesignSystem` is not the product name. Both the library and test target declare the `DesignTokens` product dependency.

The historical 0.1.1 requirement replaced candidate `1db868d` and release `0.1.0` with licensing metadata only. The released 0.2.0 dependency adds styles and explicit Strata palettes while preserving legacy colors and APIs. No dependency contents are vendored. Upgrades follow the resolved Tokens revision's `ai/MIGRATION.md`.

## Declared versus tested

| Surface | Source declaration | Verification for this slice |
| --- | --- | --- |
| Package | `NativeDesignKit` library product and module; Swift tools 6.0 | Evaluated and compiled in the scoped run below; Swift 6.0 itself **NOT TESTED** |
| iOS | iOS 15 minimum; SwiftUI bridge with UIKit test extraction | Simulator build and tests run in CI (`ios` gate, newest available iPhone simulator); device and minimum-OS verification **NOT RUN** |
| macOS | macOS 12 minimum; SwiftUI bridge with AppKit test extraction | AppKit path exercised in the scoped run below; macOS 12 **NOT TESTED** |
| Tokens | Exact public `0.2.0`; top-level `Theme` and public RGBA facade | Fresh isolated SwiftPM resolution confirms the public tag and committed revision; native build/test and external-consumer results must name their own native SHA |
| External consumer | Separate Swift package using public products only | [Fixture and runner](EXAMPLES.md); matching revision/version results belong in the PR/release notes, not inferred from `@testable` tests |

Only iOS and macOS are declared here. The dependency's own platform declarations or historical test results do not establish NativeDesignKit coverage. No watchOS, other-platform, accessibility, visual, performance, or G1 pass is claimed.

## Scoped local verification

Independent verification recorded on 2026-09-24 used macOS 27.2 arm64 and Apple Swift 6.4 (`swiftlang-6.4.0.34.1`). The native SwiftPM build **PASS** and four selected XCTest methods **PASS**, with 0 failures, 0 unexpected failures, and no skipped selected cases. The native SwiftPM backend emitted a deprecation warning; full zero-warning G1 is **NOT PASSED**, and backend-policy reconciliation remains open.

The selected methods covered every public ID in both themes, a theme-varying light→dark→light sequence, exact unknown-ID errors in both themes, and synthetic asymmetric RGB with alpha 0, 0.25, and 1 through the production helper. This exercised real AppKit numeric sRGB extraction, not color equality alone. Zero-alpha checks intentionally ignore hidden RGB. Actor isolation for native extraction stays test-side; the public resolver has no added actor requirement.

The prior results apply only to the revision tested then. Fresh PR checks and external-consumer results must name their own SHA; they do not inherit this historical pass.

## Remaining gates

Historical exact-tag validation for NativeDesignKit `v0.1.0` uses that tag's own fixture and scripts. Current unreleased revision validation uses the separately released provider 0.2.0; results must identify both revisions and do not establish a new NativeDesignKit release. Minimum deployment OS versions and Swift 6.0 still require their own evidence. The package declares iOS 15/macOS 12, but downstream dependencies can impose a higher effective minimum; inspect the resolved Tokens manifest when targeting the minimum OS. No platform change or expanded support is introduced by this release.

Coverage metrics and full D1/6DQ remain unmeasured. The external runner isolates its source/build/DerivedData but does not prove crash/concurrency cleanup or all tool-cache isolation. Dependency/security scans, real UI demos and Owner style approval, consumer-specific migration/rollback and independent delivery review remain separate gates. The Owner has retained the initial bridge (#1), and the repository is MIT licensed.

No deprecation is introduced. There is no previously published NativeDesignKit version to deprecate. A future removal must be documented with a from/to migration and reviewed consumer upgrade; no unsupported compatibility period is promised.

## Unreleased Strata foundation

This checkout adds neutral surface roles and brand-state properties backed by
the public exact DesignTokens 0.2.0 dependency above. Existing source signatures,
legacy brand values, iOS 15/macOS 12 declarations and explicit-theme behavior
remain. Outer material and dense inner reading planes share a single inherited
blur; Solid and Reduce Transparency preserve the same-theme opaque roles.
Fresh verification must identify both native and public provider revisions;
historical preview-mirror results do not establish current-head acceptance.
