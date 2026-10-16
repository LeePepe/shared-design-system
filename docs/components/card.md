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

## Acceptance and evidence

- Public-import compilation covers all four slots, the content-only initializer,
  empty slots, both provider
  brands, explicit light/dark and solid/glass choices.
- Actual hosted SwiftUI renders cover the same layout across that matrix, plus
  long text, narrow width and Reduce Transparency. The internal test preference
  is explicitly labeled; it does not claim the host system setting was changed.
  Pixel checks verify Glass differs over the token backdrop and its fallback
  matches the explicit theme's solid surface.
- Layout checks compare fitting heights and ensure content can grow; no card
  gesture wraps or intercepts descendants. A macOS hosted event-dispatch test
  checks a caller button's action and a disabled descendant's suppression.
  iOS separately measures semantic-font growth at accessibility Dynamic Type;
  macOS screenshots make no text-scaling claim.
- PNG evidence is generated outside git with `NDK_SNAPSHOT_DIR`; PR evidence
  records the exact source SHA, platform and image paths. Images are not shipped
  as resources or represented as minimum-OS, interaction or release acceptance.
- Repository `scripts/verify` covers host and required iOS simulator build/test.
  Minimum supported OS runtimes require separate evidence when available.
