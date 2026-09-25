# Integration

## Prerequisites and dependency resolution

The package declares Swift tools 6.0, iOS 15 and macOS 12. See the distinction
between declared and tested support in [COMPATIBILITY.md](COMPATIBILITY.md).
There are no credentials, network calls, persistence or runtime permissions.

No release tag exists yet. For candidate evaluation, use a reviewed full commit
SHA. After an approved `v0.1.0` release, the dependency declaration becomes
`.package(url: "https://github.com/LeePepe/shared-design-system.git", exact: "0.1.0")`.
That declaration is a release-time instruction, not a claim of publication.

The executable fixture in [EXAMPLES.md](EXAMPLES.md) shows a complete manifest.
Consumers that name `Theme` or `TokenError` also declare the `DesignTokens`
product from `shared-design-tokens`, at exact `0.1.0`. The library does not
re-export those types. Keep `Package.resolved` under consumer policy and confirm
the Tokens revision is `3a6d70f3ff2e01148ea303ea9219e08e877ca76c`.

## Minimal wiring

Import `NativeDesignKit` and `DesignTokens`; call
`try NativeTokenColor.resolve(id, theme: theme)` with an explicit `Theme`.
The fixture's `SamplePalette` implements this using public imports only.
Never use `@testable import` in a consumer.

Resolve again when the theme changes. Handle `TokenError.unknownToken(id)` at
the consumer boundary according to the product's policy. The library does not
supply a fallback, cache, default theme or business-series binding.

## Verify and uninstall

Run the revision-bound external consumer command in [EXAMPLES.md](EXAMPLES.md).
Its tests resolve every public ID in both themes and verify exact unknown-ID
errors. iOS build evidence and a visual demo are separate checks; compiling a
color bridge is not visual, accessibility or minimum-OS acceptance.

To uninstall, remove the consumer adapter calls and the `NativeDesignKit`
product/package dependency, then re-resolve and build/test the consumer. Keep
the direct Tokens dependency if the consumer still uses it. No library-owned
storage, tasks, registration or credentials need cleaning up.
