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
- P001 must pass delegated Owner approval and required checks, actually merge,
  and read back the exact reviewed four artifact blobs before P050 starts.
- P050 must actually merge before S100 starts or publishes. S100 must actually
  merge and read back before P175 starts. P175 must actually merge and read back
  before P190 starts. P190 must actually merge and read back before the preserved
  S200 candidate resumes or publishes. S300 begins only after S200 merges and
  the exact target main revision is recorded. No stacked merge order is inferred.
- Mechanical source relocation is isolated in S100. P175 changes only the
  provider governance contract; target public package resolution, manifest
  identity, and consumer-contract behavior change only in S200.
- One writer owns every path in a slice. Parallel `[P]` rows are permitted only
  after the slice writer verifies nonoverlapping paths and no incomplete edge.
- Product/component source, semantic token values, generated values, tests,
  assertions, gates, and policies are never changed merely to make migration
  pass. The only S100 support-policy changes are the explicitly authorized
  CODEOWNERS relocation and additive CI/setup/ignore parity in T130/T150; they
  preserve existing coverage. Findings return to the owning slice; they do not
  widen scope.
- Every publication records clean local SHA, pushed remote SHA, PR `headRefOid`,
  exact review verdict, command/exit/count evidence, and current-head checks.
- Decision B keeps the registered S200 candidate, its 36-path staged index,
  snapshot, patch SHA-256 and repair/review history untouched while P190 is open.
  P190 uses its own task/worktree/PR from exact base
  `5eec04eac574e41586e0c42732faa623e64cf9f9`; only its actual merge/readback
  permits Team Lead to return the original writer to S200.
- Provider source acquisition is from public immutable revision
  `87bef8fbab5bf67a748815d7ed04d7ae199f760a`, never a stale checkout. Target
  implementation starts from reviewed planning landed on base
  `ad63bf37d3045349c50e724e0573a75871ebc896` or an explicitly approved descendant
  containing byte-identical reviewed artifacts.

## Dependency graph

