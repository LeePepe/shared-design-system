# ProgressBar review fixture

Synthetic SwiftUI-only test app driven by XCTest UI automation. The canonical
`project.yml` uses the local package and inherited iOS 15 / Swift 6 settings.
No UIKit/AppKit hosting, native-control traversal or product integration is used.
UITests import XCTest only. Generated projects and all run evidence stay out
of git.

From the repository root, use the [portable runner](../Support/README.md):

```sh
python3 Tests/Fixtures/Support/run.py ProgressBarReview \
  --results /tmp/progress-review/Results.xcresult \
  --screenshots /tmp/progress-review/screenshots
```

Use fresh external paths. Also run `scripts/verify --all` at the same clean
commit. The runner records actual SHA, runtime and test results, then exports
the exact XCTest screenshot attachments in `screenshots.json`. Screenshot
matrix: ocean/graphite × light/dark, each showing zero/middle/complete/waiting;
320 pt long German text at standard and accessibility2 sizes; an explicitly
labeled SwiftUI Reduce Motion environment request. The latter does not assert
system preference changes or native animation suppression.

Tests exercise caller state changes and native progress accessibility values,
finite out-of-range normalization, stable state dimensions, real text growth,
SwiftUI-measured text bounds/ordering, full viewport containment and a >=44 pt
fixture action target. The read-only ProgressBar has no action/disabled/
selection/keyboard behavior to invent. No VoiceOver or minimum-OS result is
claimed by these automation checks.

Test integrity: no prior ProgressBar component or hosting tests exist at the
recorded initial base. No assertions were removed or moved; all tests here are
additive. The foundation's Button hosting-to-UI mappings remain owned by its
prerequisite PR and are unchanged by this component delta.
