# NativeDesignKit compatibility

T021-A remains a source-authoring working candidate with scoped local verification, not a released package or the complete versioned-library AI contract. [USAGE.md](USAGE.md) describes its current interface and conversion semantics.

## Fixed dependency

The manifest consumes the public repository `https://github.com/LeePepe/shared-design-tokens.git` at exactly release `0.1.0` (tag `v0.1.0`, `exact: "0.1.0"`). Its SPM identity is `shared-design-tokens`; its exported product and module are `DesignTokens`. The dependency's package display name `DesignSystem` is not the product name. Both the library and test target declare the `DesignTokens` product dependency.

This replaces the earlier candidate revision pin `1db868d`; 0.1.0 carries the same runtime API and color data. No dependency contents are vendored by this slice. Upgrades follow the Tokens `ai/MIGRATION.md` of the target version.

## Declared versus tested

| Surface | Source declaration | Verification for this slice |
| --- | --- | --- |
| Package | `NativeDesignKit` library product and module; Swift tools 6.0 | Evaluated and compiled in the scoped run below; Swift 6.0 itself **NOT TESTED** |
| iOS | iOS 15 minimum; SwiftUI bridge with UIKit test extraction | Simulator build and tests run in CI (`ios` gate, newest available iPhone simulator); device and minimum-OS verification **NOT RUN** |
| macOS | macOS 12 minimum; SwiftUI bridge with AppKit test extraction | AppKit path exercised in the scoped run below; macOS 12 **NOT TESTED** |
| Tokens | Exact release `0.1.0`; top-level `Theme` and public RGBA facade | Resolved from the public tag by CI on every PR (`scripts/verify --all`) |
| External consumer | Public resolver signature in source | Ordinary consumer import/link/use **NOT RUN**; `@testable` tests are not consumer-access proof |

Only iOS and macOS are declared here. The dependency's own platform declarations or historical test results do not establish NativeDesignKit coverage. No watchOS, other-platform, accessibility, visual, performance, or G1 pass is claimed.

## Scoped local verification

Independent verification recorded on 2026-09-24 used macOS 27.2 arm64 and Apple Swift 6.4 (`swiftlang-6.4.0.34.1`). The native SwiftPM build **PASS** and four selected XCTest methods **PASS**, with 0 failures, 0 unexpected failures, and no skipped selected cases. The native SwiftPM backend emitted a deprecation warning; full zero-warning G1 is **NOT PASSED**, and backend-policy reconciliation remains open.

The selected methods covered every public ID in both themes, a theme-varying light→dark→light sequence, exact unknown-ID errors in both themes, and synthetic asymmetric RGB with alpha 0, 0.25, and 1 through the production helper. This exercised real AppKit numeric sRGB extraction, not color equality alone. Zero-alpha checks intentionally ignore hidden RGB. Actor isolation for native extraction stays test-side; the public resolver has no added actor requirement.

The prior results apply to the unchanged manifest, source, and tests. This documentation-only reconciliation was not itself executed or tested and remains subject to independent factual review.

## Remaining gates

iOS/UIKit, minimum deployment OS versions, Swift 6.0, ordinary external SPM installation, coverage metrics, and full D1/6DQ remain unverified. Final shared-ci pin/enforcement, final Tokens substitution and revalidation at T057, complete contracts, demos/style approval, disaster-recovery evidence, independent delivery review, PRM readiness, publication, and merges remain incomplete. The scoped result does not establish release acceptance, full-library verification, or completion of the broader T021 task or historical MY-1569 work.
