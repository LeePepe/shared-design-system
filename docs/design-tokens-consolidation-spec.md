# Design-token consolidation specification

Status: proposed for independent exact-revision architecture/spec review

Issue: `MY-1890` / `01a14897-f934-7406-8e14-a240baa0a75d`

Target baseline: `LeePepe/shared-design-system@ad63bf37d3045349c50e724e0573a75871ebc896`

Provider baseline: `LeePepe/shared-design-tokens@87bef8fbab5bf67a748815d7ed04d7ae199f760a`
(`v0.2.0`)

Decision: `docs/adr/0001-consolidate-design-tokens-authority.md`

Plan and graph: `docs/design-tokens-consolidation-plan.md` and
`docs/design-tokens-consolidation-tasks.md`

This is repository-native planning. The target has no `.specify` tree, so Spec
Kit is intentionally not introduced. This revision authorizes no product-code
implementation, workflow edit, provider mutation, release, tag, registry
publication, repository settings change, or component follow-on work. Its
implementation graph includes separately reviewed prerequisites, but none may
start until this exact four-document revision passes its gate and is accepted.

## Outcome

After the reviewed migration, `shared-design-system` is the single writable
source repository for platform-neutral design data, deterministic generated
artifacts, the UI-free Swift `DesignTokens` module, and SwiftUI
`NativeDesignKit`. Both existing public products/modules remain available from
one root Swift package, both release-unit contracts are discoverable, and the
old provider repository is retained only for immutable historical resolution
until its separately authorized archive step.

## Terminology

| Term | Meaning |
| --- | --- |
| editable authority | The one reviewed source location where a human may change semantic token/style data. Generated files and historical repositories are not editable authorities. |
| Tokens layer | Platform-neutral color/style sources and schemas, deterministic generator, JS/TS/CSS/JSON artifacts, npm artifact, Node tests, and the DesignTokens release-unit contract. |
| DesignTokens layer | Foundation-only Swift product/module and its tests/consumer fixture; generated Swift data is produced by Tokens. |
| NativeDesignKit layer | SwiftUI product/module, package tests, runtime fixtures, and its release-unit contract. |
| release unit | A separately described consumer artifact. DesignTokens has npm/data and Swift surfaces; NativeDesignKit has Swift surfaces. A single SwiftPM repository tag versions both root products after consolidation. |
| historical provider | `LeePepe/shared-design-tokens`, including immutable tags and published source history. It remains readable but must cease being a writable development authority. |
| activation | The change that makes the root Swift package's `NativeDesignKit` target depend on its local `DesignTokens` target instead of the old repository URL. |
| review-capacity prerequisite | A separate, protected caller-only PR that raises the complete-diff byte ceiling without changing what is reviewed or how findings block. |
| provider-quiescence prerequisite | A separate ordinary provider PR, after S100 and before S200, that removes normal-delivery permission in exactly three provider support documents while preserving historical resolution and all product bytes. |

## Existing behaviour

- `EB-001`: Target `main` at the fixed baseline publishes only the
  `NativeDesignKit` product and resolves `DesignTokens` from
  `https://github.com/LeePepe/shared-design-tokens.git` at exact `0.2.0` /
  `87bef8fbab5bf67a748815d7ed04d7ae199f760a`.
- `EB-002`: The provider baseline has two enforced layers: `Tokens -> Swift`.
  `tokens/colors.json` and `tokens/styles.json` are its only editable data
  authorities. Its exact generated inventory is ten files: color generator
  outputs `dist/resolved.json`, `dist/index.js`, `dist/index.d.ts`,
  `dist/colors.ts`, `dist/colors.css`, and
  `Sources/DesignTokens/GeneratedColors.swift`; and style generator outputs
  `dist/styles.js`, `dist/styles.d.ts`, `dist/styles.resolved.json`, and
  `Sources/DesignTokens/GeneratedStyles.swift`. All ten must reproduce exactly.
- `EB-003`: The provider exposes `@leepepe/design-tokens` JS/TS/CSS/JSON data
  exports and the Swift product/module `DesignTokens`; its Swift target imports
  Foundation only and declares iOS 15, macOS 12, and watchOS 8.
