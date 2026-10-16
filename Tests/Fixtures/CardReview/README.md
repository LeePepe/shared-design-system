# Card native review fixture

Synthetic SwiftUI integration fixture, with XCTest UI tests importing XCTest
only. It has no product data or UIKit/AppKit host. The app's public-import entry
constructs the explicit theme; only `NativeCardBehaviorFixture.swift` uses
`@testable` for the internal nil-default Reduce Transparency input. Screenshots
label this forced fixture preference, and production still follows the system.

From the repository root, run the shared fixture runner with new external paths:

```sh
mkdir -p /tmp/card-review
python3 Tests/Fixtures/Support/run.py CardReview \
  --results /tmp/card-review/results.xcresult \
  --screenshots /tmp/card-review/screenshots > /tmp/card-review/ui.log 2>&1
python3 Tests/Fixtures/CardReview/verify-material.py \
  /tmp/card-review/screenshots /tmp/card-review/ui.log \
  --output /tmp/card-review/material.json
```

Redirect the runner's complete output to the `ui.log` used by the material
check. The second command decodes the original runtime PNGs using Python's
standard library. It compares like-for-like composited pixels for solid and
fallback and checks that normal Glass shows the token backdrop. It also checks
normal-text contrast at 4.5:1 for primary and auxiliary content across all four
Glass captures, matching full glyph pixels to the exact Tokens 0.1.1 checkout's
`dist/resolved.json`, verified against `Package.resolved` and checkout revision.
It commits no copy of the token colors.

The text sample points come from this unchanged four-slot/large fixture. Their
native-point offsets are anchored to XCTest's reported `(Card.maxX - 8,
Card.midY)`. On the 402×874 runtime, primary samples the full `d` glyph at
`(298,276)` and auxiliary samples the full glyph at `(310,329)`. Each is compared
with three adjacent untextured material points over the token accent strip,
including `(328,336)` for auxiliary. The JSON records all exact coordinates,
observed bytes, provider/PNG hashes and minimum measured ratios. A missing
full-glyph token match fails, preventing antialiased edge pixels from being
treated as foreground colors. The same checker rejects the original dev2
graphite/dark capture at 4.330786:1; the specimen and backdrop are unchanged.
This sampled evidence covers the review backdrop, not arbitrary caller imagery
or foreground overrides.

The canonical project is `project.yml`; XcodeGen output, DerivedData, xcresult
bundles, PNGs and logs are generated evidence and stay out of git. The runner
exports the exact attachment names listed in `screenshots.json`.

Normal cards are wholly onscreen. Accessibility3 long text uses a scroll view;
separate top/bottom screenshots are labeled segments of the same real layout.
Tests check the complete card's growth and horizontal bounds, slot ordering,
caller action/disabled behavior, content-only equivalence and all 16 theme /
material / preference layouts. They make no VoiceOver or minimum-OS claim.
