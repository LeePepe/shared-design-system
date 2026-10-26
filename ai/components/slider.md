# StrataSlider (unreleased)

Part of the [Strata rebuild](../COMPONENTS.md). This is an additive API under
`Controls/Slider`, not a Strata 0.3.0 release. HeroUI supplies the
inventory name only; the interaction is SwiftUI `Slider`.

```swift
public enum StrataSliderConfigurationError: Error, Equatable, Sendable {
    case invalidRange
    case invalidStep
}

public struct StrataSlider<Label: View, MinimumValueLabel: View, MaximumValueLabel: View>: View {
    public init(theme: StrataTheme,
                value: Binding<Double>,
                in range: ClosedRange<Double>,
                step: Double,
                onEditingChanged: @escaping (Bool) -> Void,
                @ViewBuilder label: () -> Label,
                @ViewBuilder minimumValueLabel: () -> MinimumValueLabel,
                @ViewBuilder maximumValueLabel: () -> MaximumValueLabel) throws
}
```

All arguments are explicit. Resolve `StrataTheme` with an explicit mode
and provider brand (`ocean` or `graphite`), then construct the control at a
boundary that can handle errors. Theme token errors propagate unchanged before
Slider construction. The Slider initializer throws `.invalidRange` for
nonfinite bounds, equal bounds or a nonfinite difference, and `.invalidStep`
for a nonfinite or nonpositive step. `ClosedRange` itself requires ordered
bounds; do not construct a reversed or NaN range.

```swift
// Inside a throwing view factory, using caller-owned @State `amount`:
try StrataSlider(theme: theme, value: $amount, in: 0...100, step: 5,
                 onEditingChanged: { isEditing = $0 }) {
    Text("Amount")
} minimumValueLabel: {
    Text("0 units")
} maximumValueLabel: {
    Text("100 units")
}
.disabled(!canEdit)
```

The caller supplies finite values within the range, formats the current value
and endpoint content, localizes every label, and owns disabled state and editing
effects. The wrapper passes range, step, binding and editing callback directly
to native Slider. It does not map indices, clamp values, round values, start a
timer, or add a drag gesture. A step need not divide the span and may exceed it;
native SwiftUI determines adjustment behavior. No special endpoint reachability
or out-of-range binding clamp semantics are promised.

The growing semantic body label supplies the native control's accessibility
name; a separate visible copy is hidden from accessibility to avoid duplicate
announcements. Min/max builders form a growing caption row below the track,
leaving space for its interaction. They describe values rather than mapping
them. The native control has a minimum 44 × 44 pt layout, native accessibility
adjustment and keyboard behavior. Callers can supply an accessibility value
when their units require it. Keep sufficient width for meaningful adjustment.

Token accent supplies tint, token foregrounds style the content, and explicit
theme mode sets native chrome. There is no control glass, palette, provider,
default theme or cache. Strata 0.3.0 uses the repository-local
DesignTokens target; NativeDesignKit 0.1.0 historically used exact DesignTokens
0.1.1. This unreleased Slider preserves the Swift 6 / iOS 15 / macOS 12
declarations.

The component-owned `SliderReview` synthetic SwiftUI app uses XCTest UI
automation for native binding updates, step alignment, editing callbacks,
disabled input, accessibility identity, stable value-state frames, 44 pt
targets, both provider brands/themes, and a narrow long-label Dynamic Type
case. Screenshots and run manifests are external and tied to their tested SHA.
This does not establish VoiceOver operation, hardware keyboard behavior,
physical-device or minimum-OS acceptance, or macOS rendered UI. To roll back,
remove call sites and restore the previous reviewed package revision; there
is no persisted component state.