- `EB-004`: The target exposes `NativeDesignKit` for iOS 15 and macOS 12.
  Explicit theme/brand selection, unchanged provider errors, no fallback table,
  no default theme, no cache, and SwiftUI-only production code are current red
  lines.
- `EB-005`: Accepted Button, Card, and List implementations coexist unchanged on
  the target baseline. Their Strata palettes, solid/glass/fallback semantics,
  APIs, accessibility/interaction boundaries, and exact review evidence remain
  the migration baseline. Button hover, native Tab focus, and focused Space
  activation remain Owner-temporarily deferred with historical failure and
  cause `UNKNOWN`; their strict assertions/history are retained.
- `EB-006`: NativeDesignKit `v0.1.0` at
  `4f7fd4f66cb9091704a57add96b42c0ed2058932` still resolves the old provider URL
  at exact `0.1.1`. The target and provider also have different immutable
  `v0.1.0` commits.
- `EB-007`: The target's normal local/CI entry is `scripts/verify`; required
  GitHub gates are fail-closed current-head checks. Provider and target
  repository governance files are not interchangeable.
- `EB-008`: Target base `.github/workflows/review.yml` supplies no
  `max-diff-bytes`, so pinned shared-ci applies its fail-closed 200,000-byte
  complete-diff default. The complete provider tree evidence is untruncated at
  92 blobs / 591,678 raw bytes; the intended 84-file S100 subset is 581,977 raw
  bytes. Its exact source-path text patch is 614,289 bytes / 17,393 additions;
  the three 22-byte relocated path-header occurrences per file add 5,544 bytes,
  yielding 619,833 bytes before provenance, adaptations, or target contexts.
- `EB-009`: Provider `main` and `v0.2.0` both resolve to the exact provider
  baseline. At that revision, `AGENTS.md` and `docs/constitution.md` permit normal
  reviewed delivery and `README.md` describes the provider data as editable;
  therefore target activation alone cannot durably freeze provider authority.
  The target root `AGENTS.md`, `Package.swift`, and `README.md` likewise still declare
  the external provider dependency and must be reconciled at activation.
- `EB-010`: Target CODEOWNERS protects native governance, Swift manifests, root
  `ai/**`, and architecture/support paths with `@LeePepe`, but lacks relocated
  equivalents for provider-protected Node manifests/locks, `tokens/**`, nested
  `ai/**`, `docs/constitution.md`, `docs/architecture/**`, `scripts/verify`,
  `scripts/ci/**`, and `THIRD_PARTY_NOTICES.md`. A mechanical import without a
  target policy adaptation would silently remove effective Owner routing from
  those important paths.
- `EB-011`: Provider CI has an Ubuntu 24.04 Node/Chrome lane using
  `setup-command: scripts/ci/setup.sh`,
  `test-command: scripts/verify --layer Tokens`, and
  `test-runs-on: ubuntu-24.04`. Target CI instead has its macOS
  `scripts/verify --all` plus exact-public-SHA consumer command, contract audit,
  and workflow lint at shared-ci
  `6e354f476bc53d68f0f09fc231d5cd938466af9c`. The pinned reusable workflow
  already supports the three provider lane inputs and runs setup before every
  selected command lane; preserving both coverages needs no shared-ci change.

## Functional requirements and acceptance

### Authority and architecture

- `AC-AUTH-001`: Exactly one tracked pair of editable semantic data files exists
  in the final target: `Packages/DesignTokens/tokens/colors.json` and
  `Packages/DesignTokens/tokens/styles.json`. The old repository, imported
  generated outputs, caches, fixtures, and native sources are mechanically
  rejected as alternate authorities.
