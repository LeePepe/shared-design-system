# StrataAvatar (unreleased)

Part of the unreleased [Strata rebuild](../COMPONENTS.md); absent from the
Strata 0.3.0 release. This is native SwiftUI with no networking,
identity model, initials derivation or image loader.

```swift
public enum StrataAvatarSize: Equatable, Sendable {
    case small, medium, large
}

public struct StrataAvatar<Content: View>: View {
    public init(theme: StrataTheme,
                size: StrataAvatarSize,
                accessibilityLabel: Text,
                @ViewBuilder content: () -> Content)
}
```

All arguments are required. Small, medium and large have fixed circular
visual bounds of 32, 44 and 64 points. The surface and inherited foreground
come from the explicit theme. There is no material layer or animation, so
Reduce Transparency and Reduce Motion require no alternate rendering path.
Theme construction and its unchanged provider errors follow the
[shared theme contract](../COMPONENTS.md#explicit-theme).

```swift
import DesignTokens
import Strata
import SwiftUI

let theme = try StrataTheme(theme: .light, brand: "ocean")
let initials = StrataAvatar(theme: theme, size: .medium,
                            accessibilityLabel: Text("Example member")) {
    Text("AB")
}
let symbol = StrataAvatar(theme: theme, size: .small,
                          accessibilityLabel: Text("Example group")) {
    Image(systemName: "person.2.fill")
}

// A caller-owned local Image; loading and error policy stay in the consumer.
func picture(_ image: Image, theme: StrataTheme) -> some View {
    StrataAvatar(theme: theme, size: .large,
                 accessibilityLabel: Text("Example member")) {
        image.resizable().scaledToFill()
    }
}
```

Use `resizable().scaledToFill()` to fill the circle with intentional cropping.
`resizable().scaledToFit()` preserves the image's aspect ratio inside the square
visual bounds, leaving the token surface visible where the image does not fill
them. The circular mask still crops any corners outside the circle; add caller
padding when the entire rectangular image must remain visible. An unresized
image retains its intrinsic size and may be cropped. The component clips only
its visual content to the circle. Place
ordinary names, descriptions and long text beside the avatar, outside its
builder. Supply concise visual initials yourself. The inherited font uses
system semantic styles; a one-line visual may shrink to half size and remains
bounded by the fixed circle at large accessibility sizes. The full accessible
label remains available independently of that visual.

The avatar exposes one image element with the caller's localized label and
ignores redundant child glyph labels. It has no action, focus, selection,
loading or disabled state. Compose a native Button when needed and give that
control an appropriate action label and at least a 44-point hit region; the
32-point avatar alone is not an interactive target. A disabled environment
does not dim a noninteractive avatar.

XCTest UI screenshots of the SwiftUI fixture app cover ocean/graphite in
light/dark, initials, SF Symbol, a caller-provided local template image with
fit/fill, an empty visual, all three sizes and narrow adjacent long text.
UI assertions check image semantics, labels, fixed size, intentional clipping,
caller-owned Button composition and iOS accessibility text sizes.
These do not establish VoiceOver speech, device behavior, minimum-OS support,
or macOS Dynamic Type scaling. The five Strata colors remain a provider gap.
To roll back, remove these call sites and restore the reviewed package revision;
there is no stored state to migrate.
