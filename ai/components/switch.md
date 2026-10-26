# StrataSwitch (unreleased)

`StrataSwitch` is part of the unreleased [Strata rebuild](../COMPONENTS.md).
It is a SwiftUI `Toggle` using native switch styling, with caller-owned state
and label content. It is unavailable in Strata 0.3.0.

```swift
import DesignTokens
import Strata
import SwiftUI

struct SwitchExample: View {
    let theme: StrataTheme
    @State private var isOn = false

    var body: some View {
        StrataSwitch(theme: theme, isOn: $isOn) {
            Text("Enable notifications")
        }
    }
}
```

The public initializer is
`init(theme: StrataTheme, isOn: Binding<Bool>, @ViewBuilder label: () -> Label)`.
Construct the theme explicitly, for example with
`try StrataTheme(theme: .light, brand: "ocean")`. The provider supports
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

The pure SwiftUI iOS review fixture is exercised through XCTest UI automation;
its UI tests import XCTest only. Tests tap the actual switch, observe
caller-visible state and binding-write counts, update state from a caller
button, and coordinate-tap a disabled switch in both initial states. The
native accessibility switch type, meaningful caller label and on/off values
are asserted through the UI automation tree. Long labels are measured at
standard and accessibility Dynamic Type sizes in a 280 pt layout, with an
actual switch tap at the larger size. Actual iOS PNGs cover both brands and
themes, normal and disabled on/off states, and narrow accessibility text.
The fixture's README records the migration from the prohibited native-hosting
tests. No AppKit or UIKit hosting/traversal remains in Switch tests.

These tests do not establish VoiceOver speech, physical-device interaction,
macOS keyboard focus, live external-keyboard activation or minimum-OS
acceptance. Native semantics remain owned by SwiftUI Toggle.

Strata 0.3.0 uses the repository-local DesignTokens target;
NativeDesignKit 0.3.0 uses the repository-local DesignTokens target;
NativeDesignKit 0.1.0 historically used exact DesignTokens 0.1.1. This
unreleased Switch preserves the iOS 15/macOS 12 floors and color-bridge
behavior. To roll back, remove these call sites and restore the previously
reviewed package revision. There is no persisted state to migrate.