- `AC-AUTH-002`: After S100 actually merges, a distinct provider-quiescence PR
  based on the exact provider baseline changes only `AGENTS.md`,
  `docs/constitution.md`, and `README.md`. It removes ordinary provider delivery,
  identifies the target as the future authority, and tells future adopters to
  use the target's version-matched migration contract only after activation; it
  does not claim an exact target SHA or public route before S200/T260. It
  preserves old exact pins, tags, releases, URL resolution, APIs, data, and
  generated bytes. That exact-head-reviewed, Owner-approved, required-CI PR must
  actually merge and read back before S200 starts. S200 then atomically makes the
  target authoritative by reconciling its executable package resolution with its
  root `AGENTS.md`, architecture, README, and AI contracts. D400 archive is only
  separately authorized settings enforcement; it neither delays the transfer nor
  changes historical clone/tag/release availability.
- `AC-LAYER-001`: The root and leaf tech-contexts declare exactly three code
  layers with an acyclic direction: `Tokens -> DesignTokens -> NativeDesignKit`.
  Every imported/changed path resolves to one layer or a reasoned support area;
  the context audit reports no gaps, overlaps, reverse edges, or cycles.
- `AC-LAYER-002`: Actual language/build seams match the declaration:
  `DesignTokens` imports no SwiftUI/UIKit/AppKit, `NativeDesignKit` imports the
  local `DesignTokens` target, and token/generator code imports no component
  source. Static import checks plus build/consumer tests prove the boundary.
- `AC-GEN-001`: Source schemas, units, and provenance remain versioned.
  Generation from the two editable authorities deterministically reproduces the
  exact ten-file inventory named by `EB-002` (six color outputs and four style
  outputs), and the gate reports `Checked 10 outputs`. Editing any generated
  output, omitting a file, or introducing drift fails `scripts/verify --all`.

### Public products and behaviour

- `AC-SWIFT-001`: The root `Package.swift` publishes stable products/modules
  named `DesignTokens` and `NativeDesignKit` and declares iOS 15, macOS 12, and
  watchOS 8 at package level. A DesignTokens-only watchOS consumer builds. A
  tracked NativeDesignKit platform guard makes selecting that product for
  watchOS fail with a stable unavailable diagnostic, while its iOS/macOS build
  and API remain unchanged; consolidation does not create a watchOS component
  implementation.
- `AC-SWIFT-002`: Public DesignTokens color/style types, IDs, lookup behavior,
  explicit themes, encoded-sRGB/alpha semantics, Sendable immutable data, and
  exact error cases match provider `v0.2.0`. Unknown IDs/modes/references and
  invalid values continue to fail closed without aliases or fallback.
- `AC-NATIVE-001`: NativeDesignKit public APIs and accepted Button/Card/List
  source bytes and behavior remain unchanged unless a migration-only import-path
  adaptation is required. The only additive production-source exception is the
  exact T215 watchOS platform guard required by `AC-SWIFT-001`; any other byte
  change outside manifests/contracts/tests is a blocking scope error and needs a
  new reviewed product decision.
- `AC-NATIVE-002`: Five Strata palettes, light/dark, Solid, Glass, Reduce
  Transparency fallback, one-outer-blur composition, provider error propagation,
  explicit theme selection, and no local palette/default/fallback/cache continue
  to pass the existing package and runtime assertions.
- `AC-NATIVE-003`: The deferred Button hover/Tab/Space evidence remains
  `FAILED`, cause `UNKNOWN`, Owner-temporarily-deferred. Migration does not rerun
  the unchanged diagnosis, delete/weaken/skip its strict assertions, or report a
  pass.
- `AC-WEB-001`: Packing from `Packages/DesignTokens` retains npm name
  `@leepepe/design-tokens`, private publication status, zero runtime
  dependencies, existing JS/TS/CSS/JSON export shapes, licenses/attribution, and
  exact fail-closed consumer behavior. No npm registry publication occurs.

### Contracts, verification, and consumers

- `AC-REVIEW-001`: Before S100 is dispatched or published, one small protected
  PR, based on the actual P001 merge whose four planning blobs match their
  reviewed identities, changes only `.github/workflows/review.yml` to pass
  `max-diff-bytes: 1000000` to the existing pinned reusable review. It receives
  ordinary exact-head independent review, delegated Owner approval, required
  CI, and an actual merge readback. The shared-ci source/SHA, trusted-base
  `rules-file`, review prompt/verdict rules, critical/high blocking,
  Owner-decision handling, complete untruncated diff, 25-minute reusable timeout,
  2-minute `codex-review-gate`, and every other caller field remain unchanged.
  Before S100 publication, its frozen complete three-dot diff is measured by the
  review gate's byte semantics and must be at most 1,000,000 bytes; overflow
  blocks and returns for replanning, never source splitting, truncation, or
  generated-data omission.
