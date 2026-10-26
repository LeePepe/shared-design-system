# RadioGroup review fixture

Synthetic SwiftUI-only app with XCTest-only UI automation. The canonical
`project.yml` references the local package through `../../..`; the shared
[runner](../Support/README.md) generates an ignored Xcode project. No hosting,
native window/control traversal or UIKit/AppKit helpers are used.

```sh
python3 Tests/Fixtures/Support/run.py RadioGroupReview \
  --results "$RADIO_REVIEW_OUTPUT/Results.xcresult" \
  --screenshots "$RADIO_REVIEW_OUTPUT/screenshots" \
  > "$RADIO_REVIEW_OUTPUT/ui.log" 2>&1
python3 Tests/Fixtures/RadioGroupReview/check_checkmarks.py \
  --screenshots "$RADIO_REVIEW_OUTPUT/screenshots" \
  --ui-log "$RADIO_REVIEW_OUTPUT/ui.log" \
  > "$RADIO_REVIEW_OUTPUT/checkmarks.json"
```

Set `RADIO_REVIEW_OUTPUT` to a new external directory and create it first.
Run full `scripts/verify --all` too. Final evidence requires a clean committed
SHA shared by both runs. `screenshots.json` names the seven actual XCTest PNG
attachments; no generated evidence belongs in git. Inspect every exported PNG
for clipped/overlapping content before handoff.

## Strata checkmark color regression

An actual iOS review caught the native inline Picker drawing a system-blue
checkmark even when its SwiftUI `tint` was the correct token accent. The native
checkmark also needs the accent-color environment. The fixture-owned
`check_checkmarks.py` keeps a mechanical guard for that regression, as required
by pinned shared-ci protocol §7. It reads actual unmodified XCTest PNGs rather
than checking source strings or generating replacement screenshots.

The checker uses Python's standard library only, including PNG chunk CRC
validation, zlib decoding and all five PNG row filters. It accepts noninterlaced
8-bit RGB/RGBA screenshots and rejects unsupported input. Run package resolution
first (full verification does this). Expected colors are resolved recursively
from the exact `shared-design-tokens` checkout's `tokens/colors.json` brand
mapping. The checkout revision must match `Package.resolved` at version 0.1.1,
and the token file must match that revision. No palette is copied into the test.

Each matrix test emits `RADIO_GROUP_CHECKMARK` JSON immediately before capture
with its real XCTest app, selected-option and unselected-option frames. The
checker derives pixels per point from **PNG width / actual app width**, checks
the screenshot height against that same scale, and asserts that these fixture
rows span the full app width. It samples the trailing 20% of each native row,
inset 2 pt vertically and at the trailing edge, away from the short option label.
A connected core of at least 8 square points must equal the resolved opaque
accent exactly; the same region of the unselected row must contain no accent
pixels. Thus a missing or wrong-color selected glyph fails, while antialiased
edge pixels do not need to equal the opaque core. Exit 0 requires all four
ocean/graphite × light/dark checkmarks; a failure exits 1 and reports every case.

The original dev2 captures are retained only as external regression evidence.
They predate per-capture JSON telemetry. To prove that the checker rejects those
actual system-blue glyphs, explicitly use their matching log's initial native
tree (actual window and selected/unselected row coordinates):

```sh
python3 Tests/Fixtures/RadioGroupReview/check_checkmarks.py \
  --legacy-tree \
  --screenshots "$RADIO_DEV2_SCREENSHOTS" \
  --ui-log "$RADIO_DEV2_UI_LOG" \
  > "$RADIO_REVIEW_OUTPUT/dev2-checkmarks.json"
```

That command must exit 1 with four color failures and zero exact accent pixels
in each selected glyph region. The initial tree's full-width option rows occupy
the same positions in the original matrix captures; the checker still obtains
the scale from the actual native window and asserts the full-width invariant.
The historical path is explicit; ordinary runs fail on missing per-capture
geometry. Use the original files unmodified, and keep PNGs, logs and both JSON
reports outside git. Final handoff records their hashes and the tested SHA.

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
| `testStrataBindingSelectionDisabledAndExternalWrites` | Actual native option taps write the exact Hashable tag once; only one option is selected; disabled coordinate taps cannot mutate state; external caller changes update selection. |
| `testTaggedIdentitySurvivesCallerReordering` | Reordering dynamic caller options preserves tagged selection and later taps write stable values, rather than indices. |
| `testExplicitThemeReachesStrataPickerWhileCallerEnvironmentRemainsOpposing` | Caller-supplied label and option views observe the actual inherited SwiftUI color scheme. Both explicit modes reach the Picker subtree under an opposing host; the outer probe keeps the host mode. Real selected tags, disabled coordinate input and target containment remain checked. |
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
`../ButtonReview/README.md`; `StrataTokenColorTests` is unchanged.

Evidence is the current iOS simulator runtime only. No physical device,
minimum-OS, macOS rendered UI, live VoiceOver or keyboard/focus run is implied.
The native iOS adaptation is an inline checkmark list, not radio-circle styling.
