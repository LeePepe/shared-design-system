# RadioGroup review fixture

Synthetic SwiftUI-only app with XCTest-only UI automation. The canonical
`project.yml` references the local package through `../../..`; the shared
[runner](../Support/README.md) generates an ignored Xcode project. No hosting,
native window/control traversal or UIKit/AppKit helpers are used.

```sh
python3 Tests/Fixtures/Support/run.py RadioGroupReview \
  --results <new-external-directory>/Results.xcresult \
  --screenshots <new-external-empty-directory>
```

Run full `scripts/verify --all` too. Final evidence requires a clean committed
SHA shared by both runs. `screenshots.json` names the seven actual XCTest PNG
attachments; no generated evidence belongs in git. Inspect every exported PNG
for clipped/overlapping content before handoff.

The app requires explicit `NDK_BRAND`, `NDK_THEME`, `NDK_HOST_THEME`, `NDK_SCENARIO`, and
`NDK_TEXT_SIZE` launch values. UI tests set them. Invalid configuration is
visible, with no fallback colors. State, option identity, ordering and display
labels are synthetic caller-owned fixture content.

The component is a direct child of a native `List`, including the 320 pt host.
On iOS, `.inline` requires a native `List`/`Form` row host; the framework falls
back to a wheel in a standalone stack. That diagnostic failure was corrected
by using the documented native host, without replacing any behavioral check.
The narrow native rows must fit the 320 pt viewport; their full native touch
frame may include the list's row margins.

| Test | Meaning |
| --- | --- |
| `testNativeBindingSelectionDisabledAndExternalWrites` | Actual native option taps write the exact Hashable tag once; only one option is selected; disabled coordinate taps cannot mutate state; external caller changes update selection. |
| `testTaggedIdentitySurvivesCallerReordering` | Reordering dynamic caller options preserves tagged selection and later taps write stable values, rather than indices. |
| `testExplicitThemeReachesNativePickerWhileCallerEnvironmentRemainsOpposing` | Caller-supplied label and option views observe the actual inherited SwiftUI color scheme. Both explicit modes reach the Picker subtree under an opposing host; the outer probe keeps the host mode. Real selected tags, disabled coordinate input and target containment remain checked. |
| Four `testVisualMatrix*` methods | Both brands/themes show selected, unselected and disabled inline options with >=44 pt targets, native selected traits and complete viewport containment. |
| `testLongLabelsGrowWithoutClippingAtAccessibilitySizeInNarrowLayout` | A 320 pt board grows rows at accessibility2, retains full accessibility labels, keeps rows disjoint and visible, and remains selectable. |
| `testInvalidBrandShowsOriginalFailureWithoutControl` | The original unknown-brand error is visible and no control replaces it. |

Two pure package tests cover public generic construction with a caller-defined
Hashable type, optional selection and dynamic tagged options. Construction
does not rewrite caller selection. Real behavior is exercised by UI automation,
not by inspecting or traversing SwiftUI/native control internals.

Test integrity: RadioGroup adds fresh tests. No existing assertion is removed,
weakened or moved, so there are no component-specific moved-test mappings.
Inherited Button hosting-to-UI mappings remain owned by the foundation PR in
`../ButtonReview/README.md`; `NativeTokenColorTests` is unchanged.

Evidence is the current iOS simulator runtime only. No physical device,
minimum-OS, macOS rendered UI, live VoiceOver or keyboard/focus run is implied.
The native iOS adaptation is an inline checkmark list, not radio-circle styling.
