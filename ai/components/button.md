# StrataButton (unreleased)

This API is part of the unreleased [Strata rebuild](../COMPONENTS.md), not
Strata 0.3.0. HeroUI informs the component inventory only; the
implementation is native SwiftUI and copies no earlier unmerged component.

```swift
public enum StrataButtonVariant: Equatable, Sendable {
    case primary, secondary, ghost
}

public struct StrataButton<Label: View, LoadingLabel: View>: View {
    // Existing initializer remains source compatible (solid treatment).
    public init(theme: StrataTheme,
                variant: StrataButtonVariant,
                isLoading: Bool,
                action: @escaping () -> Void,
                @ViewBuilder label: () -> Label,
                @ViewBuilder loadingLabel: () -> LoadingLabel)
    public init(theme: StrataTheme,
                variant: StrataButtonVariant,
                surface: StrataSurfaceStyle,
                isLoading: Bool,
                action: @escaping () -> Void,
                @ViewBuilder label: () -> Label,
                @ViewBuilder loadingLabel: () -> LoadingLabel)
}
```

New compositions pass material explicitly; theme, variant and state are always
explicit. Supply localized content in both builders and own
the loading state and action. The loading builder should describe the work
(e.g. `Text("Saving changes…")`), rather than supplying a spinner alone.

```swift
StrataButton(theme: theme, variant: .primary, surface: .glass, isLoading: isSaving,
             action: save) {
    Text("Save changes")
} loadingLabel: {
    Text("Saving changes…")
}
.disabled(!canSave)
```

Primary uses the exact provider accent/onAccent pair on a solid rounded shape.
At the normal 44 pt target height the shape is capsule-like. As multiline text
grows, continuous corners stay bounded at 22 pt so the fill contains the label;
the hit area, pressed cue and focus outline use the same shape. Semantic text
grows and wraps without shrinking typography to preserve the silhouette.
Secondary uses the shared neutral dense surface with a restrained material edge
when Glass is requested; it adds no second blur below a specimen shell. Ghost
uses provider brand text with no idle fill and a subtle brand hover/pressed fill.
Solid and reduced-transparency Secondary use the neutral inset role to retain
their capsule against the card plane.
Primary remains solid in both material choices and uses the provider's hover and
active pairs. Press feedback includes an outline; keyboard focus uses a
continuous accent outline. Reduce Motion removes scale and spinner rotation.
Disabled uses the neutral inset and secondary text roles without fading content.
The system Reduce Transparency preference selects the shared opaque treatment
without changing the explicit palette, mode, layout or action state.

Both labels remain in layout to reserve the larger footprint, with exactly the
current label exposed to accessibility. A decorative circular activity cue identifies loading; it stays static with
Reduce Motion while the caller's readable loading label remains visible. Loading prevents dispatch;
`.disabled(true)` also prevents dispatch. The component owns no async task,
network call, retry policy or state transition.

SwiftUI `Button` retains its native action and accessibility semantics and
supports caller `.keyboardShortcut(...)`. The hit area is at least 44 × 44 pt;
semantic callout typography, wrapping, and intrinsic height allow longer
localized labels. Caller actions remain caller owned. The standalone SwiftUI ButtonReview
fixture uses XCTest UI automation and actual iOS runtime screenshots for five Strata palettes × both themes × Glass/solid (20 specimens), as well as
legacy-brand behavior matrices with three variants and normal/loading/disabled states,
plus a 320 pt board with German localized labels at accessibility2. UI tests
measure long-label growth, full text/viewport containment, text bounds inside
the actual fill path, a stable loading footprint and ≥44 pt targets.
Actual enabled taps dispatch; disabled/loading
coordinate taps do not. Run `python3 Tests/Fixtures/Support/run.py ButtonReview
--results <external-new-path>.xcresult --screenshots <external-empty-directory>`
from the checkout; full instructions and the moved-test mapping are in
`Tests/Fixtures/Support/README.md` and `Tests/Fixtures/ButtonReview/README.md`.
The original initializer has a separate runtime lane that omits `surface`,
retaining its documented Solid treatment. It exercises action suppression and
re-enabling, a native held press, loading footprint and both complete German
accessibility labels with the same strict assertions as the explicit-surface
lane. Original and explicit Solid legacy-brand matrices provide paired actual
captures and frame observations for surface compatibility; explicit Glass
coverage remains alongside them. Runtime results and image comparisons must
identify the new exact source revision before claiming compatibility verification.
This fixture is separate from package gates. macOS package checks do not claim
rendered UI or iOS Dynamic Type evidence. Opaque provider RGBA checks
require at least 4.5:1 for onAccent/accent and foreground/surface in both brands
and themes; this does not establish contrast on arbitrary Glass backgrounds.
Screenshots do not prove VoiceOver, physical device touch, minimum-OS behavior
or live keyboard/focus interaction; those require separate observed validation.

Native hover, Tab focus and focused Space activation remain **unverified**.
At `07d431356c8f6338ece001853b18cba8bc62a6a3`, the strict input suite produced
1 pass / 3 failures / 0 skips. A separate flat ordinary SwiftUI control experiment
at `151851eaed040510635423f0b4bee937dee9bb48` also failed: hover callbacks0,
view/AX focusfalse and Space actions0. The cause is **UNKNOWN**. On2026-10-17
the Owner explicitly temporarily deferred this native-input acceptance and
continued component delivery; the strict tests and failed history are retained.
Visual or package-test success does not establish these inputs.

`StrataTokenColor` behavior and platform floors remain unchanged. This Button
revision uses the merged Strata foundation and public exact DesignTokens0.2.0
at `87bef8fbab5bf67a748815d7ed04d7ae199f760a`. The provider release does not
release Strata or establish remote CI or native input acceptance;
the PR records exact source/provider SHAs and remaining gates. To roll back, remove this API's call sites and restore the previously
reviewed package revision. No persisted state or migration is involved.
