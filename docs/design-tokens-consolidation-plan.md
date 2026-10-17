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
| provider | `https://github.com/LeePepe/shared-design-tokens.git` |
| exact provider import | `87bef8fbab5bf67a748815d7ed04d7ae199f760a` (`v0.2.0`) |
| repository protocol | `shared-ci@6e354f476bc53d68f0f09fc231d5cd938466af9c` |
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
| Tokens | `Packages/DesignTokens/tokens/**`, `dist/**`, `scripts/**` except Swift-only fixtures, Node tests/examples, `package*.json`, nested `ai/**`, provider docs/specs/licenses | editable visual data, schema/provenance, generation, JS/TS/CSS/JSON/npm surfaces and contract | none |
| DesignTokens | `Packages/DesignTokens/Sources/DesignTokens/**`, Swift tests/examples, nested `Package.swift` | UI-free Swift data interface and exact-error behavior | Tokens |
| NativeDesignKit | existing `Sources/NativeDesignKit/**`, `Tests/**` excluding imported provider tests, root `ai/**` | SwiftUI interface, package tests, actual UI fixtures, native consumer contract | DesignTokens |
| repository support | root `Package.swift`/lock, root docs/architecture, root ADR/spec/plan/tasks, `AGENTS.md`, hooks, workflows, `scripts/verify`, `scripts/ci/**` | package integration, path routing, common gates and review | checked as support; manifest/gate changes force the full graph |

Exact glob ownership is finalized in the contract-import PR and must pass the
context audit without hiding executable paths in support.

## Planning decisions

1. **Nest the provider release unit.** `Packages/DesignTokens` avoids manifest,
   license, spec, and `ai/` root collisions and remains a valid npm pack root.
2. **One root Swift graph.** Root `Package.swift` exposes `DesignTokens` and
   `NativeDesignKit`; NativeDesignKit depends on the local target. The nested
   provider manifest remains a provider-local verification/packaging fixture,
   not a second public repository authority.
3. **Expand, activate, then contract.** First import and verify the exact
   provider without changing the active native dependency. Then activate the
   local target, transfer development authority to the target, and update both
   contracts atomically. From that S200 revision onward the old repository
   accepts no new source/PR/tag/release. Finally prove public resolution and
   prepare archive enforcement evidence. No intermediate main revision is left
   broken or falsely authoritative.
4. **Separate mechanical import from behaviour.** Import preserves provider
   bytes except listed root/path adaptations. Activation owns manifest/package
   identity and contract changes. Native component source is inspection-only.
5. **Preserve independent contracts.** Root `ai/` remains NativeDesignKit;
   nested `ai/` remains DesignTokens. Cross-links and checkers prove correct
   version/release-unit discovery rather than merging incompatible registries.
6. **Adopt target governance.** Provider `.github`, hooks, root `AGENTS.md`, CI,
   rulesets, and old shared-ci pin are provenance inputs, not imported active
   governance. The target's normal hook/verify/CI/gates remain authoritative.
7. **Do not import colliding refs.** Provider source provenance is a manifest of
   exact revision, blob/hash mapping, licenses, and exclusions. Old commits/tags
   stay immutable and reachable in the old repository.
8. **Use a unified future Swift version.** The recommended first consolidated
   release candidate is `v0.3.0`; choosing/tagging/releasing it is a later Root
   decision. Exact-revision consumers unblock implementation verification.
9. **Retire safely.** The old repository remains historically readable after
   authority transfers at S200. Recommended settings enforcement is a later
   notice + archive after target delivery, consumer migration evidence, and Root
   authorization; never delete/rename/transfer/rewrite/mirror.
10. **Preserve current native truth.** Button/Card/List accepted bytes and
    contracts are migration baselines. Button input deferrals remain failed and
    unknown; migration neither retries nor converts them to pass.

## PR slices and dependency order

### `P001` — Planning contract foundation

One docs-only goal: land the independently reviewed ADR/spec/plan/tasks before
implementation. Only the four paths named by `T001` may change. Full target
verification and Owner review apply because the ADR is protected architecture.

### `S100` — Exact provider import and local gates

Observable goal: the target contains an inert, exact, provenance-bound
DesignTokens provider release unit under `Packages/DesignTokens`, and its
Tokens/DesignTokens gates pass inside the target without changing root product
resolution.

This slice may perform only mechanical path relocation and the minimum
root-relative harness/context adaptations needed to run the imported package.
The root NativeDesignKit manifest stays byte-identical, still resolving public
exact provider `0.2.0`. Provider active governance files are excluded. Generated
artifacts must match regeneration and the provenance manifest.

### `S200` — Activate the local Swift dependency and contracts

Observable goal: an exact target revision publicly resolves stable
`DesignTokens` and `NativeDesignKit` products from one root Swift package, and
all version-matched consumer contracts explain the manifest-only migration.

This slice changes the root manifest/lock, dependency direction, target/root
contracts, external consumers, and necessary tests together. It must not change
semantic token data, generated values, NativeDesignKit component source, visual
behavior, platform floors, or gate strength. The old URL must be absent from the
activated root package and its revision-mode consumer lock.

### `S300` — Exact-head consolidation and retirement-readiness gate

Observable goal: one frozen pushed target revision has complete local/public
consumer/current-head evidence plus a concrete, limitation-aware retirement and
rollback packet for Root.

