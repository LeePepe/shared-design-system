# Integration

## Prerequisites and dependency resolution

The package declares Swift tools 6.0, iOS 15 and macOS 12. See the distinction
between declared and tested support in [COMPATIBILITY.md](COMPATIBILITY.md).
There are no credentials, network calls, persistence or runtime permissions.

Pin the NativeDesignKit 0.1.0 release with:

```swift
.package(url: "https://github.com/LeePepe/shared-design-system.git", exact: "0.1.0")
```

Use a reviewed full 40-character commit SHA with `revision:` only when
evaluating unreleased future revisions, not as the release dependency.

The executable fixture in [EXAMPLES.md](EXAMPLES.md) shows a complete manifest.
Consumers that name `Theme` or `TokenError` also declare the `DesignTokens`
product from `shared-design-tokens`, at exact `0.1.1`. The library does not
re-export those types. Keep `Package.resolved` under consumer policy and confirm
the Tokens revision is `234b7d0b058474f1aa3f0edeab1be6084ad7eca5`.

## Minimal wiring

### Released 0.1.0 (Color bridge only)
When consuming the released 0.1.0 tag, import `NativeDesignKit` and `DesignTokens`, and call `try NativeTokenColor.resolve(id, theme: selectedTheme)` with an explicit `DesignTokens.Theme`:

```swift
import DesignTokens
import NativeDesignKit
import SwiftUI

let color = try NativeTokenColor.resolve("product.surface.raised", theme: selectedTheme)
```

### Unreleased 0.2.0 candidate (Theme seam & Components)
When evaluating the unreleased 0.2.0 candidate revision, construct an explicit `NativeDesignTheme` and pass it to presentation primitives:

```swift
import DesignTokens
import NativeDesignKit
import SwiftUI

let theme = try NativeDesignTheme(theme: selectedTheme)
let card = NativeCard(theme: theme) {
    Text("Card Content")
}
```

Construct a new `NativeDesignTheme` (or re-resolve direct colors with `selectedTheme`) when the theme changes. Handle `TokenError` at the consumer boundary according to product policy. The library does not supply a fallback, cache, default theme or business-series binding.

## Verify and uninstall

Run the exact-version external consumer command in [EXAMPLES.md](EXAMPLES.md).
Its tests resolve every public ID in both themes and verify exact unknown-ID
errors. iOS build evidence and a visual demo are separate checks; compiling a
color bridge is not visual, accessibility or minimum-OS acceptance.

To uninstall, remove the consumer adapter calls and the `NativeDesignKit`
product/package dependency, then re-resolve and build/test the consumer. Keep
the direct Tokens dependency if the consumer still uses it. No library-owned
storage, tasks, registration or credentials need cleaning up.
