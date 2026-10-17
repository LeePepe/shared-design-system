# Design-token consolidation plan

Status: proposed for independent exact-revision architecture/spec review

Specification: `docs/design-tokens-consolidation-spec.md`

Architecture decision: `docs/adr/0001-consolidate-design-tokens-authority.md`

Dependency graph: `docs/design-tokens-consolidation-tasks.md`

## Planning provenance

| Field | Value |
| --- | --- |
| issue | `MY-1890` / `01a14897-f934-7406-8e14-a240baa0a75d` |
| target | `https://github.com/LeePepe/shared-design-system.git` |
| exact target base | `ad63bf37d3045349c50e724e0573a75871ebc896` |
| immutable review history / successor parent | rounds 1–3 remain `NEEDS_WORK`: `18d3225b24c22523b4d7adc9c54ff28dec783be0`, `20e93ec93a8ab8ecdd20a64d65ceda5da226285e`, and parent `6f08e5bc0cc071883dc22c65072a0197db4cfdcb`; Owner decision `01a148cb-76ec-7bb0-90e9-9572b947a4a8` authorizes this one bounded post-budget successor and one exact-revision gate |
| provider | `https://github.com/LeePepe/shared-design-tokens.git` |
| exact provider import | `87bef8fbab5bf67a748815d7ed04d7ae199f760a` (`v0.2.0`) |
| repository protocol | `shared-ci@6e354f476bc53d68f0f09fc231d5cd938466af9c` |
| review-capacity evidence | external read-only `coordination/consolidation-provider-tree-root-read.json`: complete 92-blob / 591,678-byte tree; planned 84-file / 581,977-byte subset; exact source-path text patch 614,289 bytes / 17,393 additions plus 5,544 bytes for three 22-byte path-prefix occurrences per file = 619,833-byte relocated mechanical patch |
| protection-parity evidence | external read-only `coordination/consolidation-codeowners-parity-root-evidence.json` and `coordination/consolidation-ci-parity-root-evidence.json` at the exact target/provider baselines; Owner directions `01a148c3-1ebf-73b1-bf26-0cd5693dfe58` and `01a148c5-b1c0-7039-b512-4dd52ef6045c` |
| accepted native reference | Strata prototype `b4bff430517ed2e2944f814d8b5ab89a1866ee33`, digest `c41f53160d0eb7e6e39b2733a3a689119a4c0868101c2aa2381b0061f4c6b456` |
| planning method | repository-native ADR/spec/plan/tasks; no Spec Kit installation |

## Architecture

```text
Packages/DesignTokens/tokens/{colors,styles}.json
                 │ validate + deterministic generation
                 ▼
          Tokens layer
  JS / TS / CSS / JSON / npm contract
                 │ generated Swift data
                 ▼
       DesignTokens layer
  Foundation-only Swift product/module
                 │ local target dependency
                 ▼
      NativeDesignKit layer
  SwiftUI product/module and fixtures
```

The external seam is the root Swift package with two stable products and the
nested npm artifact. The internal seam is generated immutable data: Tokens owns
the generator and sources; DesignTokens owns the UI-free Swift interface;
NativeDesignKit owns native presentation. There is no adapter that mirrors or
falls back to the old repository.

### Final path ownership

| Area | Paths | Responsibility | Depends on |
| --- | --- | --- | --- |
| Tokens | `Packages/DesignTokens/tokens/**`, `dist/**`, `ai/**`, `scripts/*.mjs`, `tests/*.mjs`, `tests/consumer/**`, `examples/data/*.{mjs,ts,json}`, `package*.json`, and the two exact generated Swift files | editable visual data, schema, generation, all ten generated outputs, JS/TS/CSS/JSON/npm surfaces and executable release-unit contract | none |
| DesignTokens | non-generated `Packages/DesignTokens/Sources/DesignTokens/**`, Swift tests/examples, nested `Package.swift` | UI-free Swift data interface and exact-error behavior | Tokens |
| NativeDesignKit | existing `Sources/NativeDesignKit/**`, `Tests/**` excluding imported provider tests, root `ai/**` | SwiftUI interface, package tests, actual UI fixtures, native consumer contract | DesignTokens |
| repository support | imported/root metadata `*.md` outside nested `ai/**`, `LICENSE*`, notices, `docs/**`, `specs/**`, provenance manifest; root `Package.swift`/lock, architecture, ADR/spec/plan/tasks, `AGENTS.md`, hooks, workflows, `scripts/verify`, `scripts/ci/**` | metadata/legal/provenance, package integration, path routing, common gates and review | checked as support; manifest/gate changes force the full graph |

