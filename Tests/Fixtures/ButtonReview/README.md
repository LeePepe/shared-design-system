# Button review fixture

An iPhone/iPad SwiftUI app with XCTest UI automation and an optional macOS
pointer/keyboard target. This is test-only
synthetic state, not a product screen or additional library product. See the
[shared runner instructions](../Support/README.md) for commands and reuse.
`project.yml` is canonical; XcodeGen generates the shared `ButtonReview` scheme.
The local package path is `../../..`. No dependency pin or platform floor changes.

The UI tests provide all required `NDK_BRAND`, `NDK_THEME`, `NDK_SURFACE`,
`NDK_SCENARIO`, `NDK_TEXT_SIZE` and `NDK_LANGUAGE` launch inputs. The UI tests
change and restore the simulator's actual Reduce Motion and Reduce Transparency
preferences through Settings, and assert SwiftUI observed those preferences.
`specimen` uses the shared `StrataSpecimen` shell and a dense inner stage,
with five real Strata palettes × light/dark × Glass/solid (20 named captures).
The compact normal row shows Primary, Secondary and Ghost, followed by
disabled/loading examples. `matrix` retains the original behavior boards. Matrix captures show all three
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

The XcodeGen app target explicitly includes `../Shared/StrataSpecimen.swift`.
This shared test-only helper belongs to the foundation; ButtonReview supplies
its own controls and stage. No RGB palette or glass recipe is duplicated here.
The exact source/provider revisions, clean-tree receipt and external candidate
mirror configuration belong with each result bundle; a local candidate mirror
does not establish that the provider version is released or that remote gates
passed. Run simulator work through the coordinator's serial lock.

Runtime contrast verification (Python standard library only):

```sh
python3 Tests/Fixtures/ButtonReview/verify-composites.py \
  <results>.run.json <runner-stdout>.log --output <external-report>.json
```

The checker requires a passing run from a clean current head, the exact provider
revision, and measured SwiftUI Text bounds rather than inflated accessibility
rectangles. It matches full glyph pixels to provider text roles, tests three
nearby actual background samples at >=4.5:1 for all20 specimens and the real
Reduce Transparency capture plus one explicit forced-fallback capture, compares
layout across all22, and compares both fallback backgrounds to explicit solid.
Measurements cover this specimen, not arbitrary
consumer backdrops. Held-press evidence can additionally use a serial `simctl io
screenshot` during the UI test's four-second native press; record that capture
separately from XCTest attachments with the same exact source/provider SHAs.

The macOS `ButtonReviewMac` scheme runs real pointer hover for all three variants
and caller Command-S activation, including disabled/loading suppression. The
new pointer check moved from iPhone after XCTest reported “Pointer events are
not supported for this device”; it is retained in `ButtonPointerReviewUITests`
on a platform that supports the input, with no skip or weaker assertion.

```sh
xcodegen generate --no-env --spec Tests/Fixtures/ButtonReview/project.yml
xcodebuild test -project Tests/Fixtures/ButtonReview/ButtonReview.xcodeproj \
  -scheme ButtonReviewMac -destination 'platform=macOS' \
  -derivedDataPath <external-new-directory> -resultBundlePath <external-new>.xcresult \
  CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=-
```

The ad-hoc identity signs only the local test app/runner, with no account or
provisioning profile. This host may still reject native UI automation before
any test method runs. The same pointer/keyboard suite is also available on an
iPad simulator through `ButtonReviewPointer`; iPhone remains the20-specimen
and behavior target.

The pointer test requires a SwiftUI hover callback for each target, in addition
to captured appearance. An accepted XCTest mouse event alone cannot establish
hover behavior. A plain Text sentinel helps distinguish missing runtime pointer
delivery from component behavior. The iPad focus test reads the actual Full
Keyboard Access preference without changing it. That preference must already
be enabled on the supplied iPad runtime, and a disabled preference fails the
test. The original native focus and Space activation assertions still run and
remain required. Report failures with their result bundle; do not substitute
an idle screenshot for observed hover or focus.

