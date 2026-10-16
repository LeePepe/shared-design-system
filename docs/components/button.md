# Button — Strata round 2

The source follows the accepted [Strata theme](../strata-theme-v0.2.md) and
Button stage in approved prototype revision
`b4bff430517ed2e2944f814d8b5ab89a1866ee33`. The public API contract is
[ai/components/button.md](../../ai/components/button.md).

Primary uses the provider's solid contrast pair, including hover and active
roles. Secondary uses the shared dense neutral surface and its weak material
edge; it introduces no nested blur. Solid/Reduce Transparency Secondary uses the neutral inset fill so its capsule
stays distinct from the inner card plane. Ghost uses the explicit brand text role and
a subtle fill for hover/press. Disabled controls retain readable neutral text;
no whole-content opacity reduces contrast. Native SwiftUI Button owns activation
and accessibility semantics, while the caller owns action, loading and labels.
Loading reserves both label footprints, adds a circular activity cue and
prevents activation. Reduce Motion stops cue rotation and press scaling.

Semantic callout text and 44 pt minimum targets adapt the demo proportions to
native controls. Bounded 22 pt corners remain capsule-like at the normal height
and contain multiline localized text at accessibility sizes. Neither labels
nor typography are clipped or reduced to force a fixed height.

The existing initializer remains available with solid treatment. The additive
overload requires an explicit `surface`, making material selection independent
from palette, light/dark and caller state. Rollback removes uses of that overload
before returning to the earlier package revision; no stored data is involved.

The dedicated [ButtonReview fixture](../../Tests/Fixtures/ButtonReview/README.md)
composes actual NativeButton controls inside the shared 32 pt specimen shell
and a dense 24 pt inner stage. Its 20 theme/material captures retain the same
content and geometry. Separate behavior boards preserve the existing enabled,
disabled and loading dispatch checks, 320 pt German localization, Dynamic Type
growth, full-label containment and stable loading footprint assertions. Legacy
brand matrices remain covered. Package tests additionally verify the provider
primary/hover/active contrast pairs, Ghost's role, disabled colors and the
bounded-corner regression. Actual composite contrast and Reduce Transparency
need the runtime evidence recorded against the exact PR head.

Generated screenshots and result bundles live outside git. Screenshots do not
establish VoiceOver, minimum-OS, physical-device or macOS pointer/keyboard
acceptance. Remote gates and an independent exact-SHA visual review are
separate from local candidate-provider verification.