Exact glob ownership is finalized in the contract-import PR and must pass the
context audit without hiding executable paths in support.

## Planning decisions

1. **Nest the provider release unit.** `Packages/DesignTokens` avoids manifest,
   license, spec, and `ai/` root collisions and remains a valid npm pack root.
2. **One root Swift graph.** Root `Package.swift` exposes `DesignTokens` and
   `NativeDesignKit`; NativeDesignKit depends on the local target. The nested
   provider manifest remains a provider-local verification/packaging fixture,
   not a second public repository authority.
3. **Expand, quiesce, then activate.** First import and verify the exact provider
   without changing the active native dependency. After S100 merges, land one
   three-document provider PR that removes ordinary provider development while
   preserving historical resolution. Only after that merge/readback may S200
   activate the local target, transfer development authority, and update target
   executable and documented contracts atomically. Finally prove public
   resolution and prepare archive enforcement evidence. No intermediate main
   revision is left broken or falsely authoritative.
4. **Separate mechanical import from behaviour.** Import preserves provider
   bytes except listed root/path adaptations. Activation owns manifest/package
   identity and contract changes. Native component source is inspection-only.
5. **Preserve independent contracts.** Root `ai/` remains NativeDesignKit;
   nested `ai/` remains DesignTokens. Cross-links and checkers prove correct
   version/release-unit discovery rather than merging incompatible registries.
6. **Adopt target governance and preserve provider coverage.** Provider
   `.github`, hooks, root `AGENTS.md`, rulesets, and old shared-ci pin are
   provenance inputs, not imported active governance. S100 minimally adapts the
   target's authoritative CODEOWNERS and CI caller: every native rule/Owner and
   native macOS/UI/public-consumer gate stays; relocated Node manifests/locks,
   token data, nested AI contract, constitution, architecture, verification/CI
   support, and notices gain the same Owner; and a real Ubuntu 24.04 Tokens lane
   runs with nested locked-tool setup. The target pin, aggregate, review gates,
   events, permissions, concurrency, timeouts, and fail-closed semantics remain
   authoritative and unchanged.
7. **Raise capacity before import.** A separate caller-only protected PR passes
   `max-diff-bytes: 1000000` to the existing pinned review. It must pass its own
   exact-head review, delegated Owner approval, required CI, and merge before
   S100. The value covers a measured 619,833-byte relocated mechanical baseline
   with 380,167 bytes of adaptation headroom. The frozen S100 complete diff must
   still fit; overflow blocks and replans. No review content, severity, pin,
   trusted rules, timeout, gate, or fail-closed behavior changes.
8. **Do not import colliding refs.** Provider source provenance is a manifest of
   exact revision, blob/hash mapping, licenses, and exclusions. Old commits/tags
   stay immutable and reachable in the old repository. The manifest never embeds
   its containing commit; an external immutable receipt later binds the target
   import SHA to the manifest blob.
9. **Freeze provider authority through its own contract.** The ordinary provider
   PR changes exactly `AGENTS.md`, `docs/constitution.md`, and `README.md` from
   `87bef8fbab5bf67a748815d7ed04d7ae199f760a`. Exact-head review, CODEOWNERS/
   delegated Owner approval, required CI, PR Manager merge, and three-blob
   readback are mandatory. Product/data/generated bytes, historical tags,
   releases and URL resolution remain unchanged; gates, provider shared-ci pin
   `42d1704a5690ab5890657feaadb8929384632766`, rulesets/settings, credentials,
   releases, tags, archive state, and
   repository identity are out of scope.
10. **Use a unified future Swift version.** The recommended first consolidated
   release candidate is `v0.3.0`; choosing/tagging/releasing it is a later Root
   decision. Exact-revision consumers unblock implementation verification.
11. **Retire safely.** The old repository remains historically readable after
   authority transfers at S200. Its README quiescence notice lands in P175;
   archive/settings enforcement remains a later choice after target delivery,
   consumer migration evidence, and Root authorization. Never delete, rename,
   transfer, rewrite, or mirror.
