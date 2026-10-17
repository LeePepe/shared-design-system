# NativeChip (unreleased)

This additive API belongs to the Strata rebuild and is not in the released
NativeDesignKit 0.3.0 color bridge. HeroUI supplies inventory only.

```swift
public enum NativeChipTone: Equatable, Sendable {
    case neutral, accent, critical
}

public struct NativeChip<Label: View>: View {
    public init(theme: NativeDesignTheme, tone: NativeChipTone,
                @ViewBuilder label: () -> Label)
    public init(theme: NativeDesignTheme, tone: NativeChipTone,
                removalAccessibilityLabel: Text, onRemove: @escaping () -> Void,
                @ViewBuilder label: () -> Label)
}
```

Pass an explicitly resolved theme. Its provider supports only `ocean` and
`graphite`; resolution errors propagate unchanged. Neutral pairs `surface`
with `foreground`, accent pairs `accent` with `onAccent`, and critical pairs
`critical` with `onCritical`. All fills are solid. There is no blur, shadow,
local palette, fallback theme, or automatic status/business meaning.

```swift
NativeChip(theme: theme, tone: .neutral) { Text("Draft") }

NativeChip(theme: theme, tone: .accent,
           removalAccessibilityLabel: Text("Remove Design filter"),
           onRemove: { selectedFilters.remove("design") }) {
    Text("Design")
}
.disabled(!canEdit)
```

The caller owns labels, localization, formatting, data and removal state.
Supply meaningful text with critical tone; its decorative triangle provides
a non-color cue but no library-assigned status announcement. The label remains
readable by accessibility, and the separate native `Button` announces the
explicit localized removal label. Static chips are content, with no implicit
action, selected state or whole-chip button. Removal calls the closure and
does not hide the chip; the caller decides how the collection changes.

Removal has a 44 × 44 pt target, native Button semantics, pressed/focus outlines
and disabled action blocking. A dashed outline marks a disabled remove target
without fading text. The chip uses a semantic subheadline font and permits
multiline height growth. Compact chips have a capsule silhouette; continuous
corners stay bounded as content grows so long labels remain on opaque fill.
Do not constrain caller content to a fixed height or add a one-line limit.

The portable SwiftUI fixture at `Tests/Fixtures/ChipReview` covers all three
tones, static/removable/disabled states, actual removal dispatch, caller-owned
state, accessibility labels, target size, stable geometry and narrow long-text
growth. Real XCTest captures cover ocean/graphite × light/dark and a narrow
accessibility-size case. These establish evidence only for the tested simulator
and exact SHA recorded by the runner; they do not establish minimum-OS,
physical-device, macOS rendering or observed VoiceOver/keyboard operation.

The released color resolver, exact Tokens 0.1.1 dependency, Swift 6 and declared
iOS 15/macOS 12 floors remain unchanged. Roll back by removing Chip call sites
and restoring the prior reviewed package revision; no persisted state migrates.
