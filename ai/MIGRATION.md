# Migration and rollback

## Consolidated DesignTokens route

For a consumer already using `DesignTokens` 0.2.0, preserve every source import
and API call. Replace the `shared-design-tokens` URL/package identity with
`shared-design-system` at a reviewed exact revision and select the stable
`DesignTokens` product from that package. NativeDesignKit and DesignTokens then
resolve from one package graph.

Before an authorized consolidated release, rollback restores the recorded old
URL, exact 0.2.0 requirement and lockfile together. Historical provider tags and
NativeDesignKit 0.1.0 remain immutable. Re-run the same consumer behavior/error
tests; never copy token values or use a local path/mirror as public evidence.

## Local bridge → NativeDesignKit 0.3.0

NativeDesignKit 0.1.0 is the earlier historical release. The supported 0.3.0
interface remains a color-only bridge; this is not a migration of components,
typography, spacing or Web styles. No existing product adoption is claimed.

1. Record the old consumer revision and its color/theme behavior. Identify
   explicit Tokens IDs; do not invent mappings from unreviewed local colors.
2. Pin NativeDesignKit at exact `0.3.0` as described in [INTEGRATION.md](INTEGRATION.md).
3. Replace only the consumer's native color conversion with
   `NativeTokenColor.resolve(_:theme:)`. Preserve the consumer's theme selection,
   error handling, consent/behavior and business ID-to-series bindings.
4. Resolve every used ID in both themes. Confirm encoded sRGB byte conversion
   and unmodified alpha. Run consumer build/tests and compare the real UI in
   each supported theme/platform. Owner style approval is a separate gate.
5. To roll back, revert the consumer pin/adapter PR to the recorded prior
   revision and re-run the same tests/UI checks.

This library has no persisted state, schema migration or network side effects.
Reverting the pin has no library-owned data conversion to undo. The external
fixture tests public API behavior, not any product's migration or rollback;
those results belong to each consumer PR. Never remove an immutable release tag.

## Earlier candidate revision → 0.3.0

If the consumer pinned a pre-release SHA, record that SHA before replacing
the revision requirement with exact `0.3.0`. Resolve again, confirm the tag's
commit in `Package.resolved`, and run the version-mode fixture from
[EXAMPLES.md](EXAMPLES.md). To roll back, restore the recorded SHA and re-run
consumer tests/UI checks. A source-compatible tag does not waive consumer tests.
