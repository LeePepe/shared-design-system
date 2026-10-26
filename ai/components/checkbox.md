# StrataCheckbox (unreleased)

Part of the unreleased Strata rebuild. Strata 0.3.0 contains only
the color bridge; evaluate Checkbox at an explicitly reviewed revision.
HeroUI supplies inventory only; this is a fresh native SwiftUI implementation.

```swift
public struct StrataCheckbox<Label: View>: View {
    public init(theme: StrataTheme,
                isOn: Binding<Bool>,
                @ViewBuilder label: () -> Label)
}

StrataCheckbox(theme: theme, isOn: $includeAttachments) {
    Text("Include attachments")
}
.disabled(!canEdit)
```

Theme and binding are required. Callers own state, localization, formatting,
and the label content. Reconstruct the explicit theme when mode or brand
changes. The provider supports ocean/graphite only; token resolution errors
propagate unchanged through `StrataTheme` construction.

On iOS, the enabled selected square uses the exact accent/onAccent token pair and a
checkmark. Unselected uses a clear fill and neutral secondary-foreground outline.
Disabled uses unchanged neutral surface/secondary-foreground colors with the
checkmark retained for selected state. Text is never faded with whole-view
opacity; the pressed row has a neutral outline. No per-control glass or additional palette is introduced.

The underlying control is SwiftUI `Toggle`. iOS uses a native `Button` inside
its `ToggleStyle` for the entire row, with a native Toggle accessibility
representation exposing label, on/off value and disabled semantics. macOS uses
SwiftUI's native checkbox style, with token accent tint and explicit mode;
native macOS indicator/disabled rendering remains platform controlled. The row has a minimum 44 pt height/width;
semantic body text wraps and grows rather than shrinking or truncating.
Caller accessibility labels/identifiers can be applied to the component.

The synthetic iOS review fixture tests real binding writes, caller-driven
updates, disabled taps, accessible label/value, target bounds, stable selection
layout and long text at accessibility Dynamic Type. It exports actual app
screenshots for both brands and modes, including enabled/disabled on/off states
and narrow accessibility layouts. See `Tests/Fixtures/CheckboxReview/README.md`.
Screenshot evidence does not establish VoiceOver operation, live keyboard/focus,
physical-device touch, minimum iOS 15/macOS 12 behavior or macOS rendered parity.

No existing color bridge behavior or dependency/platform floor changes.
Rollback removes Checkbox call sites and restores the previously reviewed
package revision. There is no library-owned persistence or migration.
