# ListReview

A real SwiftUI fixture for the unreleased NativeList. The faithful specimen
uses three synthetic caller-owned design notes following the accepted Strata
reference: icon, primary/secondary text, trailing metadata, selected checkmark
and label, compact heading, context/footer and selected count. The real
NativeList supplies rows and the dense 24pt reading plane; shared
`StrataSpecimen` supplies page, backdrop and the 32pt outer region. It contains
its own ScrollView, so the fixture does not nest scrolling or duplicate glass.

`project.yml` explicitly includes `../Shared/StrataSpecimen.swift`. Its documented
DEBUG `@testable` import accesses the shared surface/Reduce Transparency seams;
UI automation imports only XCTest. No UIKit/AppKit hosting or image renderer
is used. The canonical runner is [Support/run.py](../Support/run.py).

From the repository root, with the merged Strata foundation integrated:

```sh
python3 /tmp/ndk-strata/ui-serial.py "$PWD" \
  python3 Tests/Fixtures/Support/run.py ListReview \
  --results /tmp/ndk-list-review/Results.xcresult \
  --screenshots /tmp/ndk-list-review/screenshots \
  --derived-data /tmp/ndk-list-review/DerivedData
```

Use fresh external output paths. Simulator operations must remain under the
shared serial lock, including repository verification. Resolve the canonical
public DesignTokens repository at exact `0.2.0`, revision
`87bef8fbab5bf67a748815d7ed04d7ae199f760a`, without package-root or generated
Xcode-workspace mirrors or a path dependency. Record the full native/provider
SHAs, tested clean state, exact commands and resolved package receipts alongside
exported raw PNGs. Historical candidate-mirror captures remain separate evidence.

The fixture requires explicit `NDK_BRAND`, `NDK_THEME` (`light`/`dark`),
`NDK_SURFACE` (`glass`/`solid`), `NDK_SCENARIO`, `NDK_TEXT_SIZE`
(`large`/`accessibility2`) and `NDK_REDUCE_TRANSPARENCY` (`0`/`1`). Tests set
these on launch. Zero leaves the system preference unmodified; one forces
the internal fixture override. Invalid inputs or brands display an error,
without fallback theme or content.

Expected attachments in `screenshots.json`:

- Twenty unchanged-structure specimens: five palettes × light/dark × glass/solid.
- Ten explicitly named `forced-reduced` captures: internal fallback seam,
  separate from observed system preference evidence.
- Disabled and changed single selection, read-only rows and narrow
  accessibility2 long text.
- `list-system-reduced-transparency`: actual simulator Settings → Accessibility
  → Display & Text Size → Reduce Transparency, with the override left nil.
  The test observes SwiftUI's real accessibility environment and restores the
  original simulator setting in `defer`. It never changes host preferences.

Behavior checks cover real native row taps, repeated selected-row activation,
exclusive and multiple selection, individual/global disabled coordinate taps,
external changes, identity after caller reorder, read-only nonbutton semantics,
minimum 44pt targets and narrow Dynamic Type height growth. Frame containment
is asserted before specimen captures. All labels/state are fixture-owned.
The 320pt long-text case presents the actual List alone in a ScrollView at
accessibility2, with its complete original strings and a compact caller-owned
heading/footer. It omits showcase chrome so the test measures List text reflow.

Each screenshot also attaches `-geometry.json` telemetry with the SwiftUI
text frames, the observed heading accessibility frame and viewport size.
Captures require two consecutive identical actual runtime screenshots so
selection-label transitions cannot become the final evidence image.
`verify-contrast.py` reads those attachments and the exact provider artifact,
then inspects full-coverage glyph pixels and adjacent actual surface pixels.
It also checks solid/forced-fallback image equality in the specimen area.
The receipt records results and limitations; pixel antialiasing edges do not
represent full-coverage text contrast.

Run normal package verification as well as the UI fixture; the final evidence
receipt names the tested source/dependency SHAs and actual public-resolution
outcomes. Keyboard/focus/hover,
VoiceOver, minimum OS and physical devices require their own runtime evidence;
source affordances or static captures do not establish those results.