12. **Preserve current native truth.** Button/Card/List accepted bytes and
    contracts are migration baselines. Button input deferrals remain failed and
    unknown; migration neither retries nor converts them to pass.

## PR slices and dependency order

### `P001` — Planning contract foundation

One docs-only goal: land the independently reviewed ADR/spec/plan/tasks before
implementation. Only the four paths named by `T001` may change. Full target
verification and delegated Owner approval apply because the ADR is protected
architecture. Its normal non-Draft PR, required checks, and actual merge must
complete, and target main must read back the exact four reviewed blob identities,
before P050 starts.

### `P050` — Complete-review capacity prerequisite

Observable goal: the existing target review admits the complete expected S100
diff without changing review semantics. One small governance PR changes only
`.github/workflows/review.yml` to add `max-diff-bytes: 1000000` to the existing
reusable-review call. Its own diff fits the current 200,000-byte default and must
receive exact-head independent review, delegated Owner approval, required CI,
and actual merge readback before S100 begins. Shared-ci, the exact pin, rules,
timeouts, Owner-decision handling, severity behavior, complete-diff admission,
and `codex-review-gate` remain byte/semantically unchanged as applicable.

### `S100` — Exact provider import and local gates

Observable goal: the target contains an inert, exact, provenance-bound
DesignTokens provider release unit under `Packages/DesignTokens`, and its
Tokens/DesignTokens gates pass inside the target without changing root product
resolution.

This slice may perform only mechanical path relocation and the minimum
root-relative harness/context/protection adaptations needed to run and protect
the imported package. The root NativeDesignKit manifest stays byte-identical,
still resolving public exact provider `0.2.0`. Provider active governance files
are excluded. Generated artifacts must match regeneration and the provenance
manifest.

S100 owns four bounded target-support changes. `.github/CODEOWNERS` preserves
every existing native pattern and `@LeePepe`, then adds all-depth
`package.json`/`package-lock.json` coverage scoped to `Packages/DesignTokens/`
and relocated exact coverage for nested `tokens/`,
`ai/`, `docs/constitution.md`, `docs/architecture/`, `scripts/verify`,
`scripts/ci/`, and `THIRD_PARTY_NOTICES.md` under `Packages/DesignTokens/`.
`.github/workflows/ci.yml` preserves the exact shared-ci pin, macOS
`scripts/verify --all` plus public-consumer command, aggregate, audits, events,
permissions, concurrency, and 45-minute timeout, then adds
`setup-command: scripts/ci/setup.sh`,
`test-command: scripts/verify --layer Tokens`, and
`test-runs-on: ubuntu-24.04`. The root setup wrapper enters
`Packages/DesignTokens` and invokes the exact imported provider setup, preserving
its checksum-pinned Node 22.23.3 platform matrix and locked `npm ci` flags.
`.gitignore` adds only anchored nested `node_modules/` and `*.tgz` outputs;
it never ignores generated data, `dist/**`, source, manifests, or locks. These
are S100 protected-path changes, not part of P050 and not permission to alter
review, shared-ci, rulesets/settings, identity, credentials, releases, or
provider governance.

### `P175` — Provider authority quiescence prerequisite

Observable goal: the imported S100 release unit remains byte/history compatible,
while the provider's durable repository contract no longer permits ordinary
development before target activation. One ordinary provider PR, based on exact
`87bef8fbab5bf67a748815d7ed04d7ae199f760a`, changes only `AGENTS.md`,
`docs/constitution.md`, and `README.md`. The README identifies the target as the
future authority and requires future adopters to use a version-matched target
migration contract after activation; it names no future SHA and claims no public
route before S200/T260. It must pass
exact-head independent review, CODEOWNERS/delegated Owner approval, required CI,
PR Manager merge, and merged-main/three-blob readback. It preserves historical
pins/tags/releases,
public APIs/data/generated bytes, old-URL resolution, gates, and the provider
shared-ci pin; it cannot change source, manifests, credentials, rulesets,
settings, releases/tags, archive state, or repository identity. S200 cannot start
or publish until P175 actually merges. P175 also records the exact three
pre-change blobs: if Root abandons activation before S200, an ordinary reviewed,
Owner-approved, required-CI provider rollback PR restores only those blobs and
merges before the inert S100 import is removed.

### `S200` — Activate the local Swift dependency and contracts