```text
T001 planning artifacts
  -> exact-revision AI Reviewer PASS
    -> normal P001 PR + delegated Owner approval + required checks
      -> actual merge + exact four-blob readback
      -> P050 complete-review capacity
        T050 -> exact-head review + delegated Owner approval + CI + actual merge
          |
          v
      -> S100 exact provider import
        T110 -> T120
          \      /
           T130 -> T140 -> T150
                       |
                       v
      -> P175 provider authority quiescence
        T175 -> exact-head review + Owner approval + CI + PRM merge/readback
                       |
                       v
      -> P190 test-capable Swift package scheme prerequisite
        T190 -> exact-head review + Owner approval + CI + PRM merge/readback
                       |
                       v
      -> S200 local Swift activation
        T210 -> T215 -> T220
          |              |
          +-----> T230 ---+-> T240 -> T250 -> T260
                                      |
                                      v
      -> S300 exact-head consolidation gate
        T310 -> T330 -> T320
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
| acceptance | all spec IDs are stable, mapped, and cover existing/compatibility/removed behavior; task graph is acyclic and schedulable; the normal planning-only PR passes delegated Owner approval and required checks, actually merges, and target main reads back the exact reviewed four blobs |
| verification | `git diff --check`; Markdown/reference/AC/task mapping checks; `scripts/verify`; exact four-path diff; reviewed/local/PR/merged blob-SHA equality |
| blocks | P050 and every S100/P175/P190/S200/S300 task |

## `P050` — Complete-review capacity prerequisite

Observable PR intent: **After this PR, the unchanged pinned Codex review admits
the complete bounded S100 diff while preserving every fail-closed review
semantic.**

- [ ] T050 [US0] Raise only the native caller's complete-diff byte capacity and merge it before S100.

| Field | `T050` |
| --- | --- |
| owner area | repository support / review governance |
| context | target `AGENTS.md`, `.github/workflows/review.yml`, pinned `shared-ci@6e354f476bc53d68f0f09fc231d5cd938466af9c` reusable review, and external `coordination/consolidation-provider-tree-root-read.json` |
| paths | `.github/workflows/review.yml` only: add `max-diff-bytes: 1000000` to `codex-review-target.with` |
| excludes | shared-ci source or pin; `codex-bin`; `rules-file`; Owner identity/decision semantics; reusable 25-minute timeout; concurrency/permissions/events; critical/high/tool/setup/parse fail-closed behavior; complete-diff handling; `codex-review-gate` and its 2-minute timeout; rulesets/settings; credentials; releases; all source/tests/data/generated files |
| contract impact | target complete-review capacity only; no truncation, severity, prompt, verdict, gate, package, runtime, or release change |
| acceptance | Evidence is complete (`truncated=false`): the intended 84-file / 581,977-byte provider subset produces a 619,833-byte relocated mechanical patch, so 1,000,000 leaves 380,167 bytes for bounded S100 adaptations. The P050 PR itself receives ordinary exact-head review under the old 200,000-byte default, delegated Owner approval, required CI, and actual merge readback. Before S100 publication, its frozen complete three-dot diff must be at most 1,000,000 bytes; overflow blocks/replans without splitting, truncation, or generated-data omission. |
| verification | exact one-field diff audit; workflow lint; contract audit; `scripts/verify`; exact-head AI review; protected-path Owner approval; required checks at PR head; merged-main caller blob/readback; negative evidence that every excluded caller/shared-ci/gate field is unchanged |
| depends on | P001 actual merge plus byte-identical readback of all four reviewed planning blobs |
| blocks | every S100/P175/P190/S200/S300 task |

## `S100` — Exact provider import and local gates

Observable PR intent: **After this PR, the exact DesignTokens v0.2.0 release unit
is provenance-bound and independently verifiable inside shared-design-system,
while NativeDesignKit still resolves the public external provider unchanged.**

- [ ] T110 [US1] Import the platform-neutral Tokens release unit under `Packages/DesignTokens/` with exact provenance.
- [ ] T120 [US1] Import the UI-free Swift DesignTokens target/tests/examples without activating it in the root package.
- [ ] T130 [US1] Declare Tokens and DesignTokens layer ownership/dependency/gates, map every imported path, and preserve effective Owner routing.
- [ ] T140 [US1] Adapt nested pack/contract/consumer paths and prove the nested artifact uses its own versioned contract.
- [ ] T150 [US1] Preserve target/native and provider/Linux gates, then verify the mechanical import, baseline hashes, generated drift checks, and unchanged root Native dependency.

| Task | Owner layer/area | In-scope paths | Contract / task-local acceptance | Verification | Depends on |
| --- | --- | --- | --- | --- | --- |
| `T110` | Tokens | `Packages/DesignTokens/tokens/**`, `dist/**`, `ai/**`, `scripts/*.mjs`, `tests/*.mjs`, `tests/consumer/**`, `examples/data/*.{mjs,ts,json}`, `package*.json`, and exact generated files `Sources/DesignTokens/{GeneratedColors.swift,GeneratedStyles.swift}` | Provider `v0.2.0` executable Tokens sources/exports are copied or explicitly excluded with hashes. Only nested `tokens/colors.json` and `tokens/styles.json` are editable data. Both generators reproduce exactly ten named outputs: `dist/{resolved.json,index.js,index.d.ts,colors.ts,colors.css,styles.js,styles.d.ts,styles.resolved.json}` and `Sources/DesignTokens/{GeneratedColors.swift,GeneratedStyles.swift}`. Old `.github`, hooks, root agent files, credentials, settings, refs, and all repository-support paths are excluded from Tokens ownership. | nested `npm ci`; provider Node/generate/pack/contract/AI/browser gates; `Checked 10 outputs`; exact ten-file inventory/hash check; deliberate generated-drift negative check | P050 actual merge read back |
| `T120` | DesignTokens | non-generated `Packages/DesignTokens/Sources/DesignTokens/**`, Swift tests/example, nested `Package.swift` | Product/module/signatures/errors/platforms match provider baseline; generated files remain T110-owned outputs; Foundation-only and no UI import; root `Package.swift` unchanged. S100 makes no public target-resolution claim. | nested `swift build`; `swift test`; disposable local-path consumer of the nested manifest; public-surface/blob comparison to provider `v0.2.0`; forbidden-import scan | `T110` generated data available |
| `T130` | repository support | imported nested `README*`, `CHANGELOG*`, `LICENSE*`, notices, `docs/**`, `specs/**`, and provenance manifest; root `docs/architecture/tech-context.md`; new Tokens and DesignTokens leaf contexts; existing NativeDesignKit leaf context; target `.github/CODEOWNERS` | Metadata/legal/docs/specs/provenance remain support, not Tokens. The manifest records immutable provider/path/blob/license/exclusion facts but never its containing target commit. Root context gains explicit nested support globs. Three code layers are declared while NativeDesignKit still uses the external provider until S200. Every path maps once; Tokens -> DesignTokens edge only; no executable tree is hidden as support. CODEOWNERS retains every line/pattern and `@LeePepe` Owner from target baseline blob `ba57dda416563c976f271a051b346327b74db16a`, then adds `/Packages/DesignTokens/**/package.json`, `/Packages/DesignTokens/**/package-lock.json`, `/Packages/DesignTokens/tokens/`, `/Packages/DesignTokens/ai/`, `/Packages/DesignTokens/docs/constitution.md`, `/Packages/DesignTokens/docs/architecture/`, `/Packages/DesignTokens/scripts/verify`, `/Packages/DesignTokens/scripts/ci/`, and `/Packages/DesignTokens/THIRD_PARTY_NOTICES.md`, all with that same Owner. Existing `**/Package.swift`, `**/Package.resolved`, and `**/tech-context.md` rules already cover their nested equivalents and remain unchanged. Provider `.github/**` is not imported; no identity, ruleset, settings, pin, gate, or review-policy change occurs. | provenance manifest verifier; shared-ci context audit; workflow lint; layer/support listing and edge audit; baseline CODEOWNERS-line preservation; deterministic effective-pattern resolution proving imported `tokens/colors.json`, upstream `package.json`, root nested `package-lock.json`, `scripts/verify`, `scripts/ci/setup.sh`, constitution, architecture tech-context, nested `Package.swift`, nested `ai/README.md`, and notice plus existing native `.github/workflows/ci.yml`, `scripts/verify`, root `Package.swift`, and root `ai/README.md` all resolve to `@LeePepe`; negative scope audit for settings/rules/identity | `T110`, `T120` paths fixed |
| `T140` | Tokens | nested `package*.json`, `ai/**`, contract checker/tests, Node/TypeScript/CSS examples and tarball harness | Real tarball packed from nested root preserves name/exports/license/private state and its own `ai/` bytes; path adaptation is recorded separately from imported byte identity. Root contract remains untouched until T240. No registry publication or old URL substitution. | real tarball install; JS/TS/CSS/JSON consumers; nested checker; source-vs-packed contract comparison | `T110`, `T130` |
| `T150` | repository support / integration evidence | imported exact `Packages/DesignTokens/scripts/verify` and `Packages/DesignTokens/scripts/ci/**`; target `.github/workflows/ci.yml`; new target `scripts/ci/setup.sh`; target `.gitignore`; test/evidence only otherwise, with no production behavior | Before publication, root manifest/lock and Native source blobs match baseline; `scripts/verify --all` selects/runs every local layer gate, reproduces all ten generated outputs, and reports `Checked 10 outputs`; the frozen complete three-dot diff is at most 1,000,000 bytes. Target CI retains baseline events, permissions, concurrency, `runs-on: macos-15`, exact shared-ci pin `6e354f476bc53d68f0f09fc231d5cd938466af9c`, the exact macOS `scripts/verify --all && python3 scripts/ci/external-consumer.py --revision "$(git rev-parse HEAD)"` command, contract/workflow audits, 45-minute timeout, aggregate and review gates. It adds only `setup-command: scripts/ci/setup.sh`, `test-command: scripts/verify --layer Tokens`, and `test-runs-on: ubuntu-24.04`. The target setup wrapper enters `Packages/DesignTokens` and invokes the exact imported provider setup blob `4fb3f7d4da77e757c5ed9491db2f41fe1cf3da24`, preserving `set -euo pipefail`, Node 22.23.3, its Linux-x64/Darwin-arm64/Darwin-x64 checksum matrix, `GITHUB_PATH`, and `npm ci --ignore-scripts --no-audit --no-fund`; setup failure blocks every command lane. `.gitignore` preserves every target entry and adds only `/Packages/DesignTokens/node_modules/` and `/Packages/DesignTokens/*.tgz`; generated data, `dist/**`, source, manifests, and locks remain tracked. P050's review caller stays separate and unchanged in S100. Only after actual S100 merge, the external receipt records PR number, reviewed PR-head SHA, final merge/squash SHA, and unchanged provenance-manifest blob. Squash identity changes never trigger a tracked manifest edit and must preserve its path/blob mappings; P175 cannot begin before this receipt exists. | pre-push `git diff --check`; exact imported setup blob plus wrapper-cwd audit; shell/setup lint and nested lock install; workflow lint; exact target-caller baseline-field/pin diff audit; `scripts/verify --all` on macOS; real required Ubuntu 24.04 Tokens lane with Node/Chrome/generation/pack/contract counts; exact ten-output/hash and ignored-path audits; exact diff-byte measurement using review semantics; root manifest/blob equality and imported source/hash mapping; protected-path delegated Owner approval plus current-head aggregate/`codex-review-gate`; post-merge clean SHA/review/check reconciliation and durable PR-head-to-merge receipt | `T120`, `T130`, `T140` |

S100 excludes root Swift activation, native contract/package-identity migration,
component source, token/style value changes, publication, tags, and old-repository
mutation. Except for T130/T150's exact target CODEOWNERS/CI/setup/ignore parity,
it also excludes active governance changes. Any unavoidable imported byte
adaptation appears in an explicit source-path/adaptation table and receives
behavior-equivalence tests.

## `P175` — Provider authority quiescence prerequisite

Observable PR intent: **After this PR, the provider remains a byte-stable,
resolvable historical source, but its durable repository contract no longer
permits ordinary development before target activation.**

- [ ] T175 [US1] Freeze provider development authority in exactly three support documents and merge it before S200.

| Field | `T175` |
| --- | --- |
| owner area | provider repository support / governance contract |
| context | provider exact base `87bef8fbab5bf67a748815d7ed04d7ae199f760a`; provider `main` and `v0.2.0` readback; existing CODEOWNERS protection; merged S100 import/receipt |
| paths | provider `AGENTS.md`, `docs/constitution.md`, and `README.md` only |
| excludes | `ai/**`; all source, data, generated files, manifests, tests, examples, package locks, workflows/hooks/gates; provider shared-ci source and exact pin `42d1704a5690ab5890657feaadb8929384632766`; rulesets/settings; credentials; releases/tags; archive/delete/rename/transfer; repository identity; target repository files |
| contract impact | removes permission for normal provider development, identifies the target as future authority, and requires adopters to use its version-matched migration contract after activation without naming a future SHA or claiming a public route; preserves exact old pins, URL resolution, public APIs/data/generated bytes, history, tags, releases, and all gate semantics |
| acceptance | Starts only after S100 actual merge/readback. The ordinary provider PR is based on the exact provider baseline, receives exact-head independent review, CODEOWNERS/delegated Owner approval for protected `AGENTS.md`/constitution paths, required CI, and PR Manager actual merge. Provider merged main is then read back with the reviewed three blob IDs unchanged. The receipt also records the exact three pre-P175 blobs. If Root abandons activation before S200, a separate ordinary PR restores only those blobs with the same review/approval/CI/merge/readback and must land before S100 cleanup. No settings/archive/release action occurs. |
| verification | exact three-path diff and exclusion audit; provider contract/README consistency; explicit absence of a pre-S200 target SHA/public-route claim; workflow/shared-ci-pin/gate byte comparison; source/data/generated/package/history identity checks; captured reviewed PR-head = remote branch = PR `headRefOid`; required-check rollup; final merge/squash receipt mapping reviewed head to merged-main SHA and the same three blobs; executable exact-three-blob rollback receipt template |
| depends on | S100 actual merge/readback and durable import receipt |
| blocks | P190 and every S200/S300 task |

## `P190` — Test-capable Swift package scheme prerequisite

Observable PR intent: **After this PR, the native iOS gate deterministically
selects the one generated Swift package scheme that can execute every declared
package test target for both the real one-product base and the accepted
two-product topology.**

- [ ] T190 [US2] Discover one complete test-capable generated package scheme, fail closed on invalid metadata, and prove both topologies.

| Field | `T190` |
| --- | --- |
| owner area | repository support / NativeDesignKit verification |
| context | exact target base `5eec04eac574e41586e0c42732faa623e64cf9f9`; `AGENTS.md`; pinned shared-ci protocol §3; `docs/architecture/native-design-kit/tech-context.md`; Decision B `01a14980-d4e9-7a54-bd45-d90e6ae9cc53`; raw `NativeDesignKit` product-scheme failure from the preserved S200 candidate |
| paths | `scripts/ci/swift-package.sh`; focused `scripts/ci/test-swift-package.py`; narrow fixtures under `scripts/ci/fixtures/swift-package/**`; only the NativeDesignKit leaf gate entry/prose needed to run the focused suite |
| excludes | root/nested `Package.swift` and locks; all product source/tests outside the focused fixture; semantic token data/schema/values; generated outputs; root/provider contracts; `scripts/verify`; hooks; workflows; CODEOWNERS; setup/Linux lanes; shared-ci pin/source; rulesets/settings; credentials; releases/tags/publication; registered S200 worktree/candidate/snapshot |
| contract impact | fixes only native iOS gate scheme selection. Expected test targets come from `swift package dump-package`; candidates come from machine-readable Xcode scheme metadata and are checked by machine-readable test enumeration for the selected simulator destination. Selection requires exactly one usable candidate enumerating every declared test target. No first-entry rule, name/suffix hardcode, unchecked product-scheme fallback, `only-testing`, skip, xfail, removed product/test, or weakened assertion is allowed. Missing, malformed, empty, ambiguous, unusable, or incomplete metadata fails before the final test action. |
| task-local acceptance | `P190-AC-001`: the unchanged real one-product root executes its actual `NativeDesignKitTests` through `scripts/ci/swift-package.sh ios` and passes `scripts/verify --all`; a simulated fixture alone does not satisfy this. `P190-AC-002`: a real minimal two-library-product/two-test-target Swift fixture executes both `NativeDesignKitTests` and `DesignTokensTests` through the same helper with no filtered test selection. `P190-AC-003`: reordering schemes does not change the selected usable scheme. `P190-AC-004`: missing/malformed/empty metadata and zero usable candidates fail closed. `P190-AC-005`: two usable complete candidates fail as ambiguous. `P190-AC-006`: a candidate omitting either declared test target fails as incomplete. `P190-AC-007`: all excluded gate/product/policy bytes remain unchanged; exact candidate review, normal hooks, delegated Owner approval, required CI, PR Manager merge and merged-main readback bind one head. |
| verification | focused parser/command-harness negatives for `P190-AC-003`–`006`; real task-local two-product iOS fixture with machine-readable executed-test evidence naming both test targets; actual one-product `scripts/ci/swift-package.sh ios`; `scripts/verify --all`; `git diff --check`; exact path/exclusion/blob audit; frozen-candidate AI Reviewer PASS with publication permission; local = remote = PR head reconciliation; Owner approval and required checks; merged-main helper/test/fixture/leaf-wiring blob readback |
| depends on | P175 actual merge/readback; exact S100 target base `5eec04eac574e41586e0c42732faa623e64cf9f9` |
| blocks | every S200/S300 task; the staged S200 candidate remains untouched until this prerequisite actually merges and is read back |

## `S200` — Local Swift activation and version-matched contracts

Observable PR intent: **After this PR, a public exact revision of
shared-design-system supplies both stable Swift products with NativeDesignKit
using the local DesignTokens target and version-matched migration contracts.**

- [ ] T210 [US2] Publish both root Swift products and replace the external package edge with the local DesignTokens target.
- [ ] T215 [US2] Enforce DesignTokens-only watchOS support without exposing NativeDesignKit as a watchOS component library.
- [ ] T220 [US2] Prove NativeDesignKit source/API/visual/error behavior remains unchanged through activation.
- [ ] T230 [US2] Update the nested DesignTokens contract and public consumers for the new repository route.
- [ ] T240 [US2] Update NativeDesignKit/root discovery, compatibility, migration, and rollback contracts.
- [ ] T250 [US2] Make local verification prove every layer/artifact and preserve the S100 CI companion that proves the later public SHA.
- [ ] T260 [US2] Freeze, independently review, hook-verify, publish, then require exact-public-SHA CI before delivery.

| Task | Owner layer/area | In-scope paths | Contract / task-local acceptance | Verification | Depends on |
| --- | --- | --- | --- | --- | --- |
| `T210` | repository support / Swift package integration | root `Package.swift`, `Package.resolved` as applicable, `AGENTS.md`, and architecture dependency/authority declarations | Root products/modules are exactly `DesignTokens` and `NativeDesignKit`; Native target depends on local DesignTokens; the old provider URL/package is absent from active root resolution and root `AGENTS.md`; executable resolution and documented authority agree; package floors are iOS15/macOS12/watchOS8. The original writer integrates the actual P190 merged base into the preserved registered candidate without replacing its worktree or resetting its repair history. | `swift package dump-package`; root resolve/build/test; manifest/`AGENTS.md` negative search for active external dependency; context/authority audit; P175 three-blob merge-receipt readback; P190 merged helper/test/wiring blob readback and preserved-candidate snapshot reconciliation | P175 and P190 actual merge/readback; Team Lead bounded continuation to the original S200 writer |
| `T215` | NativeDesignKit | one new platform-boundary source file plus an external negative compile fixture; no component implementation file | DesignTokens-only watchOS consumer builds. Selecting NativeDesignKit for watchOS fails with the documented stable unavailable diagnostic before component use. iOS/macOS API and behavior are unchanged; no watchOS component implementation is added. | watchOS DesignTokens-only compile; negative NativeDesignKit watchOS compile matching the diagnostic; iOS/macOS package build/tests | `T210` candidate |
| `T220` | NativeDesignKit | Native tests/fixtures only when needed for migration regression; existing production source is inspection-only except the exact T215 platform guard | Native public API and accepted Button/Card/List blobs/semantics remain unchanged. Explicit themes, exact errors, five palettes, Solid/Glass/fallback stay. Deferred Button input assertions/history remain unchanged and are not rerun as claimed evidence. | baseline blob comparison; existing package tests; applicable actual fixture regression without unchanged pointer diagnosis; no removed/weakened test diff | `T215` |
| `T230` | Tokens | `Packages/DesignTokens/ai/**`, nested compatibility/migration/changelog, contract checker/tests, and Node/package examples | Contract names the new target URL/revision route while preserving npm artifact identity/exports and documenting the unchanged public Swift interface. Old immutable versions remain documented. Swift target-revision resolution is owned by T260 after push, not this contract task. | nested AI checker/tests; packed Node consumer; contract byte/version/surface checks | `T210` |
| `T240` | NativeDesignKit contract | root `ai/**`, root `README.md`, compatibility/migration/integration/examples/registry/checker tests as necessary | Root README and version-matched contract discover both release units, replace the stale external-provider route, explain local target dependency and consumer manifest migration, preserve Native release/unreleased split, rollback, accepted component evidence, and deferred Button truth. | root contract checker/tests; README/`AGENTS.md`/manifest authority consistency; broken-pointer/version negative fixtures; local-path consumer fixture compiling public imports without a public-resolution claim | `T210`, `T220`, `T230` contract location fixed |
| `T250` | repository support / integration | `scripts/ci/external-consumer.py`; `scripts/ci/test-ai.py`; `Tests/Fixtures/LocalConsumer/verify.py`; their focused tests/fixtures; and the three S200 leaf gate declarations | The P190-merged helper/tests/leaf wiring, S100 hook, `scripts/verify`, CI caller, setup wrapper, Linux Tokens lane, and Owner-routing policy remain byte-identical during S200. Generic layer routing runs every local gate, exact ten-output generation check, local-path Swift consumer, and real packed npm consumer before push. The configured local-consumer evidence directory is fresh and task-owned; the harness passes that exact path and reads only that run's receipt. Receipt state starts failed/unknown and becomes `passed` only after Swift exit, the exact required marker, product/local-only assertions, and every other success condition are validated; every error retains durable truthful failed evidence. Focused regressions cover a non-default configured output path and zero Swift exit with a missing/drifted marker. The P175 receipt is present, and provider freeze plus target `Package.swift`/lock/`AGENTS.md`/README/contexts agree on authority. The CI companion imports both Swift products only after the pushed target SHA is fetchable. Missing/cancelled/skipped/mismatched resolution fails; no path/mirror/stale-receipt fallback may count as evidence. Any further normal-entry/helper/workflow change is a contract blocker returned to Team Lead. | pre-push `scripts/verify`; `scripts/verify --all`; P190 helper/test/wiring blob equality; explicit configured-output regression; zero-exit/missing-or-drifted-marker negative receipt regression; fresh receipt path/run-identity assertion; exact ten-output check; S100 hook/caller/setup/CODEOWNERS blob comparison; workflow lint; contract/authority audit; P175 receipt readback; local-path Swift consumer; real nested npm tarball consumer; post-push public route is deliberately not claimed here | `T220`, `T230`, `T240`; P190 actual merge/readback |
| `T260` | integration evidence | no extra tracked scope | One frozen clean candidate has exact provider/import/P175/P190 provenance, current local results, and AI Reviewer pre-push PASS before the normal hook-protected push. Only after publication, the pushed branch and PR `headRefOid` are reconciled to local HEAD; required CI's existing companion resolves that exact public SHA and imports both products before delivery. Protected-path Owner review and every real required gate bind the same head. Any byte change during push reconciliation or repair invalidates all candidate evidence and restarts freeze, local verification, exact-head review, push, public-SHA CI, and reconciliation. The Owner-directed continuation retains all earlier S200 repair/review history; it is not a fresh automatic round. | captured local/remote/PR SHA equality after push; exact-public-SHA consumer receipt from required CI; P175 merge receipt; P190 merge/readback receipt; check rollup at head; diff path audit; reviewer verdict; explicit no-byte-change reconciliation | `T250` |

S200 excludes semantic data/value/schema changes, generated-value changes,
component/API redesign, new platform components, provider release/tag, npm
publication, and repository settings.

## `S300` — Exact-head consolidation and retirement readiness

This is one acceptance/evidence outcome, not a code PR unless an owning
S100/P175/S200 defect is routed back and corrected there.

- [ ] T310 [US3] Re-run isolated public Node and Swift consumers against the exact merged consolidation revision.
- [ ] T330 [US3] Produce the concrete consumer migration, history/tag mapping, rollback, and old-repository retirement packet for Root.
- [ ] T320 [US3] Finally reconcile every acceptance row, architecture, baseline behavior, provenance, checks, reviews, and unchanged-scope evidence.

| Task | Owner layer/area | In-scope evidence | Acceptance / verification | Depends on |
| --- | --- | --- | --- | --- |
| `T310` | integration verification | disposable external consumers and receipts outside tracked source | Node installs actual nested tarball; Swift resolves public target URL at exact merged SHA, imports both products, runs public behavior tests, and has no old provider URL/identity in resolution. Record hashes, lock, commands/exits/counts. | S200 merged and exact merge SHA fetchable |
| `T330` | repository support / decision packet | read-only consumer discovery plus reviewed migration/retirement/rollback docs, P175 receipt, and release mapping | Known consumers and limitations are listed. Historical tag/URL availability and the already-landed three-file provider quiescence notice are proven. Packet recommends a consolidated `v0.3.0` candidate and separately identifies archive/settings/release decisions; it rejects delete/rename/transfer/rewrite/mirror. No external mutation occurs. | `T310` |
| `T320` | integration verification | target/provider main, PR/check/review/provenance readbacks, T330 packet, and the canonical acceptance matrix | Every one of the 26 AC rows has cited producer and final evidence; the T330 consumer/retirement/rollback/release packet and P175 receipt are reconciled; three-layer audit/gates pass; native baseline blobs/tests and Button deferral history are intact; no unrequested source/test/policy change; local/remote/merge/check SHAs are reconciled. A stale or partial result is `unverified`, not pass. | `T330` |

## Decision boundary `D400`

Root/Owner chooses whether and when to authorize:

1. the first unified consolidated Swift tag (recommended `v0.3.0`);
2. any Native release notes/artifacts;
3. any DesignTokens npm tarball release and whether registry publication remains
   disabled (default: disabled);
4. GitHub archive/read-only settings after consumer and rollback evidence.

Until that explicit decision, no agent tags, releases, changes credentials or
repository settings, makes any further old-repository edit beyond merged P175,
or calls consolidation fully retired. Old tags/commits remain accessible in
every outcome.

## Canonical acceptance-to-task matrix

This is the sole operational AC mapping. Every producer has a dependency path to
the universal final evidence task `T320`; `D400` is never an acceptance producer.

| Acceptance ID | Producing slice/task(s) | Final evidence task | Downstream decision |
| --- | --- | --- | --- |
| `AC-REVIEW-001` | P050 `T050`; S100 `T150` | `T320` | — |
| `AC-AUTH-001` | S100 `T110`, `T130`, `T150` | `T320` | — |
| `AC-AUTH-002` | P175 `T175`; S200 `T210`, `T240`, `T260`; S300 `T330` | `T320` | `D400` archive/settings only |
| `AC-LAYER-001` | S100 `T130`; S200 `T210`, `T250` | `T320` | — |
| `AC-LAYER-002` | S100 `T120`; S200 `T210`, `T250` | `T320` | — |
| `AC-GEN-001` | S100 `T110`, `T150`; S200 `T250` | `T320` | — |
| `AC-SWIFT-001` | S100 `T120`; P190 `T190`; S200 `T210`, `T215`; S300 `T310` | `T320` | — |
| `AC-SWIFT-002` | S100 `T120`; S200 `T230`; S300 `T310` | `T320` | — |
| `AC-NATIVE-001` | S200 `T215`, `T220`, `T260` | `T320` | — |
| `AC-NATIVE-002` | S200 `T220`, `T250` | `T320` | — |
| `AC-NATIVE-003` | S200 `T220`, `T240` | `T320` | — |
| `AC-WEB-001` | S100 `T110`, `T130`, `T140`; S200 `T230`; S300 `T310` | `T320` | — |
| `AC-CONTRACT-001` | S100 `T140`; S200 `T230`, `T240`, `T250` | `T320` | — |
| `AC-VERIFY-001` | S100 `T130`, `T150`; P190 `T190`; S200 `T250`, `T260` | `T320` | — |
| `AC-CONSUMER-001` | S100 `T140`; S200 `T230`, `T250`, `T260`; S300 `T310` | `T320` | — |
| `AC-CONSUMER-002` | S200 `T230`, `T250`, `T260`; S300 `T310` | `T320` | — |
| `AC-EVIDENCE-001` | S100 `T150`; P175 `T175`; P190 `T190`; S200 `T260` | `T320` | — |
| `AC-HISTORY-001` | S100 `T110`, `T130`, `T150` | `T320` | — |
| `AC-HISTORY-002` | P175 `T175`; S200 `T230`, `T240`; S300 `T330` | `T320` | `D400` release choice only |
| `AC-COMPAT-001` | S200 `T210`, `T230`, `T240`; S300 `T310` | `T320` | — |
| `AC-COMPAT-002` | P175 `T175`; S200 `T240`; S300 `T330` | `T320` | — |
| `AC-RETIRE-001` | S300 `T330` | `T320` | — |
| `AC-RETIRE-002` | P175 `T175`; S300 `T330` | `T320` | `D400` archive/settings only |
| `AC-ROLLBACK-001` | P175 `T175`; S200 `T230`, `T240`; S300 `T330` | `T320` | — |
| `AC-SCOPE-001` | P050 `T050`; S100 `T110`, `T120`, `T130`, `T140`, `T150`; P175 `T175`; P190 `T190`; S200 `T210`, `T215`, `T220`, `T230`, `T240`, `T250`, `T260`; S300 `T310`, `T330` | `T320` | — |
| `AC-SCOPE-002` | P001 `T001`; P050 `T050`; S100 `T110`, `T120`, `T130`, `T140`, `T150`; P175 `T175`; P190 `T190`; S200 `T210`, `T215`, `T220`, `T230`, `T240`, `T250`, `T260`; S300 `T310`, `T330` | `T320` | — |

All implementation tasks have one owning layer/area, explicit paths, exclusions,
contract effect, verification, and blocking edges. No task requires Fullstack to
invent product behavior or a release/settings decision.

## Planning publication gate

Before handing this graph to Team Lead:

1. only this plan and task graph differ from exact S100 base
   `5eec04eac574e41586e0c42732faa623e64cf9f9`; the accepted ADR/spec and all
   product/gate bytes remain unchanged;
2. `git diff --check` and the repository's normal planning-safe verification
   pass at the candidate revision;
3. planning checks prove the canonical matrix has exactly one row for every spec
   AC, every task including P190/T190 exists in its stated slice, every producer
   reaches T320 in the DAG, P190 merge/readback blocks S200, T330 precedes T320,
   and D400 appears only in the three permitted downstream-decision cells;
4. the exact commit plus supplemented plan/tasks blob SHAs and unchanged accepted
   ADR/spec blob SHAs are recorded;
5. an independent AI Reviewer returns architecture/spec `PASS` for that exact
   revision; and
6. any byte change after review triggers a fresh gate.

Planner does not implement P050/S100/P175/P190/S200, create implementation children
before PASS, assign roles, merge, release, mutate the old repository, or decide
D400.
