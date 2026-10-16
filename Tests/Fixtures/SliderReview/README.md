# SliderReview

Synthetic SwiftUI fixture app; native interaction and rendering run through
XCTest UI automation importing only XCTest. No hosting controller/view, native
window, control traversal, product screen or business data is used.

Use the shared [runner](../Support/README.md):

```sh
python3 Tests/Fixtures/Support/run.py SliderReview \
  --results /tmp/slider-review/Results.xcresult \
  --screenshots /tmp/slider-review/screenshots
```

The four matrix attachments contain minimum/midpoint/maximum/disabled states
for ocean/graphite in light/dark mode. The fifth shows a 320 pt German label
and growing endpoint content at accessibility2. Screenshot names are declared
in `screenshots.json`; generated Xcode projects and external evidence are not
committed. Run on a clean exact head, inspect all PNGs, and retain the shared
runner's SHA/device/attachment records.

Native adjustment tests check caller-unit binding updates, step alignment,
reachable endpoints for the tested divisible span, balanced begin/end editing
callbacks, actual disabled drag suppression, native accessibility label/value,
stable frames under value and disabled changes, and minimum 44 pt control
targets (only subpixel AX rounding is tolerated). Actual drags at both vertical
edges prove the native target responds beyond its original intrinsic height;
padding an inert frame cannot pass this regression. Narrow-layout checks compare
actual SwiftUI label/component geometry at large and accessibility2 sizes and
assert all captured content remains within the viewport without overlap.

Test-integrity mapping: this fresh component had no prior hosting assertions
or screenshot helper dependency. No previous tests are removed or moved. The
new package suite validates configuration/public construction; real UI checks
live in `SliderReviewUITests` and do not replace the unchanged color tests.
Native keyboard/VoiceOver operation, minimum OS, hardware, and macOS rendered
layout remain unobserved; do not infer them from simulator screenshots.
