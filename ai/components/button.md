# NativeButton (unreleased)

This API is part of the unreleased [Strata rebuild](../COMPONENTS.md), not
NativeDesignKit 0.1.0. HeroUI informs the component inventory only; the
implementation is native SwiftUI and copies no earlier unmerged component.

```swift
public enum NativeButtonVariant: Equatable, Sendable {
    case primary, secondary, ghost
}

public struct NativeButton<Label: View, LoadingLabel: View>: View {
    public init(theme: NativeDesignTheme,
                variant: NativeButtonVariant,
                isLoading: Bool,
                action: @escaping () -> Void,
                @ViewBuilder label: () -> Label,
                @ViewBuilder loadingLabel: () -> LoadingLabel)
}
```

All arguments are explicit. Supply localized content in both builders and own
the loading state and action. The loading builder should describe the work
(e.g. `Text("Saving changes…")`), rather than supplying a spinner alone.

```swift
NativeButton(theme: theme, variant: .primary, isLoading: isSaving,
             action: save) {
    Text("Save changes")
} loadingLabel: {
    Text("Saving changes…")
}
.disabled(!canSave)
```

Primary uses the exact provider accent/onAccent pair on a solid capsule.
Secondary uses a neutral solid surface and foreground; Ghost omits a normal
background and draws a token-colored pressed cue. No glass layer sits under
main-action text. Pressed feedback has a clear outline, keyboard focus has an
accent outline, and Reduce Motion removes the short scale animation. Disabled
uses unchanged neutral/secondary token colors instead of fading all text.

Both labels remain in layout to reserve the larger footprint, with exactly the
current label exposed to accessibility. A decorative hourglass identifies
loading without relying on animation or color. Loading prevents dispatch;
`.disabled(true)` also prevents dispatch. The component owns no async task,
network call, retry policy or state transition.

SwiftUI `Button` retains its native action and accessibility semantics and
supports caller `.keyboardShortcut(...)`. The hit area is at least 44 × 44 pt;
semantic font sizes, wrapping, and intrinsic height allow longer localized
labels. Caller actions remain caller owned. macOS captures cover both provider
brands, both themes, three variants and normal/loading/disabled states, plus a
320 pt case requesting an accessibility Dynamic Type size. macOS does not
establish iOS Dynamic Type scaling. Screenshots do not prove VoiceOver, physical
device touch or minimum-OS behavior; those require separate consumer validation.

Existing `NativeTokenColor` behavior, dependency and platform floors are
unchanged. To roll back, remove this API's call sites and restore the previously
reviewed package revision. No persisted state or migration is involved.
