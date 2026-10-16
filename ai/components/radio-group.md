# NativeRadioGroup (unreleased)

Part of the [Strata rebuild](../COMPONENTS.md); absent from NativeDesignKit
0.1.0. The HeroUI inventory supplies the name only. This is a fresh SwiftUI
implementation with no copied component code or additional dependency.

```swift
public struct NativeRadioGroup<Selection: Hashable, Label: View, Options: View>: View {
    public init(theme: NativeDesignTheme,
                selection: Binding<Selection>,
                @ViewBuilder label: () -> Label,
                @ViewBuilder options: () -> Options)
}
```

```swift
NativeRadioGroup(theme: theme, selection: $density) {
    Text("Review density")
} options: {
    Text("Compact").tag(Density.compact)
    Text("Balanced").tag(Density.balanced)
    Text("Detailed").tag(Density.detailed)
}
.disabled(!canEdit)
```

`Density`, its values, `density`, and `canEdit` belong to the caller. Supply
localized labels and unique `.tag` values matching the binding's exact type.
For optional selection, use optional tags. Dynamic options use caller-owned
stable `ForEach` identity; there is no index mapping, option model, automatic
initial selection, formatting or selection storage in the library. The caller
keeps the selected value valid as its available options change.

The control delegates binding updates, disabled input, focus, keyboard handling
and accessibility semantics to native `Picker`. macOS uses `.radioGroup`.
iOS uses `.inline`: a native vertical single-selection list with a checkmark,
not visual radio circles. Native selected semantics and the checkmark identify
the selected row without relying on color. Caller `.disabled(...)` applies to
the whole group, and caller option modifiers remain part of the options builder.

The explicit `NativeDesignTheme` provides foreground and accent colors. There
is no ambient theme, palette, fallback, provider modification or glass layer.
Theme construction and unchanged provider errors follow the foundation contract.
Semantic body typography and vertically growing option content support long
labels; option layout reserves at least 44 × 44 pt. No fixed group height or
single-line limit is imposed. Native platform chrome remains system managed.

The isolated [review fixture](../../Tests/Fixtures/RadioGroupReview/README.md)
checks actual iOS binding changes, exclusive selection, disabled coordinate
taps, external state updates, stable tagged identity after caller reordering,
row targets and localized-content-ready long text at accessibility2 in a 320 pt
board. Its screenshots cover ocean/graphite × light/dark and the narrow case.
Exact tested SHA and results belong to the external run manifest and PR.
These checks do not claim live VoiceOver, native keyboard/focus interaction,
macOS rendering, physical-device or minimum-OS acceptance.

Swift 6, iOS 15/macOS 12 declarations, exact DesignTokens 0.1.1 and the released
color bridge remain unchanged. Roll back by removing these call sites and
restoring a reviewed package revision; no data migration is needed.
