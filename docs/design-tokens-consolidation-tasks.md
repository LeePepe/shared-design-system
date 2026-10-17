# Design-token consolidation task graph

Status: proposed for independent exact-revision architecture/spec review

Specification: `docs/design-tokens-consolidation-spec.md`

Plan: `docs/design-tokens-consolidation-plan.md`

ADR: `docs/adr/0001-consolidate-design-tokens-authority.md`

## Execution rules

- This graph authorizes no implementation until its exact planning revision has
  AI Reviewer `PASS` and Team Lead acceptance.
- Each slice is one observable PR goal, one branch/worktree, one Fullstack
  writer, one frozen prepublication candidate, and one exact-head review/gate
  cycle. Tasks within a slice are layer-scoped rows, not separate writers or PRs.
- S100 must merge before S200 starts. S300 begins only after both merge and the
  exact target main revision is recorded. No stacked merge order is inferred.
- Mechanical source relocation is isolated in S100. Public package resolution,
  manifest identity, and contract behavior change only in S200.
- One writer owns every path in a slice. Parallel `[P]` rows are permitted only
  after the slice writer verifies nonoverlapping paths and no incomplete edge.
- Product/component source, semantic token values, generated values, tests,
  assertions, gates, and policies are never changed merely to make migration
  pass. Findings return to the owning slice; they do not widen scope.
- Every publication records clean local SHA, pushed remote SHA, PR `headRefOid`,
  exact review verdict, command/exit/count evidence, and current-head checks.
- Provider source acquisition is from public immutable revision
  `87bef8fbab5bf67a748815d7ed04d7ae199f760a`, never a stale checkout. Target
  implementation starts from reviewed planning landed on base
  `ad63bf37d3045349c50e724e0573a75871ebc896` or an explicitly approved descendant
  containing byte-identical reviewed artifacts.

## Dependency graph

```text
T001 planning artifacts
  -> exact-revision AI Reviewer PASS
    -> Team Lead acceptance / planning publication
      -> S100 exact provider import
        T110 -> T120
          \      /
           T130 -> T140 -> T150
                       |
                       v
      -> S200 local Swift activation
        T210 -> T215 -> T220
          |              |
          +-----> T230 ---+-> T240 -> T250 -> T260
                                      |
                                      v
      -> S300 exact-head consolidation gate
        T310 -> T320 -> T330
                          |
                          v
      -> D400 Root release/archive decision
```

The graph is acyclic. `D400` is a decision boundary, not an implementation task.

## `P001` — Reviewed planning contract

- [ ] T001 Create and validate the ADR/spec/plan/tasks at the four exact docs paths.

| Field | `T001` |
| --- | --- |
| owner area | repository support / architecture planning |
| context | `AGENTS.md`, root and NativeDesignKit tech-contexts, target `ai/**`, pinned shared-ci protocol/contract, provider constitution/architecture/contracts at exact provider revision |
| paths | `docs/adr/0001-consolidate-design-tokens-authority.md`; `docs/design-tokens-consolidation-{spec,plan,tasks}.md` |
| excludes | all source, tests, manifests, locks, contracts, gates, workflows, settings, releases, tags, old repo |
| contract impact | planning and proposed architecture only; no runtime/public package change |
| acceptance | all spec IDs are stable, mapped, and cover existing/compatibility/removed behavior; task graph is acyclic and schedulable |
| verification | `git diff --check`; Markdown/reference/AC/task mapping checks; `scripts/verify`; exact four-path diff; blob SHA capture |
| blocks | every S100/S200/S300 task |

## `S100` — Exact provider import and local gates

Observable PR intent: **After this PR, the exact DesignTokens v0.2.0 release unit
is provenance-bound and independently verifiable inside shared-design-system,
while NativeDesignKit still resolves the public external provider unchanged.**

- [ ] T110 [US1] Import the platform-neutral Tokens release unit under `Packages/DesignTokens/` with exact provenance.
- [ ] T120 [US1] Import the UI-free Swift DesignTokens target/tests/examples without activating it in the root package.
- [ ] T130 [US1] Declare Tokens and DesignTokens layer ownership/dependency/gates and map every imported path.
- [ ] T140 [US1] Adapt nested pack/contract/consumer paths and prove the nested artifact uses its own versioned contract.
- [ ] T150 [US1] Verify the mechanical import, baseline hashes, generated drift checks, and unchanged root Native dependency.

