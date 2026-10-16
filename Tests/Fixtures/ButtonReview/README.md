# Button review fixture

An iOS-only SwiftUI app and XCTest UI automation target. This is test-only
synthetic state, not a product screen or additional library product. See the
[shared runner instructions](../Support/README.md) for commands and reuse.
`project.yml` is canonical; XcodeGen generates the shared `ButtonReview` scheme.
The local package path is `../../..`. No dependency pin or platform floor changes.

The UI tests provide all required `NDK_BRAND`, `NDK_THEME`, `NDK_SCENARIO`,
`NDK_TEXT_SIZE` and `NDK_LANGUAGE` launch inputs. Matrix captures show all three
variants in normal/loading/disabled states for ocean/graphite × light/dark.
The 320 pt board uses German localized labels and actual iOS accessibility2
typography. XCTest captures the running app, not a hosted view bitmap.

## Test migration / PR integrity record

Trusted NativeDesignKit context restricts test UIKit/AppKit usage to numeric
color extraction. The following hosting-based checks were moved, not waived.
`NativeTokenColorTests` is unchanged, as are pure action and theme/error tests.

| Previous package check/helper | Replacement UI test | Preserved or stronger coverage |
| --- | --- | --- |
| `testLoadingPreservesMeasuredFootprintAndMinimumHitSize` | `testLoadingPreservesFootprintAndMinimumTarget` | Real app idle/loading frames remain equal within 0.5 pt; both dimensions ≥44 pt and the target is fully onscreen. |
| `testLongLabelsGrowAtAccessibilitySizeWithinNarrowIOSHost` | `testLongLocalizedAccessibilityGrowthWithinNarrowBoard` | Real app German text grows by >20 pt at accessibility2, stays ≤272.5 pt wide inside a 320 pt board, exposes the complete active label, contains the text frame inside the production fill path, stays onscreen and retains loading dimensions within 0.5 pt. |
| `testRealSwiftUIButtonScreenshots` | `testVisualMatrixOceanLight`, `testVisualMatrixOceanDark`, `testVisualMatrixGraphiteLight`, `testVisualMatrixGraphiteDark` | Always capture all four brand/theme boards; assert every variant/state exists, enabled state, ≥44 pt target and full viewport containment before capture. |
| `testNarrowAccessibilitySizeScreenshot` | `testLongLocalizedAccessibilityGrowthWithinNarrowBoard` | `button-accessibility-narrow` is an actual iOS screenshot with measured accessibility text growth and full-label/frame assertions. |
| `NativeSnapshot.capture` / `NSHostingView` / `NSWindow` / `UIHostingController` | `XCTAttachment(screenshot: app.screenshot())` + shared runner export | Runtime iOS screenshots with preserved `.xcresult` attachments and deterministic PNG names; no UIKit/AppKit hosting. |

`testActionDispatchAndDisabledLoadingCoordinateTaps` additionally verifies a
real enabled tap increments the synthetic count, three disabled coordinate
taps and three loading coordinate taps cannot increment it, then a re-enabled
tap works. The pure package dispatch matrix stays in `NativeButtonTests`.
`testInvalidBrandShowsErrorWithoutFallback` checks the fixture's visible error
boundary; it does not change production error propagation.

There are no skips, xfails, relaxed assertions or policy/gate changes in this
migration. macOS package build/tests remain required; no macOS rendered UI
evidence is claimed. VoiceOver, physical devices, minimum OS, live keyboard and
focus behavior need separate observed evidence. Opaque-pair contrast checks do
not establish readability on arbitrary composited material backgrounds.

Matrix target sizes are checked in physical screenshot pixels against the
44 pt minimum (132 px on a 3× display). This avoids floating point accessibility
edge subtraction reporting 43.999969 pt for a rendered 44 pt target. The scale
comes from the screenshot PNG width and the app frame; no UI framework import
or lower target-size threshold is used.

The narrow-board regression also measures the active SwiftUI `Text` and button
bounds through `GeometryReader` preferences in the same coordinate space. The
fixture uses test-only `@testable import NativeDesignKit` to check every text
rectangle corner against the production `NativeButtonShape` fill path, for
both idle and loading labels. This convex shape contains the entire text
rectangle when it contains its corners. A capsule control must reject the idle
text bounds, proving this case exercises the former shape-escape bug rather
than just rectangular containment. The visible result accompanies the actual
accessibility screenshot; no text is clipped or reduced to fit.
