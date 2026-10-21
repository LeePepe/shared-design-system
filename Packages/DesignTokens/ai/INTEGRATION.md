# Integration

## npm artifact

Prerequisites: Node >=22, npm, and the release tarball built from tag `v0.2.0` (`npm pack` in a checkout of that tag) plus its SHA-256 from the release notes. There is no npm registry publication. Verify its digest against the handoff before installing; a matching version string alone does not authenticate bytes. The runtime has no dependencies, permissions or install hooks. Development-only checker and TS execution require exact Ajv 8.17.1 and TypeScript 5.9.3.

Commands below are executable recipes after replacing `<release.tgz>` with that verified local file; they are not registry-publication instructions. Start in an empty disposable consumer directory:

```sh
npm init -y
npm install --ignore-scripts --no-audit --no-fund --save-exact /path/to/<release.tgz>
npm install --ignore-scripts --no-audit --no-fund --save-dev --save-exact ajv@8.17.1 typescript@5.9.3
node node_modules/@leepepe/design-tokens/scripts/check-ai-contract.mjs --root node_modules/@leepepe/design-tokens --expected-name @leepepe/design-tokens --expected-version 0.2.0
node node_modules/@leepepe/design-tokens/examples/data/usage.mjs
node node_modules/@leepepe/design-tokens/examples/data/migration.mjs
node node_modules/typescript/bin/tsc --strict --target ES2022 --module NodeNext --moduleResolution NodeNext --outDir node_modules/@leepepe/design-tokens/examples/data/compiled node_modules/@leepepe/design-tokens/examples/data/usage.ts
node node_modules/@leepepe/design-tokens/examples/data/compiled/usage.js
```

Expect checker JSON `ok: true`, no errors, exit 0; each fixture prints PASS. Locate the entry at `node_modules/@leepepe/design-tokens/ai/README.md` and cross-check the installed manifest/registry version against your lockfile. Keep the original installed contract unchanged; emitted JS is a disposable build output. In a real TS project, copy the fixture into the consumer's source tree and compile with its own pinned toolchain.

Uninstall: first remove imports, scoped CSS references and dependent code, then `npm uninstall @leepepe/design-tokens`; verify the consumer build and lockfile. Rollback is [explicit](MIGRATION.md), not a change to generated provider files.

## Web style CSS

The package includes the theme-independent style data asset
`@leepepe/design-tokens/styles.css`. Import it when a web adapter needs the
generated `--lp-spacing-*`, `--lp-radius-*`, `--lp-dimension-*`, or typography
custom properties:

```css
@import '@leepepe/design-tokens/styles.css';
```

The asset contains no Tailwind configuration and does not establish a default
theme. Consumers choose where to apply the namespaced variables.

## Swift revision

Swift tools 6.0+; public product/module `DesignTokens`. Pin the consolidated
repository at a reviewed full revision, never a branch or range:

```swift
.package(
    url: "https://github.com/LeePepe/shared-design-system.git",
    revision: "<40-character SHA>"
)
.product(name: "DesignTokens", package: "shared-design-system")
```

The root package also publishes `NativeDesignKit`, which depends on this local
target. DesignTokens alone supports watchOS 8; NativeDesignKit is unavailable on
watchOS. Before publication, the repository verifies the same public imports
through a local-path consumer without claiming public resolution. Required CI
after push owns exact-public-revision resolution.

Read `Packages/DesignTokens/ai/README.md` from the actual resolved checkout.
Remove the product and containing package dependency to uninstall, then resolve
and build again. Historical consumers may stay on immutable old provider tags
until they perform the manifest-only migration in [MIGRATION.md](MIGRATION.md).

## Contract failures

The [checker](../scripts/check-ai-contract.mjs) is a development tool; run it with Ajv available, separately from runtime consumption. The installed fixture proves it and all its inspected inputs are available without a provider source checkout. It emits `{ok, errors: [{id, path, message, repair}]}` and exit 1 on contract failure; use the diagnostic path and restore the exact reviewed artifact before retrying.

| Stable ID family | Repair |
|---|---|
| `AI_INPUT`, `AI_ROOT` | Supply an available root and explicit exact name/version |
| `AI_FILE_MISSING`, `AI_JSON`, `AI_JSON_SHAPE` | Restore readable, valid object-root JSON/prerequisites |
| `AI_PACKAGE_IDENTITY`, `AI_VERSION_MISMATCH` | Reconcile lockfile, manifest and registry; never fall back to latest |
| `AI_REGISTRY_SCHEMA`, `AI_SCHEMA_DRIFT`, `AI_TOKEN_SCHEMA` | Use this checker/schema version and compatible token schema |
| `AI_DOC_LINK`, `AI_DOC_ANCHOR`, `AI_DOC_EMPTY`, `AI_DOC_SYNTAX` | Restore portable inline links, headings and nonempty docs in the artifact |
| `AI_EXAMPLE_MISSING`, `AI_EXAMPLE_DUPLICATE` | Restore unique, runnable example entries |
| `AI_API_MISSING`, `AI_API_DRIFT`, `AI_API_SYMBOLS`, `AI_API_DUPLICATE` | Review actual API/docs, compile consumers, then explicitly update fingerprints if approved |
| `AI_EXPORT_SHAPE`, `AI_EXPORT_UNREGISTERED`, `AI_SWIFT_PRODUCT` | Restore declared public exports/product and corresponding surfaces |

Invalid color values/IDs and generation drift are tested by the existing source/runtime suites, not a general schema validator inside this checker. Unknown policy fields are rejected, but that is not Owner exception or rule-downgrade enforcement. Read [bounded checker semantics](../docs/ai-checker.md) before interpreting a pass. Fingerprints and a PR-owned registry are integrity evidence, not a trusted external policy baseline.

## Candidate and release evidence

Version 0.2.0 includes styles and five explicit Strata palettes. The release
notes bind tag, commit, tarball digest and external consumer evidence. Before
the tag exists, source review uses exact-commit candidate harnesses and isolated
local mirrors; that evidence does not establish remote release resolution.