| Task | Owner layer/area | In-scope paths | Contract / task-local acceptance | Verification | Depends on |
| --- | --- | --- | --- | --- | --- |
| `T110` | Tokens | `Packages/DesignTokens/{tokens,dist,ai,docs,specs,examples/data,scripts,tests}` Node/data portions; `package.json`, lock, README/changelog/licenses/notices; import manifest | Provider `v0.2.0` public sources/exports/docs are copied or explicitly excluded with hashes. Only nested `tokens/colors.json` and `tokens/styles.json` are editable data. Generated outputs reproduce exactly. Old `.github`, hooks, root agent files, credentials, settings, and refs are excluded. | nested `npm ci`; provider Node/generate/pack/contract/AI/browser gates; provenance manifest verifier; deliberate generated-drift negative check | P001 accepted |
| `T120` | DesignTokens | `Packages/DesignTokens/Sources/DesignTokens/**`, Swift tests/example, nested `Package.swift` | Product/module/signatures/errors/platforms match provider baseline; Foundation-only and no UI import; root `Package.swift` unchanged. S100 makes no public target-resolution claim. | nested `swift build`; `swift test`; disposable local-path consumer of the nested manifest; public-surface/blob comparison to provider `v0.2.0`; forbidden-import scan | `T110` generated data available |
| `T130` | repository support | root `docs/architecture/tech-context.md`; new Tokens and DesignTokens leaf contexts; existing NativeDesignKit leaf context | Three-layer target model is declared but NativeDesignKit still uses the external provider until S200. Every path maps once; Tokens -> DesignTokens edge only; target governance/pin/gates retained. Existing CODEOWNERS already protects `docs/architecture/**`; no executable tree is hidden as support. | shared-ci context audit; workflow lint; layer listing/edge audit; existing CODEOWNERS effective-pattern inspection | `T110`, `T120` paths fixed |
| `T140` | Tokens | nested `package*.json`, `ai/**`, contract checker/tests, Node/TypeScript/CSS examples and tarball harness | Real tarball packed from nested root preserves name/exports/license/private state and its own `ai/` bytes; path adaptation is recorded separately from imported byte identity. Root contract remains untouched until T240. No registry publication or old URL substitution. | real tarball install; JS/TS/CSS/JSON consumers; nested checker; source-vs-packed contract comparison | `T110`, `T130` |
| `T150` | integration evidence | test/evidence only; no new production behavior | Root manifest/lock and Native source blobs match baseline; existing `scripts/verify --all` selects/runs new layers through declared gates; provider and target revisions/hashes recorded. | `git diff --check`; `scripts/verify --all`; root manifest/blob equality; imported source/hash mapping; clean SHA/review/check reconciliation | `T120`, `T130`, `T140` |

S100 excludes root Swift activation, native contract/package-identity migration,
component source, token/style value changes, publication, tags, and old-repository
mutation. Any unavoidable imported byte adaptation appears in an explicit
source-path/adaptation table and receives behavior-equivalence tests.

## `S200` — Local Swift activation and version-matched contracts

Observable PR intent: **After this PR, a public exact revision of
shared-design-system supplies both stable Swift products with NativeDesignKit
using the local DesignTokens target and version-matched migration contracts.**

- [ ] T210 [US2] Publish both root Swift products and replace the external package edge with the local DesignTokens target.
- [ ] T215 [US2] Enforce DesignTokens-only watchOS support without exposing NativeDesignKit as a watchOS component library.
- [ ] T220 [US2] Prove NativeDesignKit source/API/visual/error behavior remains unchanged through activation.
- [ ] T230 [US2] Update the nested DesignTokens contract and public consumers for the new repository route.
- [ ] T240 [US2] Update NativeDesignKit/root discovery, compatibility, migration, and rollback contracts.
- [ ] T250 [US2] Make the normal verification entry prove all three layers and both public consumer routes.
- [ ] T260 [US2] Freeze, independently review, publish, and reconcile the activation SHA.