This is verification/evidence work. If a tracked repair is needed, it returns to
the owning S100/S200 implementer and creates a new SHA/review cycle. S300 does
not mutate repository settings, publish/tag, or edit the old repository.

### `D400` — Root release and retirement decision

After S300, Root decides whether to authorize the recommended consolidated
`v0.3.0` release and the old-repository notice/archive sequence. Native/npm
release and GitHub settings remain outside the current authorization. A negative
or deferred decision leaves the old immutable repository readable and the
target revision consumable only by reviewed SHA; it is not silently reported as
full retirement.

## Verification strategy

| Invariant | Enforcing mechanism | Proof |
| --- | --- | --- |
| one editable data authority | tech-context ownership, provenance/import checker, generator source-path assertions | negative duplicate-source fixture plus context audit |
| generated files are generated | provider `generate:check` wired into Tokens gate | source regeneration produces no diff; one deliberate drift fixture fails |
| no UI in DesignTokens | Swift import lint plus package compilation | forbidden-import negative check and Swift build/test |
| no reverse/circular dependency | root/leaf `depends_on`, context audit, root manifest inspection | audit has no cycle; manifest shows local `NativeDesignKit -> DesignTokens` only |
| exact errors/no fallback | imported provider Node/Swift suites and native regression tests | unknown/invalid inputs retain exact failures in both themes |
| stable native behavior | component source blob comparison plus package/runtime regression assertions | Button/Card/List source blobs match target baseline and existing tests remain present |
| stable npm exports | real tarball install and checker from nested pack root | isolated JS/TS/CSS/JSON consumer receipt |
| stable public Swift products | root-package external consumer at pushed SHA | imports both products; lock resolves only target URL/SHA |
| data-only watchOS boundary | root package floor plus NativeDesignKit compile guard | DesignTokens-only watchOS build succeeds; selecting NativeDesignKit fails with the named unavailable diagnostic |
| contracts match artifacts | root/nested registry/checkers and versioned-doc byte checks | both checker outputs pass from resolved consumer artifacts |
| gates fail closed | target `scripts/verify --all`, hook parity, CI aggregate/current-head review | command exits zero on candidate; negative fixture/cancel/skip cannot report pass |
| history/rollback truthful | immutable tag/readback table and provenance manifest | old/new tag commits, source mappings, and rollback commands are explicit |
| retirement does not strand old consumers | preserved old URL/tags plus discovery limitations and archive-only recommendation | Native v0.1.0 resolution and known-consumer table remain verifiable |

## Acceptance coverage

| Acceptance | Primary tasks |
| --- | --- |
| `AC-AUTH-001`, `AC-GEN-001`, `AC-HISTORY-001` | `T110`, `T120`, `T150`, `T310` |
| `AC-AUTH-002` | `T240`, `T260`, `T330`, `D400` |
| `AC-LAYER-001`, `AC-LAYER-002` | `T130`, `T210`, `T250` |
| `AC-SWIFT-001`, `AC-SWIFT-002` | `T120`, `T210`, `T215`, `T230`, `T310` |
| `AC-NATIVE-001..003` | `T220`, `T250`, `T320` |
| `AC-WEB-001` | `T110`, `T140`, `T310` |
| `AC-CONTRACT-001` | `T140`, `T230`, `T240`, `T250` |
| `AC-VERIFY-001` | `T130`, `T150`, `T250`, `T320` |
| `AC-CONSUMER-001..002` | `T140`, `T230`, `T250`, `T310` |
| `AC-EVIDENCE-001` | `T150`, `T260`, `T320` |
| `AC-HISTORY-002`, `AC-COMPAT-001..002` | `T230`, `T240`, `T330` |
| `AC-RETIRE-001..002`, `AC-ROLLBACK-001` | `T330`, `D400` |
| `AC-SCOPE-001..002` | every task exclusion; final `T320` audit |

Every acceptance ID maps to an executable task or the explicit Root decision.
No implementation task is schedulable until P001 receives an exact-revision AI
Reviewer `PASS` and Team Lead accepts the same revision.

## Risks and controls

| Risk | Control |
| --- | --- |
| Root manifests/AI docs collide | nested provider release unit; root owns only integration and Native contract entry |
| Two editable authorities exist during expand phase | staged import is provenance-locked/inert; activation makes target authoritative; old repo retirement is explicit |
| SwiftPM tag collision or independent-version fiction | preserve old refs in original repositories; unified future target tag; no tag action in implementation |
| Native v0.1.0 old URL becomes unavailable | old repository remains readable and tags immutable; archive-only retirement |
| Search zero is misreported as no consumers | discovery report includes method and limitations; known self-reference remains listed |
| Provider governance weakens target gates | do not import provider workflows/hooks/AGENTS/rulesets; target shared-ci pin and gates remain authoritative |
| Mechanical import silently changes generated bytes | provider blob/hash mapping and generate-check at import head |
| Activation changes component appearance/API | native component paths are inspection-only and baseline blob assertions fail on change |
| Evidence goes stale | all reviews, consumers, and checks bind one SHA; any repair invalidates and reruns them |

## Entry and exit gates

P001 exits only when the four artifact blobs and commit are fixed and independent
architecture/spec review returns `PASS`. S100 and S200 each require their own
Fullstack implementation, exact-head independent pre-push review, normal
non-Draft PR, required gates, and merge readback in dependency order. S300 exits
only with a frozen merged target revision, both public consumer receipts, exact
provenance, required-check evidence, and a retirement/rollback packet. D400 is
never inferred from technical success.
