# NativeSwitch (unreleased)

`NativeSwitch` is part of the unreleased [Strata rebuild](../COMPONENTS.md).
It is a SwiftUI `Toggle` using native switch styling, with caller-owned state
and label content. It is unavailable in NativeDesignKit 0.1.0.

```swift
import DesignTokens
import NativeDesignKit
import SwiftUI

struct SwitchExample: View {
    let theme: NativeDesignTheme
    @State private var isOn = false

    var body: some View {
        NativeSwitch(theme: theme, isOn: $isOn) {
            Text("Enable notifications")
        }
    }
}
```

The public initializer is
`init(theme: NativeDesignTheme, isOn: Binding<Bool>, @ViewBuilder label: () -> Label)`.
Construct the theme explicitly, for example with
`try NativeDesignTheme(theme: .light, brand: "ocean")`. The provider supports
`ocean` and `graphite`; the five Strata colors remain a provider gap. Theme
construction propagates token errors unchanged. No default theme or local
palette is supplied.

The label uses the theme foreground and a semantic body font. Native switch
chrome receives the provider accent through `.tint` and the theme's explicit
light/dark color scheme, independent of the surrounding environment. The
platform supplies its native track, thumb, disabled rendering, focus and
animation. There is no glass layer or custom animation; native accessibility
preferences remain in effect.

Labels can wrap and grow without a fixed row height. The row has a minimum
44 × 44 pt layout and rectangular hit region without an overlay covering the
native switch. Keep labels meaningful, localized and visible. SwiftUI owns
the Toggle's on/off accessibility and keyboard semantics; caller
`.accessibilityLabel(...)`, `.disabled(...)`, and binding updates pass through.
No tap gesture substitutes for Toggle interaction, and no state, persistence
or asynchronous work is owned by the component.

Hosted tests exercise native control activation, binding and disabled state,
native accessibility on/off values, keyboard focus acceptance and multiline
measurement. The headless macOS host does not expose SwiftUI's virtual
accessibility label tree, so spoken caller-label output and live keyboard
activation require separate validation. macOS PNGs cover both
brands and themes, on/off and disabled states, and narrow long labels. iOS
hosting tests compare default and accessibility Dynamic Type layout. A macOS
Dynamic Type environment alone does not prove macOS typography scaling.
The macOS snapshot host renders native tracks in neutral colors; these PNGs
do not visually establish brand accent rendering on active platform chrome.
Screenshots do not establish VoiceOver speech, physical-device interaction or
minimum-OS acceptance.

The exact DesignTokens 0.1.1 pin, iOS 15/macOS 12 floors, and released color
bridge are unchanged. To roll back, remove these call sites and restore the
previously reviewed package revision. There is no persisted state to migrate.