- `AC-CONTRACT-001`: Root `ai/` remains the NativeDesignKit contract entry and
  deterministically points to `Packages/DesignTokens/ai/` for the DesignTokens
  release unit. Each registry/checker validates its own manifest, version,
  surfaces, examples, compatibility, migration, and changelog paths; a missing,
  stale, or cross-wired contract fails.
- `AC-VERIFY-001`: `.githooks/pre-push` and `scripts/verify` retain the normal
  fail-closed local entry. Before push, `scripts/verify --all` runs
  contract/workflow audits, every Tokens/DesignTokens/NativeDesignKit local gate,
  generation checks, and packed-artifact consumers without claiming public
  resolution. The normal hook-protected push makes the candidate SHA fetchable;
  only then does the existing required CI companion command resolve that exact
  public SHA before delivery. No path/mirror substitute, hook bypass, required
  gate, assertion, policy, or effective protection is removed or weakened.
  During S100, target `.github/CODEOWNERS` retains every baseline pattern and
  Owner and adds relocated `@LeePepe` coverage for
  `/Packages/DesignTokens/**/package.json`,
  `/Packages/DesignTokens/**/package-lock.json`,
  `/Packages/DesignTokens/tokens/**`, nested `/Packages/DesignTokens/ai/**`,
  `/Packages/DesignTokens/docs/constitution.md`,
  `/Packages/DesignTokens/docs/architecture/**`,
  `/Packages/DesignTokens/scripts/verify`,
  `/Packages/DesignTokens/scripts/ci/**`, and
  `/Packages/DesignTokens/THIRD_PARTY_NOTICES.md`; a trusted resolver proves
  representative imported paths and existing native paths resolve to the same
  Owner. S100 also retains the target CI caller's events, permissions,
  concurrency, macOS verify/public-consumer command, contract/workflow audits,
  45-minute timeout, aggregate behavior, and exact shared-ci pin while adding
  the real Ubuntu 24.04 `scripts/verify --layer Tokens` lane and a target-owned
  setup wrapper that installs checksum-pinned Node 22.23.3 and the nested exact
  npm lock. Only nested `node_modules` and tarball outputs are newly ignored;
  generated data, `dist/**`, sources, manifests, and locks remain tracked and
  verified. `.github/workflows/review.yml` remains outside S100.
- `AC-CONSUMER-001`: An isolated Node consumer installs the actual packed nested
  DesignTokens artifact and exercises all declared public exports with matching
  shipped docs. An isolated Swift consumer resolves the public target repository
  at the exact pushed revision, imports both `DesignTokens` and
  `NativeDesignKit`, and proves that NativeDesignKit resolves through the local
  target with no old-repository package in `Package.resolved`.
- `AC-CONSUMER-002`: Revision-mode public resolution uses no path dependency,
  source copying, local mirror substitution, package mirror, or unpushed SHA.
  Receipts record repository URL, exact revision, package identities, products,
  contract paths, commands, exits, and test counts.
- `AC-EVIDENCE-001`: Every implementation candidate reconciles clean local HEAD,
  pushed branch, PR `headRefOid`, provider provenance, generated-artifact hashes,
  independent review, and current-head required checks. A new SHA invalidates
  earlier review/check evidence. Any reconciliation or post-push repair that
  changes bytes restarts local verification, freeze, exact-head review, push,
  public-SHA CI, and evidence collection from the new head.

### History, compatibility, retirement, and rollback

