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

Import `NativeDesignKit` and `DesignTokens`; call
`try NativeTokenColor.resolve(id, theme: theme)` with an explicit `Theme`.
The fixture's `SamplePalette` implements this using public imports only.
Never use `@testable import` in a consumer.

Resolve again when the theme changes. Handle `TokenError.unknownToken(id)` at
the consumer boundary according to the product's policy. The library does not
supply a fallback, cache, default theme or business-series binding.

## Verify and uninstall

Run the exact-version external consumer command in [EXAMPLES.md](EXAMPLES.md).
Its tests resolve every public ID in both themes and verify exact unknown-ID
errors. iOS build evidence and a visual demo are separate checks; compiling a
color bridge is not visual, accessibility or minimum-OS acceptance.

To uninstall, remove the consumer adapter calls and the `NativeDesignKit`
product/package dependency, then re-resolve and build/test the consumer. Keep
the direct Tokens dependency if the consumer still uses it. No library-owned
storage, tasks, registration or credentials need cleaning up.
