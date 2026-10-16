# Changelog

## Unreleased — 0.2.0

- Added C01–C08 explicit-theme native buttons, selection, text/search/editor, picker, slider/stepper, date, progress, badges/tags, avatar/icon-label and animated-number controls, with caller-owned state, style inputs and localized accessibility values.
- Kept the legacy TextEditor native background aligned with its explicit theme inside an oppositely themed app; added forced-legacy native-host rendering coverage on macOS and iOS.
- Added a portable dual-platform Controls showcase project, executable fixture verification, interaction assertions and real native screenshot attachments; golden-baseline and macOS desktop interaction acceptance remain separate.
- Added explicit foundation inputs for scalable typography, control/surface metrics, token-backed surfaces and accessibility-aware Glass, adaptive/equal grids, wrapping flow, keyboard dismissal, motion, transitions, interpolation and cancellable stagger replay.
- Fixed legacy flow measurement to wrap natural-width children and oversized localized labels, retain child identity across resize/reorder and render each interactive child once; corrected double RTL mirroring in flow placement. Added current-runtime forced-legacy rendering tests.
- Documented foundations separately from the existing color bridge/Theme/Card machine registry; retained the original token/error contracts and exact provider pin.

- Added explicit throwing `NativeDesignTheme(theme:)` seam resolving semantic tokens once for explicit theme without caching or defaulting.
- Added generic `NativeCard` container providing raised-surface and primary-foreground styling for caller-owned SwiftUI content.
- Preserved all `NativeTokenColor` 0.1.0 behavior, Swift 6, iOS 15, and macOS 12 platform floors, and exact `shared-design-tokens` 0.1.1 pin.
- Updated AI consumer contract, registry, schema, and external-consumer fixtures to staged unreleased 0.2.0.

## 0.1.0 — first release (Git tag v0.1.0)

- SwiftUI `NativeTokenColor.resolve(_:theme:)` bridge over exact DesignTokens
  0.1.1, with explicit themes, encoded sRGB conversion and unchanged errors.
- Versioned AI-contract entry, integration/migration guidance, machine registry
  and an ordinary external SwiftPM consumer fixture.

NativeDesignKit is MIT licensed, and the initial bridge (#1) is retained.
Git tag `v0.1.0` marks the merge commit of the release pull request.
Exact-tag external consumer validation runs against `v0.1.0`; its results are
recorded in the GitHub release notes, not claimed here. UI demos/style acceptance and unmeasured 6DQ dimensions remain
separate from build/test success.
