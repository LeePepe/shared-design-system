# NativeRadioGroup (unreleased)

Part of the [Strata rebuild](../COMPONENTS.md); absent from NativeDesignKit
0.3.0. The HeroUI inventory supplies the name only. This is a fresh SwiftUI
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

On iOS, put this control directly in a native `List` or `Form` (a transparent
`Group` is also suitable). The native inline style needs that row host. A
standalone stack can fall back to a wheel picker and is outside this component's
inline presentation contract. Do not wrap it in a single stacked list row.

`Density`, its values, `density`, and `canEdit` belong to the caller. Supply
localized labels and unique `.tag` values matching the binding's exact type.
For optional selection, use optional tags. Dynamic options use caller-owned
stable `ForEach` identity; there is no index mapping, option model, automatic
initial selection, formatting or selection storage in the library. The caller
keeps the selected value valid as its available options change.

The control delegates binding updates, disabled input, focus, keyboard handling
and accessibility semantics to native `Picker`. macOS uses `.radioGroup`.
iOS uses `.inline` in that host: a native vertical single-selection list with a checkmark,
not visual radio circles. Native selected semantics and the checkmark identify
the selected row without relying on color. Caller `.disabled(...)` applies to
the whole group, and caller option modifiers remain part of the options builder.

The explicit `NativeDesignTheme` provides foreground and accent colors. There
is no ambient theme, palette, fallback, provider modification or glass layer.
Theme construction and unchanged provider errors follow the foundation contract.
The native Picker subtree receives the explicit `theme.mode` as its SwiftUI
color scheme, including native disabled and selection chrome. The surrounding
caller environment retains its own mode. The native checkmark receives the
provider accent through both the tint and accent-color environments.
Semantic body typography and vertically growing option content support long
labels; option layout reserves at least 44 × 44 pt. No fixed group height or
single-line limit is imposed. Native platform chrome remains system managed.

The isolated [review fixture](../../Tests/Fixtures/RadioGroupReview/README.md)
checks actual iOS binding changes, exclusive selection, disabled coordinate
taps, external state updates, stable tagged identity after caller reordering,
row targets and long text at accessibility2 in a 320 pt
board. A caller-owned environment probe in the actual Picker label and options
also checks both explicit modes under an intentionally opposing caller scheme,
with real selection and disabled input. Screenshots cover ocean/graphite ×
light/dark, the narrow case and both opposing-environment boundaries.
Exact tested SHA and results belong to the external run manifest and PR.
These checks do not claim live VoiceOver, native keyboard/focus interaction,
macOS rendering, physical-device or minimum-OS acceptance.

NativeDesignKit 0.3.0 uses the repository-local DesignTokens target;
NativeDesignKit 0.1.0 historically used exact DesignTokens 0.1.1. This
unreleased RadioGroup preserves Swift 6, iOS 15/macOS 12 declarations and the
color-bridge behavior. Roll back by removing these call sites and restoring a
reviewed package revision; no data migration is needed.