```sh
xcodebuild test -project Tests/Fixtures/ButtonReview/ButtonReview.xcodeproj \
  -scheme ButtonReviewPointer -destination 'platform=iOS Simulator,id=<iPad-UUID>' \
  -derivedDataPath <external-new-directory> -resultBundlePath <external-new>.xcresult \
  CODE_SIGNING_ALLOWED=NO
```

Export macOS/iPad attachments using `xcrun xcresulttool export attachments`. A keyboard
navigation screenshot is an observation; claim a visible focus ring only after
inspecting that actual capture. Host automation permissions remain a separate
runtime requirement and cannot be inferred from a package build.

`testStandardControlsDiagnoseNativeInputDelivery` adds an `input-diagnostics`
board alongside the unchanged specimens. A standard bordered SwiftUI Button,
plain Text hover sentinel, TextField and focusable key probe compare actual
callbacks with NativeButton. It records both requested and observed focus,
requires real focused Space activation on both controls, and compares element
and coordinate hover with mouse-click delivery. Successful text entry or a
shortcut alone does not establish focus navigation. The board never changes
system preferences and supplies no synthetic hover/focus override. Preserve
the XCTest synthesized-event attachments and observations when this test fails;
those identify the event source and coordinates without guessing from idle PNGs.

`ButtonFlatControlIsolationUITests/testFlatStandardHoverNativeTabFocusAndSpace`
is a bounded diagnostic positive control launched with
`--button-flat-control-isolation`. Its separate flat `VStack` contains one
ordinary bordered SwiftUI Button and a Text sentinel, without ScrollView,
NativeButton, FocusState, focus setters, TextField or shortcuts. It records
free-movement hover entry/exit counts and monotonic callback timestamps, actual
frames/hittability, label `isFocused` callbacks, separate AX `hasFocus`, native
Tab/Space dispatch timing, action count, AX text attachments and runtime PNGs.
The expected Tab target is recorded only by the test, never assigned as focus.
FKA's pre-existing preference is an external prerequisite, not observed native
focus; the serial experiment receipt must hash/read it before and after without
changing it. The diagnostic sends three hover movements, one Tab and one Space;
each state predicate waits at most two seconds, with a 180-second method limit.
If a native key dispatch takes 20 seconds or more, it records a failure/capture
and stops this experiment rather than repeating known quiescence stalls.
Its failure leaves all original hover/focus/Space assertions required and does
not establish whether the product or runtime is responsible. Run only this
method for the isolation experiment; preserve cumulative prior failures.

## Public-base delivery and deferred native input

Final delivery consumes public exact DesignTokens0.2.0 at
`87bef8fbab5bf67a748815d7ed04d7ae199f760a` with no local mirror. NativeDesignKit
remains unreleased. Historical candidate packets remain scoped to their original
source/provider revisions.

The Owner on2026-10-17 explicitly temporarily deferred native hover, Tab focus
and focused Space acceptance after the flat ordinary-control failure; root cause
is UNKNOWN. Preserve the unchanged strict pointer/focus/Space suite and both07d
and151851e failed results. Do not rerun unchanged input diagnosis or claim it
passes. The normal `ButtonReview` app scheme runs the visual/layout/action and
system-preference contract; the separate pointer scheme remains intact.

One forced-fallback test uses only the foundation's existing internal
`nativeReduceTransparencyOverride` seam through `NDK_FORCE_REDUCED=true` and
asserts the actual system preference remainsfalse. It is separate from the real
system Reduce Transparency test, and no override is applied in normal launches.
The system tests attach original/reduced/restored actual Settings AX values,
restore each exact original value, then relaunch the app and assert/capture that
SwiftUI observes that original preference. No initial value is silently assumed
by restoration. Normal Glass specimens still require actual transparencyfalse.
