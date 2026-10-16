# Card — Strata implementation

Intent: a fresh, noninteractive content surface with distinct title, body,
supporting context and caller-owned actions. HeroUI supplies only the component
inventory reference; no HeroUI implementation or old component code is reused.
The Owner request to rebuild the first ten components authorizes replacing the
earlier v1 single-content planning shape. The public contract is
[ai/components/card.md](../../ai/components/card.md).

The 24pt continuous radius follows [Strata v0.2](../strata-theme-v0.2.md).
A 16pt inset and 12pt vertical rhythm keep title and body visible on narrow
layouts. Semantic `.headline`, `.body` and `.subheadline` styles adapt to the
platform. There is no card-size enum, fixed height, line limit, decorative
border, shadow, animation, implicit gesture or additional focus target.

All colors come from the explicit `NativeDesignTheme` snapshot. NativeCard
uses the shared surface renderer, so solid and glass keep the same geometry.
Reduce Transparency selects the solid path without changing theme or brand.
The card does not create a new color/material authority or claim unsupported
Strata colorways. Consumer-supplied controls retain their identity and actions;
heading semantics apply only to the header slot.

Supporting content retains `.subheadline` hierarchy. A requested Glass card uses
the existing primary text token for that slot, including its solid accessibility
fallback; an explicit solid card uses the secondary text token. The secondary
dark token fell below 4.5:1 over the actual graphite Glass specimen. This policy
repairs that specimen without changing its backdrop, material or geometry.

## Acceptance and evidence

- Public-import compilation covers all four slots, the content-only initializer,
  empty slots, both provider
  brands, explicit light/dark and solid/glass choices.
- Actual iOS SwiftUI runtime screenshots cover the same layout across that matrix, plus
  long text, narrow width and Reduce Transparency. The internal test preference
  is explicitly labeled; it does not claim the host system setting was changed.
  `verify-material.py` compares the original XCTest PNG pixels: Glass differs
  over the token backdrop and its fallback matches the explicit solid surface.
  It also matches full primary/supporting glyph pixels to colors read from the
  exact pinned provider checkout, and requires at least 4.5:1 against three
  nearby actual material pixels for each role in all four Glass combinations.
  The original development graphite/dark auxiliary capture is rejected at
  4.330786:1. Reports record provider revision/hash, PNG hashes and coordinates.
  These samples establish contrast for the accepted fixture; arbitrary caller
  backdrops and foreground overrides still need their own evaluation.
- Layout checks compare fitting heights and ensure content can grow; no card
  gesture wraps or intercepts descendants. Real XCTest UI taps check a caller
  button's action and a disabled descendant's suppression. Real iOS frames
  measure semantic-font growth at accessibility Dynamic Type.
- PNG evidence is exported outside git from XCTest attachments; PR evidence
  records the exact source SHA, platform and image paths. Images are not shipped
  as resources or represented as minimum-OS, interaction or release acceptance.
- Repository `scripts/verify` covers host and required iOS simulator build/test.
  Minimum supported OS runtimes require separate evidence when available.

The [portable CardReview fixture](../../Tests/Fixtures/CardReview/README.md)
uses SwiftUI and XCTest UI automation, respecting the leaf restriction that
UIKit/AppKit test APIs are only for numeric color extraction.

The earlier hosting tests move to equivalent or stronger real UI assertions;
their assertions are preserved by the following mapping:

| Previous test | Current coverage |
| --- | --- |
| `testLongContentGrowsAtNarrowWidth` | `testLongTextAndAccessibilityDynamicTypeGrowWithoutHorizontalOverflow` |
| `testAccessibilityDynamicTypeExpandsContent` | Same UI test: regular → accessibility3 height growth, horizontal bounds, ordered slots and scrollable actions |
| `testThemeMaterialAndTransparencyChangesKeepTheSameLayout` | `testThemeMaterialAndTransparencyKeepStableLayout`: all 16 combinations |
| `testContentOnlyInitializerDoesNotReserveEmptySections` | `testContentOnlyAndEmptySlotsHaveTheSameCompactLayout` |
| `testCallerButtonsKeepTheirNativeActionsAndDisabledState` | `testCallerActionsAndDisabledDescendantRemainIndependent`: real taps and disabled coordinate taps |
| `testGlassFallbackRendersTheExplicitThemesSolidSurface` | Four visual UI tests plus `verify-material.py`: actual solid/Glass/fallback pixel checks |
| `testHostedSwiftUIEvidenceMatrix` | Four `testVisual…` UI tests and named XCTest attachments, plus narrow/accessibility segments |

The public-import compile tests remain in the package unchanged. No gate,
policy or preexisting numeric color-extraction test is changed by this move.
