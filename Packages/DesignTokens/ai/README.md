# DesignTokens contract

Version `0.2.0` release contract of `@leepepe/design-tokens` (not published to
the npm registry) and the stable Swift product/module `DesignTokens`. New Swift
consumers resolve it from
`https://github.com/LeePepe/shared-design-system.git` using package identity
`shared-design-system` at an exact reviewed revision. Historical provider tags
remain immutable at the old URL.

| Task | Read next | Completion criterion |
|---|---|---|
| Install or uninstall | [Integration](INTEGRATION.md) | Exact artifact/revision identified, matching docs checked, data example passes |
| Implement data consumption | [Usage](USAGE.md), then the needed entry in [registry](registry.json) | Public API only; explicit theme and consumer-owned series bindings |
| Run an example | [Examples](EXAMPLES.md) | Selected executable fixture exits zero |
| Upgrade or migrate | [Compatibility](COMPATIBILITY.md), [migration](MIGRATION.md), [changelog](../CHANGELOG.md) | Version, behavior and rollback verified together |
| Diagnose contract or lookup failure | [Failure repair](INTEGRATION.md#contract-failures), [errors](USAGE.md#errors) | Underlying defect fixed; same pinned input passes without fallback |

These documents travel with the artifact; read them from the actual npm
installation or `Packages/DesignTokens/ai/` in the resolved
`shared-design-system` checkout, not a floating branch. [Constitution](../docs/constitution.md)
owns data invariants. [Checker scope](../docs/ai-checker.md) defines bounded
integrity checks, not public policy.

Version 0.2.0 includes [style foundations](USAGE.md#style-foundations-020) and
[five explicit Strata color families](USAGE.md#strata-colors-020), while preserving
all previously released color values and APIs. Release notes establish immutable
tag availability, exact commit, artifact digest and external consumer evidence.
