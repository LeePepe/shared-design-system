# TextField runtime review

This synthetic SwiftUI fixture owns no product integration. It resolves an
explicit theme and brand from required launch inputs and displays configuration
errors without a fallback. UI automation imports XCTest only. Run from the
repository root with the shared portable runner:

```sh
python3 Tests/Fixtures/Support/run.py TextFieldReview \
  --results <new-external-directory>/Results.xcresult \
  --screenshots <new-external-empty-directory>
```

The runner records the exact source SHA, clean state, simulator/runtime and
unaltered exported screenshot attachments. Keep results, logs, PNGs and
generated projects outside git. Full `scripts/verify --all` remains required
at the same committed SHA.

## Moved test integrity

The leaf architecture permits UIKit/AppKit tests only for numeric color
extraction. The former TextField tests hosted SwiftUI and traversed native
controls, or called a hosting snapshot helper. All of those assertions move
to the real SwiftUI app driven through XCTest UI automation:

| Previous package test/helper | Real UI replacement | Preserved or strengthened assertion |
| --- | --- | --- |
| `testNativeEditingWritesTheCallerBindingWithoutRewritingInput` | `testNativeEditingPreservesCallerBindingAndSubmits`, `testNativeSelectionCanReplaceInputWithoutPaddingGestureInterference` | Actual keyboard edits update the caller binding; leading/trailing spaces remain; initial value remains; real native selection can replace all text. No native-control mutation or synthetic editing event. |
| `testDisabledEnvironmentReachesTheNativeInput` | `testDisabledCoordinateTapsCannotFocusOrEdit` | AX reports disabled; center and all four padded edges cannot open the keyboard; coordinate taps cannot steal focus or change disabled input while typing into an enabled editor. |
| `testNativeSubmitReachesTheCaller` | `testNativeEditingPreservesCallerBindingAndSubmits` | Actual Done keyboard action calls the caller's `.onSubmit` exactly once and preserves input. |
| `testScreenshotBoards` wide brand/theme loop | Four `testVisualMatrix*` tests | Actual iOS ocean/graphite light/dark PNGs show populated, prompt, disabled and caller validation states; all native inputs meet 44 pt target dimensions and every captured element fits the viewport. |
| `testScreenshotBoards` narrow accessibility loop | `testLongNarrowAccessibleLabelAndEditorGrowWithoutClipping` | A real 320 pt SwiftUI layout grows at accessibility2; full German AX label, native editor and visible label remain contained and separate; measured editor and label both grow; actual runtime screenshot. The old macOS size-override captures did not establish iOS Dynamic Type or interaction. |
| `withHostedTextField`, native `firstSubview`, `NativeSnapshot.capture` callers | `XCUIApplication`, geometry preferences and `XCTAttachment(screenshot: app.screenshot())` | Native input is exercised through real UI events and AX; geometry comes from pure SwiftUI, not native view traversal. |

`testPaddedEdgesFocusTheRealEditor` additionally taps within 2 pt of each
straight edge of the visible padded surface and types into the real bound
editor. The label and entire component are measured by SwiftUI in screen
coordinates; their production 8 pt gap identifies the visible surface rather
than assuming that AX's editor rectangle covers its padding. Editor selection
gestures remain with the native field; a simultaneous tap activates focus
without installing an exclusive gesture or covering the editor with an overlay.
The minimum-target assertion rounds at 1/1000 pt solely for floating-point AX
conversion noise, retaining the 44 pt intent.

The package retains a public-construction test for generic labels, optional
prompts, unchanged caller input and ordinary SwiftUI input/submit/disabled
modifiers. `NativeTokenColorTests` is unchanged. No test is skipped or expected
to fail; no gate or policy changes are involved.

## Evidence limits

The fixture verifies iOS simulator behavior only. It does not establish
VoiceOver speech/focus order, physical keyboard or macOS interaction,
minimum-OS support, device rendering or a multiline editor. Native single-line
input retains its native horizontal scrolling for long values; visible labels
wrap and the editor grows in height with semantic typography. Color authority,
theme resolution, exact Tokens 0.1.1 and the released bridge are unchanged.