Observable goal: an exact target revision publicly resolves stable
`DesignTokens` and `NativeDesignKit` products from one root Swift package, and
all version-matched consumer contracts explain the manifest-only migration.

This slice changes the root manifest/lock, root `AGENTS.md` and README dependency
declarations, dependency direction, target/root contracts, external consumers,
and necessary tests together. It must not change
semantic token data, generated values, NativeDesignKit component source, visual
behavior, platform floors, or gate strength. The old URL must be absent from the
activated root package and its revision-mode consumer lock.

### `S300` — Exact-head consolidation and retirement-readiness gate

Observable goal: one frozen pushed target revision has complete local/public
consumer/current-head evidence plus a concrete, limitation-aware retirement and
rollback packet for Root.

This is verification/evidence work. If a tracked repair is needed, it returns to
the owning S100/P175/S200 implementer and creates a new SHA/review cycle. S300 does
not mutate repository settings, publish/tag, or edit the old repository.

### `D400` — Root release and retirement decision

After S300, Root decides whether to authorize the recommended consolidated
`v0.3.0` release and old-repository archive/read-only settings. The provider
README quiescence notice already landed in P175; Native/npm release and GitHub
settings remain outside the current authorization. A negative
or deferred decision leaves the old immutable repository readable and the
target revision consumable only by reviewed SHA; it is not silently reported as
full retirement.

## Verification strategy

| Invariant | Enforcing mechanism | Proof |
| --- | --- | --- |
| one editable data authority | tech-context ownership, provenance/import checker, generator source-path assertions | negative duplicate-source fixture plus context audit |
| generated files are generated | both provider generators and `generate:check` wired into Tokens gate | the six named color outputs plus four named style outputs reproduce byte-for-byte, the gate reports `Checked 10 outputs`, and one deliberate drift fixture fails |
| no UI in DesignTokens | Swift import lint plus package compilation | forbidden-import negative check and Swift build/test |
| no reverse/circular dependency | root/leaf `depends_on`, context audit, root manifest inspection | audit has no cycle; manifest shows local `NativeDesignKit -> DesignTokens` only |
| exact errors/no fallback | imported provider Node/Swift suites and native regression tests | unknown/invalid inputs retain exact failures in both themes |
| stable native behavior | component source blob comparison plus package/runtime regression assertions | Button/Card/List source blobs match target baseline and existing tests remain present |
| stable npm exports | real tarball install and checker from nested pack root | isolated JS/TS/CSS/JSON consumer receipt |
| stable public Swift products | root-package external consumer at pushed SHA | imports both products; lock resolves only target URL/SHA |
| data-only watchOS boundary | root package floor plus NativeDesignKit compile guard | DesignTokens-only watchOS build succeeds; selecting NativeDesignKit fails with the named unavailable diagnostic |
| contracts match artifacts | root/nested registry/checkers and versioned-doc byte checks | both checker outputs pass from resolved consumer artifacts |
| review admits the complete S100 diff | merged target caller input plus pinned reusable review byte check | P050 changes only `max-diff-bytes`; frozen S100 three-dot diff is complete and at most 1,000,000 bytes |
| imported important paths keep Owner routing | target CODEOWNERS baseline-line preservation plus effective-pattern resolver | every native rule/Owner remains; representative nested package/lock, token, AI, constitution, architecture, verification/CI-support, and notice paths resolve to `@LeePepe`, as do representative existing native paths |
| provider Linux Tokens coverage survives consolidation | additive target CI inputs, checksum-pinned nested setup, and fail-closed aggregate | Ubuntu 24.04 runs the real `scripts/verify --layer Tokens` Node/Chrome gate; macOS NativeDesignKit/UI/public-consumer, contract, workflow-lint, aggregate, and exact pin remain active on the same head |
| gates fail closed without public-resolution cycles | pre-push `scripts/verify --all`/hook parity, then pushed-SHA CI companion, aggregate/current-head review | local gates pass before push; after push the exact public SHA resolves; cancel/skip/mismatch cannot report pass |
| authority contracts match resolution | P175 three-blob receipt plus S200 root manifest/lock/`AGENTS.md`/README/context audit | provider ordinary delivery is frozen before S200; activated executable resolution and all target declarations name the same authority |
| history/rollback truthful | immutable tag/readback table, provenance manifest, and external import receipt | provider mappings are in the manifest; receipt maps reviewed PR head and final merge/squash SHA to the unchanged manifest blob without self-reference; rollback commands are explicit |
| retirement does not strand old consumers | preserved old URL/tags plus discovery limitations and archive-only recommendation | Native v0.1.0 resolution and known-consumer table remain verifiable |

