# Chip review fixture

Synthetic SwiftUI-only app and XCTest-only UI automation. This is test evidence,
not product integration. Run from the repository root using the shared portable
runner:

```sh
python3 Tests/Fixtures/Support/run.py ChipReview \
  --results /tmp/ndk-chip-review/Results.xcresult \
  --screenshots /tmp/ndk-chip-review/screenshots
```

Use fresh external output directories. The runner records exact SHA, dirty
state, device, counts and attachment provenance. `screenshots.json` declares
four brand/theme captures plus a 320 pt accessibility2 capture. Inspect every
actual exported PNG. No UIKit/AppKit hosting or native-control traversal is
used. The app's test-only geometry reports actual SwiftUI Text bounds against
the production Chip fill path; a Capsule control proves the regression case.

Coverage: all tones and static/removable/disabled states; native removal
accessibility labels and >=44 pt targets; repeated disabled coordinate taps;
static/label taps dispatch nothing; state remains with the caller; the caller
can remove an item; disabled geometry stays stable; long German labels grow
without clipping and remain on their opaque fill within a narrow viewport.

Test integrity: no prior Chip implementation or tests existed on the initial
base, so no tests are removed, weakened or moved. Chip adds three package tests
and seven real UI tests. Foundation hosting-test migrations belong to the
Button base PR and are recorded in `../ButtonReview/README.md`; this component
does not edit those tests or the unchanged numeric color-extraction tests.

UI evidence is limited to the recorded iOS simulator. Physical devices,
minimum-OS execution, macOS rendering, live keyboard navigation and VoiceOver
have not been observed.