- `AC-HISTORY-001`: An imported provenance manifest records the provider URL,
  exact `v0.2.0` commit, source path -> target path mapping, Git blob or SHA-256
  identity, licenses/attribution, and exclusions. It does not self-reference the
  commit that contains it. After the immutable target import head exists, a
  durable external PR/merge receipt records the reviewed PR-head SHA, PR number,
  final merge/squash SHA, and unchanged provenance-manifest blob, binding both
  commit identities to the same imported mapping. A squash may change commit and
  tree identity but not the recorded manifest blob/path mappings; no later
  tracked manifest edit is made. Rewritten/copied files do not retain provider
  Git commit identity.
- `AC-HISTORY-002`: Tag mapping is explicit and immutable:
  `shared-design-system/v0.1.0` remains NativeDesignKit history;
  `shared-design-tokens/v0.1.0`, `v0.1.1`, and `v0.2.0` remain provider history;
  none is moved, overwritten, or recreated in the other repository. The first
  consolidated tag is a separately authorized shared Swift-package version;
  `v0.3.0` is the recommended candidate, not an action authorized here.
- `AC-COMPAT-001`: Source imports and public product/module names remain stable.
  Consumer migration documents the required manifest-only change from provider
  URL/package identity `shared-design-tokens` to target URL/package identity
  `shared-design-system`, with exact revision evidence before any tag.
- `AC-COMPAT-002`: Published NativeDesignKit `v0.1.0` continues to resolve exact
  provider `0.1.1` from the old URL. Preserving that historical route is a hard
  retirement precondition, not evidence that the old repository remains an
  active authority.
- `AC-RETIRE-001`: Consumer discovery records known self-references, GitHub
  dependency/code-search results, release/package manifests, and their explicit
  limitations. Zero search matches never proves zero consumers.
- `AC-RETIRE-002`: Before any settings mutation, Root receives one concrete
  retirement packet that cites the already-merged provider quiescence/README
  notice, recommends publishing/adopting the consolidated revision or authorized
  release and migrating known consumers, proves all commits/tags/releases remain
  resolvable, and then offers archive/read-only settings as a separate choice.
  Delete, rename, transfer, tag rewrite, force-push, and live mirroring are
  rejected. Archive remains an explicit Owner settings decision.
- `AC-ROLLBACK-001`: Before P175, rollback is removal of the inert staged import.
  If Root abandons activation after P175 but before S200, a separate ordinary
  provider PR first restores exactly the three recorded pre-P175 blobs, with
  exact-head review, CODEOWNERS/delegated Owner approval, required CI, merge, and
  readback; only then may the target remove the inert S100 import. After
  activation but before a consolidated release, rollback restores the target
  manifest/lock and contracts to exact provider `0.2.0` while preserving the
  provider quiescence decision unless Root separately authorizes its exact
  three-blob restore. After an authorized release, consumers restore their
  recorded old URL/version or prior target revision and rerun the same external
  checks. Rollback never edits a generated artifact alone, rewrites a tag,
  bypasses review, or silently changes token behavior.

### Scope

- `AC-SCOPE-001`: No React or Android component implementation, no new SwiftUI
  component, no visual redesign, no business/product adoption, no platform-floor
  increase, and no Native/npm publication is part of consolidation.
- `AC-SCOPE-002`: The already authorized TextField, Switch, Checkbox, Select,
  Tabs, and Accordion component tasks remain separate future work. This planning
  package neither starts nor changes their writers, contracts, or visual-review
  requirements.

## Compatibility

### Preserved without consumer source changes

- Swift module imports: `import DesignTokens`, `import NativeDesignKit`.
- Public product/module names and provider/native public symbols.
- Token/style identifiers, units, values, errors, palette meanings, explicit
  mode/brand selection, and no-fallback semantics.
- NativeDesignKit iOS/macOS floors and DesignTokens data-only watchOS floor.
- Node package name, runtime exports, private registry status, license, and
  third-party attribution.
- Accepted NativeDesignKit component APIs, visual semantics, and test history.

### Deliberate compatibility migration

Swift consumers that directly declare DesignTokens must replace the old package
URL and package identity with the target repository/identity when adopting the
consolidated revision. This is a manifest-resolution migration, not a public
Swift source rename. Consumers may remain on immutable old tags until they are
ready; no floating redirect or runtime alias is introduced.