## Acceptance coverage

`docs/design-tokens-consolidation-tasks.md` is the sole canonical per-acceptance
operational matrix. Planning verification compares its IDs with this spec,
requires exactly one row per ID, resolves every producer to an owning slice/task,
proves every producer reaches final reconciliation T320 through the dependency
graph, enforces T330-before-T320, and permits D400 only as the downstream decision
for `AC-AUTH-002`, `AC-HISTORY-002`, and `AC-RETIRE-002`. No implementation task
is schedulable until P001 receives an exact-revision AI Reviewer `PASS` and Team
Lead accepts the same revision.

## Risks and controls

| Risk | Control |
| --- | --- |
| Root manifests/AI docs collide | nested provider release unit; root owns only integration and Native contract entry |
| Two editable authorities exist during expand phase | staged import is provenance-locked/inert; activation makes target authoritative; old repo retirement is explicit |
| Provider policy still permits ordinary delivery at S200 | P175 removes that permission in exactly three support files and must merge/read back before S200 starts |
| Activation is abandoned after provider quiescence | P175 records the three pre-change blobs; Root-authorized ordinary rollback restores them with review/approval/CI/merge before S100 target cleanup |
| SwiftPM tag collision or independent-version fiction | preserve old refs in original repositories; unified future target tag; no tag action in implementation |
| Native v0.1.0 old URL becomes unavailable | old repository remains readable and tags immutable; archive-only retirement |
| Search zero is misreported as no consumers | discovery report includes method and limitations; known self-reference remains listed |
| Provider governance weakens target gates | do not import provider workflows/hooks/AGENTS/rulesets; minimally translate CODEOWNERS and Linux Tokens coverage into the target caller while preserving every target rule, gate, pin, timeout, permission, event, and Owner |
| Relocated important paths lose Owner review | T130 owns target CODEOWNERS, preserves its baseline lines, adds exact relocated patterns, and proves representative native/imported path resolution to the same Owner |
| Node/Chrome coverage disappears or setup pollutes tracked data | T150 adds the real Ubuntu lane and checksum-pinned nested-lock setup; `.gitignore` permits only nested dependencies/tarballs and generation/pack checks reject omitted tracked outputs |
| S100 exceeds complete-review capacity | merge P050 first; measure the frozen S100 three-dot diff; over 1,000,000 bytes blocks/replans without splitting or omission |
| Import manifest requires its own commit hash | manifest records immutable provider/path/blob facts; later external receipt binds the target import SHA and manifest blob |
| Public resolution is attempted before push | local hook proves local/generation/packed artifacts; required CI proves the exact fetchable pushed SHA before delivery |
| Mechanical import silently changes generated bytes | provider blob/hash mapping and generate-check at import head |
| Activation changes component appearance/API | native component paths are inspection-only and baseline blob assertions fail on change |
| Evidence goes stale | all reviews, consumers, and checks bind one SHA; any repair invalidates and reruns them |

## Entry and exit gates

P001 exits only when the four artifact blobs and commit are fixed and independent
architecture/spec review returns `PASS`; its normal non-Draft PR then passes
required checks and delegated Owner approval, actually merges, and target main
reads back the exact four reviewed blobs. Only that merged P001 base admits
P050. P050 then requires its own exact-head review, delegated Owner approval,
normal non-Draft PR, required CI, and actual merge readback. Only that merged
target base admits S100. After S100 merge/readback, P175 requires its own exact
provider base, three-path diff, exact-head review, CODEOWNERS/delegated Owner
approval, required CI, PR Manager merge, and merged-main/three-blob readback.
Only then may S200 start. S100 and S200 each
require their own Fullstack implementation, exact-head independent pre-push
review, normal non-Draft PR, required gates, and merge readback in dependency
order. Local verification precedes push; public-SHA resolution runs only after
the SHA is fetchable and blocks delivery. S300 exits only with a frozen merged
target revision, both public consumer receipts, exact provenance, required-check
evidence, the already-merged P175 receipt, and a retirement/rollback packet.
D400 is never inferred from technical success.