| Task | Owner layer/area | In-scope paths | Contract / task-local acceptance | Verification | Depends on |
| --- | --- | --- | --- | --- | --- |
| `T210` | repository support / Swift package integration | root `Package.swift`, `Package.resolved` as applicable, architecture dependency declarations | Root products/modules are exactly `DesignTokens` and `NativeDesignKit`; Native target depends on local DesignTokens; old provider URL/package is absent from active root resolution; package floors are iOS15/macOS12/watchOS8. | `swift package dump-package`; root resolve/build/test; manifest negative search; context audit | S100 merged |
| `T215` | NativeDesignKit | one new platform-boundary source file plus an external negative compile fixture; no component implementation file | DesignTokens-only watchOS consumer builds. Selecting NativeDesignKit for watchOS fails with the documented stable unavailable diagnostic before component use. iOS/macOS API and behavior are unchanged; no watchOS component implementation is added. | watchOS DesignTokens-only compile; negative NativeDesignKit watchOS compile matching the diagnostic; iOS/macOS package build/tests | `T210` candidate |
| `T220` | NativeDesignKit | Native tests/fixtures only when needed for migration regression; existing production source is inspection-only except the exact T215 platform guard | Native public API and accepted Button/Card/List blobs/semantics remain unchanged. Explicit themes, exact errors, five palettes, Solid/Glass/fallback stay. Deferred Button input assertions/history remain unchanged and are not rerun as claimed evidence. | baseline blob comparison; existing package tests; applicable actual fixture regression without unchanged pointer diagnosis; no removed/weakened test diff | `T215` |
| `T230` | Tokens | `Packages/DesignTokens/ai/**`, nested compatibility/migration/changelog, contract checker/tests, and Node/package examples | Contract names the new target URL/revision route while preserving npm artifact identity/exports and documenting the unchanged public Swift interface. Old immutable versions remain documented. Swift target-revision resolution is owned by T250, not this contract task. | nested AI checker/tests; packed Node consumer; contract byte/version/surface checks | `T210` |
| `T240` | NativeDesignKit contract | root `ai/**`, README/compatibility/migration/integration/examples/registry/checker tests as necessary | Root contract discovers both release units, explains local target dependency and consumer manifest migration, preserves Native release/unreleased split, rollback, accepted component evidence, and deferred Button truth. | root contract checker/tests; broken-pointer/version negative fixtures; public-import consumer compile | `T210`, `T220`, `T230` contract location fixed |
| `T250` | repository support / integration | `scripts/ci/external-consumer.py`, its tests/fixtures, and the three leaf gate declarations | `scripts/verify` and the hook/workflow callers remain byte-identical; generic layer routing runs every local gate. The existing CI companion consumer command now imports both Swift products from the pushed target SHA. Missing/cancelled/skipped/mismatched resolution fails; no path/mirror fallback. Any need to change the normal entry or workflow is a contract blocker returned to Team Lead, not silent task expansion. | `scripts/verify`; `scripts/verify --all`; hook/caller byte comparison; workflow lint; contract audit; isolated root-revision Swift consumer importing both products; real nested npm tarball consumer | `T220`, `T230`, `T240` |
| `T260` | integration evidence | no extra scope | One clean candidate has exact provider provenance, current local results, AI Reviewer pre-push PASS, pushed SHA equality, non-Draft PR, Owner review for protected paths, and real required gates. | captured local/remote/PR SHA equality; check rollup at head; diff path audit; reviewer verdict | `T250` |

S200 excludes semantic data/value/schema changes, generated-value changes,
component/API redesign, new platform components, provider release/tag, npm
publication, and repository settings.

## `S300` — Exact-head consolidation and retirement readiness

This is one acceptance/evidence outcome, not a code PR unless an owning S100/S200
defect is routed back and corrected there.

- [ ] T310 [US3] Re-run isolated public Node and Swift consumers against the exact merged consolidation revision.
- [ ] T320 [US3] Reconcile architecture, baseline behavior, provenance, checks, reviews, and unchanged-scope evidence.
- [ ] T330 [US3] Produce the concrete consumer migration, history/tag mapping, rollback, and old-repository retirement packet for Root.