The root and nested AI-contract locations become an explicit two-release-unit
discovery scheme. Version-matched docs remain mandatory; a root floating copy
may not substitute for a resolved artifact's contract.

The prerequisite caller change raises only complete-review capacity. It does not
change any package, runtime, consumer, review rule, severity, timeout, shared-ci
pin, required check, or repository setting. It starts only after the separate
planning-only P001 PR passes required checks and delegated Owner approval,
actually merges, and the merged four artifact blobs are read back byte-identical
to the reviewed revision.

S100 deliberately adapts target support policy without importing provider
governance. CODEOWNERS retains every target baseline rule/Owner and adds only
the relocated provider important-path equivalents. The target CI caller retains
its native macOS/UI/public-consumer coverage and adds the provider's real Ubuntu
24.04 Tokens lane using fields already supported by the exact shared-ci pin. A
target `scripts/ci/setup.sh` enters the nested package and invokes the exact
imported provider setup, preserving its Node 22.23.3 platform/hash matrix and
locked `npm ci` flags; `.gitignore` adds only anchored nested `node_modules/`
and `*.tgz` outputs. These protected changes receive the same S100 exact-head
review, delegated Owner approval, required checks, and actual merge readback.

After S100, the provider-quiescence prerequisite changes only provider
`AGENTS.md`, `docs/constitution.md`, and `README.md`. It removes permission for
future provider development and identifies the target as the future authority.
It tells adopters to follow a version-matched target `ai/MIGRATION.md` only after
activation; P175 neither names nor claims an exact target SHA/public route. Old
exact pins, public APIs/data, generated bytes, tags, releases, and URL resolution
remain unchanged.
It does not edit the provider `ai/**` v0.2 contract or any source, manifest, gate,
shared-ci pin `42d1704a5690ab5890657feaadb8929384632766`, ruleset,
setting, credential, release, tag, archive state, or repository identity.

## Removed or superseded behaviour

Removed released runtime behaviour: **none**.

The following configuration is deliberately removed at activation, under
ADR-0001 and `AC-COMPAT-001`:

- NativeDesignKit's remote exact `shared-design-tokens` dependency and resolved
  package entry, replaced by the local `DesignTokens` target.
- The provider repository's permission for ordinary development, removed by the
  merged provider-quiescence prerequisite before S200. S200 then activates the
  target authority and removes the target's executable and documented external
  dependency. D400 may enforce read-only archive settings later, while historical
  clone/tag/release availability remains unchanged.

Removed, skipped, weakened, or relabelled tests/assertions/policies: **none**.
Generated outputs may move mechanically but remain byte/provenance checked.
The reusable review's 200,000-byte default is superseded only by the target
caller's evidence-bound 1,000,000-byte input; complete-diff and fail-closed
semantics are preserved.

## Non-goals

- Publishing or tagging `v0.3.0`, publishing to npm, or changing release
  credentials.
- Any provider mutation beyond the exact three support documents in the separate
  quiescence prerequisite; archiving/deleting/renaming/transferring either
  repository; or changing GitHub rulesets/settings.
- Editing shared-ci source or pin, review rules/severities/timeouts, credentials,
  `codex-review-gate`, or any `.github/workflows/review.yml` caller field other
  than P050's `max-diff-bytes`; removing or weakening any existing target CI
  caller field. S100's additive setup/Linux Tokens inputs are the only authorized
  `.github/workflows/ci.yml` adaptation.
- Reconstructing provider Git history inside the target or importing colliding
  tags.
- Changing Basalt Web authority, design values, component anatomy, state,
  interaction, accessibility, or visual evidence.
- Claiming search completeness, minimum-OS runtime validation, VoiceOver,
  physical-device coverage, or resolution from an artifact that was not tested.

## Spec acceptance gate

This package is implementation-ready only when an independent AI Reviewer
returns `PASS` for the exact commit and four artifact blobs, with no unresolved
architecture/spec finding. Team Lead must then accept that exact revision before
any implementation task is dispatched. Any byte change requires a new review.
