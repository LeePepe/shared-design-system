# NativeCard

Unreleased component contract. This Card is a fresh Strata implementation;
its four-slot API supersedes the earlier `NativeCard<Content>` planning shape.
It does not change the released 0.1.0 color resolver or declare a package release.

`NativeCard<Header, Content, Supporting, Actions>` is a SwiftUI container for
caller-owned views. Every type parameter conforms to `View`. The initializer
requires `theme: NativeDesignTheme`, `surface: NativeSurfaceStyle`, and four
`@ViewBuilder` closures labeled `header`, `content`, `supporting`, `actions`.
There is no default theme, brand, material or business data. Use `EmptyView`
for an unused slot.

When only body content is needed, a constrained initializer infers the other
three slots as `EmptyView`:

```swift
NativeCard(theme: theme, surface: .solid) {
    Text("Caller-owned content")
}
```

```swift
import DesignTokens
import NativeDesignKit
import SwiftUI

struct CardExample: View {
    let theme: NativeDesignTheme

    var body: some View {
        NativeCard(theme: theme, surface: .solid) {
            Text("A clear title")
        } content: {
            Text("Caller-owned information wraps naturally.")
        } supporting: {
            Text("Supporting context")
        } actions: {
            Button("Continue") { /* Caller-owned action. */ }
        }
    }
}

// Resolve outside body, with caller-selected values; handle errors at this boundary.
func makeCardExample() throws -> CardExample {
    CardExample(theme: try NativeDesignTheme(theme: .light, brand: "ocean"))
}
```

The [public-import compile fixture](../../Tests/NativeDesignKitTests/Components/NativeCardPublicAPITests.swift)
uses only public API. A consumer that names `Theme` also declares the direct
`DesignTokens` product dependency at exact `0.1.1`; NativeDesignKit does not
re-export Tokens. Theme resolution errors propagate unchanged before rendering.
Only provider brands `ocean` and `graphite` exist in that pin. Five-color Strata
prototypes do not add brands to the provider.

The header uses `.headline` and a heading accessibility trait. Content uses
`.body`; supporting content uses `.subheadline` and the secondary token
foreground. Actions inherit `.body` and the brand accent. Callers may override
semantic fonts and provide their own token-derived foregrounds. There is no
fixed text height, truncation limit, number formatting or localization policy.
The stack reads header → content → supporting → actions and retains descendant
controls, focus, gestures and accessibility. The card adds no tap or selection
behavior and no implicit accessibility activation action.

The card has a continuous 24pt corner radius, 16pt inset and 12pt slot spacing.
Width follows its parent proposal; height grows with its content. Controls
inside `actions` remain caller-owned, including their style and hit area; give
interactive labels at least a 44pt hit region. A
vertical action composition is useful in narrow or accessibility-sized layouts.

`surface: .solid` uses the resolved raised-surface token. `.glass` uses the
shared native SwiftUI material surface with the explicitly selected theme.
System Reduce Transparency selects the same theme's solid surface and preserves
layout and content. It does not change brand or mode. Glass is appropriate for
an outer floating surface; use solid cards for dense nested reading surfaces.
The caller owns the backdrop and must assess contrast against the actual
composited background; a static card API does not constrain arbitrary imagery
behind a material.
