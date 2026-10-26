# Checkbox review fixture

A synthetic, test-only SwiftUI iOS application. No product integration, business
model or additional package product is introduced. `project.yml` is canonical;
its local dependency is portable (`../../..`). Shared runner instructions are
in [Support/README.md](../Support/README.md).

```sh
python3 Tests/Fixtures/Support/run.py CheckboxReview \
  --results /tmp/ndk-checkbox-review/Results.xcresult \
  --screenshots /tmp/ndk-checkbox-review/screenshots
```

Use fresh external output directories and serialize simulator use as required
by the coordinator. Final evidence must record the clean tested commit SHA.
No PNG, result bundle, generated project or build log is committed.

The fixture requires explicit brand, mode, scenario and text-size launch inputs.
Invalid configuration displays an error and supplies no fallback control.
Its own caller state counts actual binding writes. UI automation imports only
XCTest and captures the running SwiftUI application with `app.screenshot()`.
UIKit/AppKit are not used for behavior, layout, traversal or screenshots.

Nine UI tests cover square-side and label-side taps, caller-driven updates,
selection-stable bounds, disabled coordinate taps in both states, complete
native accessibility label and on/off value, exact >=44 pt targets, and narrow
German text growth at real iOS accessibility2 size. Bounds round only arithmetic
noise to 1/1000 pt before comparison with the unchanged 44 pt minimum.
A component-owned ButtonStyle preserves opaque disabled token colors instead
of the platform plain-style opacity and adds a pressed outline.
Four normal captures show enabled/disabled checked/unchecked states in both
provider brands and themes; four additional 320 pt boards show long checked
labels at accessibility2, with the entire target and fixture ending onscreen.

## Test-integrity mapping

Checkbox is new and has no prior hosting assertions to migrate. No existing
test is removed, weakened or skipped by this component delta.
`StrataTokenColorTests` remains unchanged. Button's prior hosting-to-UI mappings
belong to its foundation PR and remain in ButtonReview's README.

| Requirement | Check |
| --- | --- |
| Exact enabled/disabled token roles, no faded text | Package `testSelectedAndUnselectedUseExactThemeRolesWithoutFadingText` |
| Public generic construction does not own state | Package `testPublicGenericConstructionDoesNotMutateCallerState` |
| Strata binding action, both row edges, caller updates, stable selection bounds | UI `testStrataBindingAndCallerUpdatesPreserveFootprint` |
| Disabled on/off prevent all writes | UI `testDisabledCoordinateTapsCannotChangeEitherCheckedState` |
| Strata Toggle label/value/actionability | UI `testStrataAccessibilityExposesCompleteLabelAndCheckedValue` |
| Narrow long text grows and remains actionable at accessibility size | UI `testNarrowLongLabelGrowsAtAccessibilitySizeAndRemainsOperable` |
| All states, target size, viewport containment, real screenshots | Four UI `testVisualMatrix…` tests and narrow test |
| No fallback on invalid brand | UI `testInvalidBrandDisplaysErrorWithoutFallbackControl` |

The accessibility assertions observe XCTest's native Toggle representation;
they do not claim a manual VoiceOver session. Live hardware-keyboard/focus,
physical devices, minimum iOS 15/macOS 12 and macOS rendered interaction remain
unobserved. macOS package checks do not replace those gaps. Screenshots show
solid controls, not glass. Independent visual review remains with the root.
