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
            Button { /* Caller-owned action. */ } label: {
                Text("Continue").frame(minHeight: 44)
            }
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
`DesignTokens` product dependency at exact `0.2.0`; NativeDesignKit does not
re-export Tokens. Theme resolution errors propagate unchanged before rendering.
The candidate provider adds explicit `strata-blue`, `strata-green`,
`strata-pink`, `strata-yellow` and `strata-purple` brands; `ocean` and `graphite`
remain supported. The five families are independently resolved provider colors.
Until the provider version is published, candidate-only local evidence does not
establish remote dependency or release acceptance.

The header uses `.headline` and a heading accessibility trait. Content uses
`.body`; supporting content uses `.subheadline` and `secondaryForeground` on
both Glass and solid, including the system Reduce Transparency fallback. The
dense `.card` reading role provides the background for that hierarchy. Actions
inherit `.body` and the brand accent. Callers may override semantic fonts and
provide their own token-derived foregrounds. There is no fixed text height,
truncation limit, number formatting or localization policy. The stack reads
header → content → supporting → actions and retains descendant controls, focus,
gestures and accessibility. The card adds no tap or selection behavior and no
implicit accessibility activation action.

The card has a continuous 24pt corner radius, 16pt inset and 12pt slot spacing.
Width follows its parent proposal; height grows with its content. Controls
inside `actions` remain caller-owned, including their style and hit area; give
interactive labels at least a 44pt hit region. A
vertical action composition is useful in narrow or accessibility-sized layouts.

`surface: .solid` uses the explicit theme's opaque `.card` surface role.
`.glass` uses the shared dense Card treatment. When nested under a glass region,
it inherits the outer blur rather than creating another material layer; its
inner edge is weaker than the outer shell. System Reduce Transparency selects
the same theme's opaque Card role and removes material decoration while
preserving layout and content. Material selection never changes brand or mode.
The outer page/region composition belongs to the caller, not NativeCard.

The review fixture retains behavior matrices and adds a separate composition
with caller-owned icon plate, context pill, footer/action and an explicitly
synthetic statistics card. Status and chart colors use their own provider
roles; the active brand does not turn a progress series or success state into
brand content. Actual runtime composite contrast checks cover the fixture's
primary, supporting, brand-action and status text. Callers must evaluate other
composited backdrops and foreground overrides. Use a solid card for reading
over imagery or other unverified backdrops. Screenshots do not establish
VoiceOver, minimum-OS or physical-device acceptance.
