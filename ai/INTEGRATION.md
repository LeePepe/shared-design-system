# Integration

## Prerequisites and dependency resolution

The package declares Swift tools 6.0, iOS 15, macOS 12 and a watchOS 8 floor for
the data-only DesignTokens product. NativeDesignKit remains iOS/macOS-only. See
the distinction
between declared and tested support in [COMPATIBILITY.md](COMPATIBILITY.md).
There are no credentials, network calls, persistence or runtime permissions.

Pin the NativeDesignKit 0.3.0 release with:

```swift
.package(url: "https://github.com/LeePepe/shared-design-system.git", exact: "0.3.0")
```

Use a reviewed full 40-character commit SHA with `revision:` only when
evaluating unreleased future revisions, not as the release dependency.

The executable fixture in [EXAMPLES.md](EXAMPLES.md) shows a complete manifest.
Consumers that name `Theme` or `TokenError` declare both products from the same
package dependency:

```swift
.product(name: "NativeDesignKit", package: "shared-design-system"),
.product(name: "DesignTokens", package: "shared-design-system")
```

The library does not re-export Tokens types. NativeDesignKit 0.3.0 uses the
repository-local DesignTokens target. Historical NativeDesignKit 0.1.0 retains
its old exact provider route.

## Consumer design contract

When adopting the package in a product repository, create
`docs/design-contract.md` from the
[consumer design contract template](DESIGN-CONTRACT.md). Pin the exact
`shared-design-system` revision or release used by the product, bind brand and
business semantics to upstream tokens, and record the product's page structure,
required `populated`/`empty`/`loading`/`error` states, and `light`/`dark`
coverage. Keep the file thin: do not copy the upstream token table or create
replacement base components.

Run the shared-ci `design_contract.py` static check and its snapshot/screenshot
acceptance command from the consumer repository. Store the resulting
light/dark, four-state evidence with the CI artifacts and review it against
the Designer's `design.md`.

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
product dependency, then re-resolve and build/test the consumer. Keep the same
package dependency while the consumer still uses `DesignTokens`. No library-owned
storage, tasks, registration or credentials need cleaning up.
