# Switch UI review fixture

This synthetic fixture exercises the public `StrataSwitch` API in a pure
SwiftUI iOS App. It contains no product integration or business data. The App
imports SwiftUI and Strata; UI tests import XCTest only. Theme inputs
are explicit launch-environment values supplied by the UI tests. Production
Switch source, package/platform pins, policy, and color-extraction tests are
unchanged by this test migration.

The [shared native-UI runner](../Support/README.md) generates the ignored Xcode project,
runs this fixture on the serialized iOS simulator, and exports XCTest PNG
attachments with a manifest bound to the tested source SHA. No generated
project, PNG, log or xcresult is committed.

From the repository root, with new external output paths:

```sh
python3 Tests/Fixtures/Support/run.py SwitchReview \
  --results /tmp/ndk-switch-review/Results.xcresult \
  --screenshots /tmp/ndk-switch-review/screenshots
```

`project.yml` follows the shared ButtonReview template and keeps the relative
package reference `../../..`. `screenshots.json` declares all eight expected
XCTest attachment names. The runner records source SHA, tree cleanliness,
simulator and attachment mappings. Shared-host runs acquire the coordinator's
external simulator lock before invoking it.

## Moved-test integrity

The prior candidate was `dc4292240b801966e0a5bd1b115ea1b8e40b5cf9`.
Its entire `Tests/StrataTests/Controls/StrataSwitchTests.swift` used
prohibited AppKit/UIKit hosting, native-control traversal or capture. There
were no pure Switch tests in that file. It is replaced by the following UI
tests; no existing color-extraction or pure-policy test is removed or weakened.

| Prior native-hosting assertion | XCTest UI replacement |
| --- | --- |
| `testStrataActivationWritesBindingAndReflectsCallerUpdates` | `testStrataTapWritesBindingAndCallerUpdateChangesSwitch`: actual switch taps change both native on/off value and caller-visible state, each writes exactly once; a caller button updates the switch without an interaction write. |
| `testDisabledStrataControlDoesNotWriteBinding` | `testDisabledCoordinateTapDoesNotWriteBindingInEitherState`: actual knob-coordinate taps in both disabled initial states preserve native value, caller-visible state and zero binding writes. The test also checks the control is disabled. |
| `testStrataAccessibilityPressRetainsOnOffValue` | `testMeaningfulStrataAccessibilityLabelAndOnOffValue`: XCTest identifies the native switch type and exact caller-supplied label; tapping changes the native on/off value and visible state while preserving the label. |
| `testStrataSwitchCanReceiveKeyboardFocus` | `testStrataSwitchRemainsAnActionableAccessibilityTarget`: the native accessibility switch is hittable before and after real UI activation and remains operable in both directions. The old macOS first-responder check cannot establish iOS external-keyboard focus; macOS focus and live external-keyboard activation remain explicitly unverified. No keyboard event is synthesized through native frameworks. |
| `testNarrowMultilineLabelGrowsAndRetainsStrataSwitch` | `testNarrowLongLabelGrowsAtAccessibilitySizeAndRemainsOperable`: the visible native switch row is at least 44 pt high, fits 280 pt, grows with larger text, preserves its full accessible long label and remains coordinate-tappable without the label obscuring the switch. |
| `testAccessibilityDynamicTypeIncreasesNarrowLabelHeight` | The same UI layout test launches the actual App at standard and accessibility3 sizes, comparing the accessibility row frames with a required height increase greater than 30 pt. |
| `testRealSwiftUISwitchScreenshots` | `testStrataSwitchScreenshotMatrix`: actual iOS XCTest screenshots for ocean/graphite × light/dark, with enabled off/on and disabled off/on rows; each combination also captures a 280 pt long-label layout at accessibility3. |

The App exposes state and write counts as ordinary SwiftUI Text, so assertions
observe caller behavior rather than inspecting internal control objects.
Every captured switch row must be at least 44 × 44 pt and entirely within the
visible app viewport. The minimum-dimension assertion permits only 0.000001 pt
of floating-point measurement noise: XCTest reported one 44 pt AX frame as
43.99999999999994 pt during development. This is far below a display pixel and
does not permit a visibly smaller target.
The last displayed fixture text must also fit the ScrollView's visible frame
before capture. The narrow board retains the complete long label and visible
caller state/write count; its canvas fills the viewport.
`testInvalidConfigurationShowsErrorWithoutFallbackSwitch`
also checks that invalid explicit fixture inputs produce a visible error and
no fallback switch. Theme resolution errors reach the fixture's visible error
boundary without a fallback palette.
Screenshots do not replace behavioral assertions or establish VoiceOver
speech, physical-device or minimum-OS support.
