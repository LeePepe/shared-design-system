# Native controls (unreleased candidate)

Import `SwiftUI` and `NativeDesignKit`. Resolve an explicit `NativeDesignTheme`
before rendering. Supply [foundation metrics](FOUNDATIONS.md) from reviewed
provider data. There is no default theme, metrics scale, formatter, loading task
or error recovery. NativeDesignKit still consumes the real exact Tokens 0.1.1
release; the added provider style data has no claimed published consumption.

All labels/content below are generic `@ViewBuilder` slots except text-entry
localized title keys and explicitly identified accessibility `Text` inputs.
Bindings, actions, locale/calendar/time zone, validation, focus and task lifetime
remain with callers. Native keyboard, touch, pointer and disabled behavior stays
with SwiftUI. Apply caller typography, `.disabled`, `.focused`, `.onSubmit`,
accessibility hints and identifiers as ordinary modifiers.

| Family | Public constructors and explicit inputs |
| --- | --- |
| C01 | `NativeButton(theme:metrics:presentation:isLoading:loadingLabel:action:label:)`; presentation `.prominent`, `.bordered`, `.plain`, `.glass` |
| C02 | `NativeToggle(isOn:theme:metrics:label:)`; `NativeCheckbox(isOn:theme:metrics:checkedValue:uncheckedValue:label:)`; `NativeRadioGroup(selection:theme:metrics:label:content:)` |
| C03 | `NativeTextField(_:text:theme:metrics:)`, `NativeSecureField(_:text:theme:metrics:)`, `NativeTextEditor(text:theme:metrics:accessibilityLabel:label:)`, `NativeSearchField(_:text:theme:metrics:clearLabel:)` |
| C04 | `NativePicker(selection:theme:metrics:presentation:label:content:)`; presentation `.menu`, `.segmented`, `.inline` |
| C05 | `NativeSlider(value:in:step:theme:metrics:onEditingChanged:label:)` with Double binding/range; `NativeStepper(value:in:step:theme:metrics:label:)` with Int binding/range |
| C06 | `NativeDatePicker(selection:in:displayedComponents:theme:metrics:label:)` with Date binding/range and native `DatePickerComponents` |
| C07 | `NativeProgress(value:total:presentation:theme:diameter:lineWidth:accessibilityValue:label:)`; presentation `.linear`, `.ring`, `.indeterminate`; optional Double value |
| C08 | `NativeBadge(theme:metrics:tone:label:)`, `NativeTag(theme:metrics:tone:removeLabel:onRemove:label:)`, `NativeIconLabel(theme:metrics:icon:label:)`, `NativeAvatar(theme:diameter:accessibilityLabel:content:)`, `NativeAnimatedNumber(value:theme:motion:accessibilityLabel:format:)` |

```swift
NativeButton(theme: theme, metrics: metrics, presentation: .prominent,
             isLoading: isLoading, loadingLabel: Text("Loading"), action: run) {
    Label("Run action", systemImage: "arrow.right")
}
NativePicker(selection: $choice, theme: theme, metrics: metrics, presentation: .segmented) {
    Text("Choice")
} content: {
    Text("First").tag(0)
    Text("Second").tag(1)
}
NativeAnimatedNumber(value: total, theme: theme, motion: motion,
                     accessibilityLabel: Text("Total"), format: formatTotal)
```

A button's label slot supports text, icon, and arbitrary labeled content. An
icon-only caller supplies `.accessibilityLabel`. Loading preserves label layout,
adds native progress, and disables repeat activation; `loadingLabel` is its
accessible value. The caller owns the operation and returns loading to false.
Glass uses the native Glass button style on iOS/macOS 26+, with a bordered native
fallback on older systems and when Reduce Transparency is enabled.

Checkbox is native macOS `ToggleStyle.checkbox`. SwiftUI has no iOS checkbox
style: iOS uses a ToggleStyle backed by a native Button with a checkmark, caller
localized checked/unchecked values and selected trait. Radio uses native
`PickerStyle.radioGroup` on macOS and inline Picker on iOS. Options must have
unique tags of the same type as their selection binding. Segmented pickers do
not wrap long labels; the caller selects menu/inline presentation for large
text or long translations, as the fixture does for its section picker.

Text and secure fields use native editing. Search adds a separately labeled
clear Button. TextEditor shows a caller label and separate accessible label;
its height remains caller-owned. iOS 15/macOS 12 keep the platform TextEditor
background because the public hiding API starts at iOS 16/macOS 13. A local
SwiftUI color scheme ties that native background to the required explicit theme,
including dark controls inside a light app and the inverse. This does not change
the surrounding app's appearance. Production uses no UIKit/AppKit override.

Slider requires a finite range and finite positive step; stepper requires a
positive step. Native controls enforce range behavior. Progress requires a
finite positive total, finite value when supplied, and positive finite geometry.
A nil value or `.indeterminate` uses native activity progress. Ring is a native
ProgressView with a custom circular style, visually clamped to 0...1. The caller supplies a localized accessible progress value, including indeterminate state. Its track
uses the theme's secondary text token and its fill the information token.

`NativeControlTone` is `.neutral`, `.info`, `.warning`, `.critical`. Badge/tag
foreground/background pairs use corresponding semantic/on-semantic tokens;
neutral uses raised surface/primary text. A removable tag keeps its remove
Button individually accessible. Avatar clips caller content into a circle with
an explicit diameter and accessible label; it never downloads an image.

Animated number uses SwiftUI scalar interpolation and a caller formatter. Its
accessible value is always the complete target, and Reduce Motion removes the
animation. Callers should keep formatter work inexpensive and avoid announcing
each animation frame. There is no timer or asynchronous task to cancel.

## Executable validation and limits

The dual-platform sample at `Tests/Fixtures/NativeDesignKitShowcase/README.md`
uses public imports, synthetic data and relative package references. It covers
all constructors and includes XCTest interactions and real screenshot
attachments. Its style adapter reads a separately supplied provider artifact;
it does not ship a second style table. Attachments alone are evidence, not
regression comparisons. The sample documents a deterministic PNG comparison
command, explicit thresholds/masks and OS/device-specific baseline review.
Minimum-OS runtime, assistive-technology navigation and exact published style
provider consumption require separate evidence.

The finite machine registry catalogs only `NativeTokenColor`, `NativeDesignTheme`
and `NativeCard`. It does not enumerate Controls or Foundations. This document
and `FOUNDATIONS.md` are the additive public API inventories for those families;
the registry must not be used as an exhaustive symbol list.