| Task | Owner layer/area | In-scope evidence | Acceptance / verification | Depends on |
| --- | --- | --- | --- | --- |
| `T310` | integration verification | disposable external consumers and receipts outside tracked source | Node installs actual nested tarball; Swift resolves public target URL at exact merged SHA, imports both products, runs public behavior tests, and has no old provider URL/identity in resolution. Record hashes, lock, commands/exits/counts. | S200 merged and exact merge SHA fetchable |
| `T320` | integration verification | target main/PR/check/review/provenance readbacks | All ACs except D400 decision outcomes have cited evidence; three-layer audit/gates pass; native baseline blobs/tests and Button deferral history are intact; no unrequested source/test/policy change; local/remote/merge/check SHAs are reconciled. A stale or partial result is `unverified`, not pass. | `T310` |
| `T330` | repository support / decision packet | read-only consumer discovery plus reviewed migration/retirement/rollback docs and release mapping | Known consumers and limitations are listed. Historical tag/URL availability is proven. Packet recommends consolidated `v0.3.0` candidate plus old-repo notice/archive sequence, names exact approval/settings/release steps, and rejects delete/rename/transfer/rewrite/mirror. No external mutation occurs. | `T320` |

## Decision boundary `D400`

Root/Owner chooses whether and when to authorize:

1. the first unified consolidated Swift tag (recommended `v0.3.0`);
2. any Native release notes/artifacts;
3. any DesignTokens npm tarball release and whether registry publication remains
   disabled (default: disabled);
4. an old-provider default-branch migration notice; and
5. GitHub archive/read-only settings after consumer and rollback evidence.

Until that explicit decision, no agent tags, releases, changes credentials or
repository settings, edits the old repository, or calls consolidation fully
retired. Old tags/commits remain accessible in every outcome.

## Acceptance-to-task matrix

| Acceptance ID | Task(s) |
| --- | --- |
| `AC-AUTH-001` | `T110`, `T130`, `T150`, `T320` |
| `AC-AUTH-002` | `T240`, `T260`, `T330`, `D400` |
| `AC-LAYER-001` | `T130`, `T210`, `T250`, `T320` |
| `AC-LAYER-002` | `T120`, `T210`, `T250` |
| `AC-GEN-001` | `T110`, `T150`, `T250` |
| `AC-SWIFT-001` | `T120`, `T210`, `T215`, `T310` |
| `AC-SWIFT-002` | `T120`, `T230`, `T310` |
| `AC-NATIVE-001` | `T220`, `T260`, `T320` |
| `AC-NATIVE-002` | `T220`, `T250`, `T320` |
| `AC-NATIVE-003` | `T220`, `T240`, `T320` |
| `AC-WEB-001` | `T110`, `T140`, `T230`, `T310` |
| `AC-CONTRACT-001` | `T140`, `T230`, `T240`, `T250` |
| `AC-VERIFY-001` | `T130`, `T150`, `T250`, `T260`, `T320` |
| `AC-CONSUMER-001` | `T140`, `T230`, `T250`, `T310` |
| `AC-CONSUMER-002` | `T230`, `T250`, `T310` |
| `AC-EVIDENCE-001` | `T150`, `T260`, `T320` |
| `AC-HISTORY-001` | `T110`, `T150`, `T320` |
| `AC-HISTORY-002` | `T230`, `T240`, `T330`, `D400` |
| `AC-COMPAT-001` | `T210`, `T230`, `T240`, `T310` |
| `AC-COMPAT-002` | `T240`, `T330` |
| `AC-RETIRE-001` | `T330` |
| `AC-RETIRE-002` | `T330`, `D400` |
| `AC-ROLLBACK-001` | `T230`, `T240`, `T330` |
| `AC-SCOPE-001` | slice exclusions and `T320` |
| `AC-SCOPE-002` | P001 scope and `T320` |

All implementation tasks have one owning layer/area, explicit paths, exclusions,
contract effect, verification, and blocking edges. No task requires Fullstack to
invent product behavior or a release/settings decision.

## Planning publication gate

Before handing this graph to Team Lead:

1. only the four P001 documents differ from the exact target base;
2. `git diff --check` and the repository's normal planning-safe verification
   pass at the candidate revision;
3. the exact commit plus four blob SHAs are recorded;
4. an independent AI Reviewer returns architecture/spec `PASS` for that exact
   revision; and
5. any byte change after review triggers a fresh gate.

Planner does not implement S100/S200, create implementation children before
PASS, assign roles, merge, release, mutate the old repository, or decide D400.
