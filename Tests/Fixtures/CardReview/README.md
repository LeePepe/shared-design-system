# Card native review fixture

Synthetic SwiftUI app and XCTest UI automation, with no product data or native
hosting bridge. The public-import entry constructs an explicit theme. Internal
fixture files use `@testable` only for the shared composition/surface helper and
nil-default Reduce Transparency input; production follows the system.

From the repository root, use fresh external result/build/screenshot paths:

```sh
mkdir -p /tmp/card-review
python3 Tests/Fixtures/Support/run.py CardReview \
  --results /tmp/card-review/results.xcresult \
  --screenshots /tmp/card-review/screenshots > /tmp/card-review/ui.log 2>&1
python3 Tests/Fixtures/CardReview/verify-material.py \
  /tmp/card-review/screenshots /tmp/card-review/ui.log \
  --output /tmp/card-review/legacy-material.json
python3 Tests/Fixtures/CardReview/verify-strata.py \
  /tmp/card-review/screenshots /tmp/card-review/ui.log \
  --output /tmp/card-review/strata-composites.json
```

Keep the complete runner log for geometry anchors. Both checkers read actual
XCTest PNGs and the manifest/lockfile's exact provider checkout. If resolution
uses an isolated scratch directory, pass `--provider-checkout` explicitly.
The default is `.build/checkouts/shared-design-tokens`. Reports record provider
revision/version/data hash, PNG hashes, coordinates and observed bytes. A
candidate mirror must be documented with both source SHAs and labeled local
only; it does not establish release or remote-CI acceptance.

The original behavior fixture retains caller action and disabled-descendant
taps, no implicit card activation, long-text growth, ordered slots, horizontal
bounds, accessibility3 scrolling, content-only/empty-slot equivalence and all
16 legacy brand/mode/material/preference layouts. Its twelve visual captures
retain the material/fallback and primary/secondary contrast checks. The original
320pt Card and token-accent backdrop now sit in an explicit 32pt outer region:
the strict Glass difference greater than five RGB levels is measured on that
outer material, while both inner and outer opaque fallback equality and inner
text contrast remain required. This follows the accepted one-outer-blur/dense-
inner-plane rule; testing a second translucent inner plane would contradict it.
The checker
now requires the auxiliary glyph to match the secondary role, guarding against
the former blanket primary-foreground workaround.

A separate faithful specimen uses the actual NativeCard source in the shared
32pt outer shell. Caller content supplies a token-colored icon plate, context
pill, title/body, footer/detail action, and a second explicitly synthetic
statistics card. The progress series and success badge use independent chart
and status roles. Five true provider palettes × light/dark × Glass/solid/fallback
produce thirty captures with matching geometry. The ordinary PNG checker scans
full-glyph primary, auxiliary, action and status colors and measures contrast
against dominant nearby background pixels from each actual composite. Its
420 text-role checks require at least 4.5:1. It also compares Card/stat/region
surface landmarks for solid/fallback equality and visible Glass distinction.
These checks cover this restrained shared backdrop, not arbitrary caller imagery
or foreground overrides.

The specimen action is tapped and its caller-owned feedback is checked. A
narrower long specimen and accessibility3 top/action/bottom segments verify
natural growth without clipping. A read-only preflight launches without an
override and asserts the actual system Reduce Transparency preference is off
before any Glass capture. The system fallback test opens Settings,
records the current Reduce Transparency value, turns it on, launches without
the internal override, confirms the actual SwiftUI environment value and
captures the fallback, then restores the original setting. Run simulator work
serially; do not run fixture suites or change simulator settings concurrently.
The matrix's other fallback captures explicitly use the internal test input.

The canonical project is `project.yml`; generated XcodeGen output, DerivedData,
xcresult bundles, logs and PNGs remain outside git. Attachment names are declared
in `screenshots.json`. Evidence must name a clean exact source SHA and provider
SHA. Screenshots and UI tests make no VoiceOver, physical-device, minimum-OS or
release-acceptance claim.
