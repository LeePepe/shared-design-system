# Card native review fixture

Synthetic SwiftUI integration fixture, with XCTest UI tests importing XCTest
only. It has no product data or UIKit/AppKit host. The app's public-import entry
constructs the explicit theme; only `NativeCardBehaviorFixture.swift` uses
`@testable` for the internal nil-default Reduce Transparency input. Screenshots
label this forced fixture preference, and production still follows the system.

From the repository root, run the shared fixture runner with new external paths:

```sh
python3 Tests/Fixtures/Support/run.py CardReview \
  --results /tmp/card-review/results.xcresult \
  --screenshots /tmp/card-review/screenshots
python3 Tests/Fixtures/CardReview/verify-material.py \
  /tmp/card-review/screenshots /tmp/card-review/ui.log \
  --output /tmp/card-review/material.json
```

Redirect the runner's complete output to the `ui.log` used by the material
check. The second command decodes the original runtime PNGs using Python's
standard library and samples coordinates reported by XCTest. It compares
like-for-like composited pixels for solid and fallback and checks that normal
Glass shows the token backdrop. It does not certify arbitrary backdrop contrast.

The canonical project is `project.yml`; XcodeGen output, DerivedData, xcresult
bundles, PNGs and logs are generated evidence and stay out of git. The runner
exports the exact attachment names listed in `screenshots.json`.

Normal cards are wholly onscreen. Accessibility3 long text uses a scroll view;
separate top/bottom screenshots are labeled segments of the same real layout.
Tests check the complete card's growth and horizontal bounds, slot ordering,
caller action/disabled behavior, content-only equivalence and all 16 theme /
material / preference layouts. They make no VoiceOver or minimum-OS claim.
