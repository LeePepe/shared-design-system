# NativeDesignKit v1 reconciliation plan

Status: proposed for independent exact-revision spec-gate review

Specification: `docs/native-design-kit-v1-spec.md`

Task and disposition graph: `docs/native-design-kit-v1-tasks.md`

## Planning provenance

| Field | Value |
|---|---|
| issue | `MY-1569` / `01a0c22f-c77d-7813-8fda-f1086df78681` |
| current dispatch | Team Lead recovery comment `01a14638-a5a1-789c-85b7-cc3efa633330` |
| canonical repository | `https://github.com/LeePepe/shared-design-system.git` (`1380829390`) |
| exact evidence base | `main@6d8dbe1ef5753978bc3a5e0b472af829819537ac` |
| local layer | `NativeDesignKit` |
| released contract | `0.1.0` / `NativeTokenColor` |
| current source state | ten additive Strata components, unreleased |
| external dependency | `shared-design-tokens` exact `0.1.1`, resolved `234b7d0b058474f1aa3f0edeab1be6084ad7eca5` |
| platforms | Swift 6, iOS 15+, macOS 12+ |

This plan replaces stale evidence from `main@850fc34b...`. It does not reuse or amend the old planning branch or abandoned PR #11. The prepared checkout is reused only as a working directory; this revision starts from the exact evidence base on a fresh planning branch.

## Planning decisions

1. **Reconcile rather than revive.** The 13 original AC IDs remain traceability keys. Owner-authorized Strata APIs and evidence decide their disposition; the old source snippets and T201–T501 do not regain authority.
2. **Separate shipped compatibility from unreleased source.** The released registry and general integration contract remain 0.1.0 resolver-only. Component contracts and the Unreleased changelog accurately represent the exact-revision Strata source. A release contract requires a later Owner decision.
3. **Treat intentional API replacement explicitly.** Theme and Card satisfy the original behavioural outcomes through accepted current shapes. The old signatures are not missing work.
4. **Do not infer product scope.** Metric, StatusBadge, ChartContainer, and ContentStateView are absent from the accepted ten-component rebuild. Only a new Owner decision can make them future work.
5. **Reuse truthful evidence.** Package tests, component iOS fixtures, PR evidence, the 72-image gallery, and exact-main CI are reusable evidence. They are not stretched to prove live VoiceOver, macOS rendering, minimum OS, a final-head all-fixture run, or server enforcement they did not observe.
6. **Replace the fixture graph, not its topology.** Current component-owned fixtures and shared support replace the old single showcase. A future evidence slice extends that current topology to complete iOS accessibility and macOS rendering.
7. **Keep protected gate work separate.** The fixture command is declared in the layer tech-context only after the aggregate runner exists and passes. No workflow, policy, or `scripts/verify` edit is planned.
8. **Make the final node read-only.** Exact-head online checks and effective ruleset state are observed separately. Missing permission or evidence is blocking/unverified; the verifier never changes repository settings.
9. **Preserve cancellation history.** MY-1707 stays cancelled, PR #11 stays abandoned, and MY-1708–MY-1712 are recommended for cancellation/replacement by Team Lead. Planner does not mutate them.
10. **Planning-only publication.** This PR changes only the three v1 planning documents and requests AI Reviewer review on their exact blobs.

## Current architecture

```text
caller-selected DesignTokens.Theme + provider brand
                       │ explicit throwing construction
                       ▼
              NativeDesignTheme
                       │ token-backed immutable values
          ┌────────────┼───────────────────────────────┐
          ▼            ▼                               ▼
  NativeSurfaceStyle   Controls                     Components
                       Button                       Card
                       TextField                    Avatar
                       Switch                       Chip
                       Checkbox
                       RadioGroup
                       Slider
                       ProgressBar
```

All of this remains one local `NativeDesignKit` layer. `DesignTokens` is an exact external dependency. Callers retain product data, navigation, persistence, analytics, localization content, and state meaning.

The former Metric/Badge/Chart/ContentState branch is not part of this architecture. A future component decision must start from the diagram above rather than the old v1 branch.

## Evidence already on main

### Completed delivery graph

```text
released 0.1.0 baseline
  → PR #15 Strata theme authority
    → PR #16 Button + common theme/surface/fixture support
      ├─→ PR #17 Switch
      ├─→ PR #18 Checkbox
      └─→ PR #19 Card
            ├─→ PR #20 Avatar
            └─→ PR #21 TextField
                  → PR #22 Chip
                    → PR #23 RadioGroup
                      → PR #24 Slider
                        → PR #25 ProgressBar
all PRs #16–#25
  → PR #26 inventory/changelog convergence
    → main@6d8dbe1ef5753978bc3a5e0b472af829819537ac
```

This is historical dependency evidence, not a relabelling of those PRs as old T101–T501.

### Reusable verification evidence

- Exact main passed contract checks, macOS host build/tests, iOS simulator package build/tests, and pushed-SHA external consumer verification; observed counts were 30 host tests, 30 iOS tests, and two external-consumer tests.
- Exact-main Actions run `38896539758`, job `116958302770`, concluded successfully and recorded `EXTERNAL_OK` for `6d8dbe1...`.
- Effective ruleset `23925002` requires `quality / aggregate` and `codex-review-gate`. Internal quality jobs and `codex-review-target` may run without being separately enforced and must be reported as such.
- Ten iOS fixture apps contain synthetic data, use portable relative package references, and produce exact-SHA external run records and named screenshots.
- PRs #16–#25 record independent source/evidence/PNG review. PR #26 records a byte-identical aggregate tree for its head and merge plus 72/72 gallery hashes matching.

### Evidence limits

- Fixture screenshots do not prove live VoiceOver speech or order.
- All current rendered fixture projects are iOS-only; macOS host package tests are not rendered macOS UI evidence.
- The current runner is not in `scripts/verify`, the layer gate map, or CI.
- No one frozen current head ran all ten fixture commands and a macOS matrix.
- Minimum deployment OS runtime, external keyboard, macOS focus/activation, and window resizing remain unverified.
- Conditional skipped lanes and any failed/cancelled earlier run are reported separately; they are never converted to success by a later run.

## Replacement dependency graph

The normative recommendation is:

```text
main@6d8dbe1 evidence
  → P100 reconciliation planning PR
    → exact-revision AI Reviewer PASS
      → Team Lead tracker reconciliation
        → [separate Team Lead/Owner authorization]
          → R101 current-inventory accessibility + dual-platform fixture evidence
            → R201 protected aggregate fixture-gate declaration
              → R301 read-only post-merge exact-main integration evidence
```

The graph is acyclic. `P100` is the current Planner-owned publication. `R101` and `R201` are fresh, conditional future implementation tasks, each one branch/worktree/PR. `R301` is read-only and owns final evidence, not a branch or PR. No R-node is dispatched by planning approval alone.

Two decision nodes sit outside that verification chain:

- `D-COMPONENTS`: Owner decides whether any superseded Metric/StatusBadge/ChartContainer/ContentState outcome enters a future Strata batch. A yes produces a new spec and task graph; it does not amend R101.
- `D-RELEASE`: Owner decides component release/version and machine-contract scope before any tag. A yes produces its own reviewed release/contract plan; it is not inferred from R301.

## Layer and path ownership

| Node | Owned repository paths | Layer / review rule |
|---|---|---|
| `P100` | `docs/native-design-kit-v1-spec.md`, `docs/native-design-kit-v1-plan.md`, `docs/native-design-kit-v1-tasks.md` | root support; planning-only normal PR |
| `R101` | `Tests/Fixtures/Support/**` and the ten existing `Tests/Fixtures/{Avatar,Button,Card,Checkbox,Chip,ProgressBar,RadioGroup,Slider,Switch,TextField}Review/**` trees | `NativeDesignKit`; test/evidence slice; no production source or public API |
| `R201` | `docs/architecture/native-design-kit/tech-context.md` only | protected `NativeDesignKit` architecture/gate declaration; Owner review |
| `R301` | none | read-only final evidence owner |

`Package.swift`, `Package.resolved`, `Sources/**`, `ai/**`, `CHANGELOG.md`, `scripts/**`, `.github/**`, token data, and repository settings are inspection-only for R101–R301. A concrete need to change one stops the affected node for a reviewed plan revision; it is not absorbed as incidental work.

## Verification contracts

### P100 planning publication

Before commit and against the final planning commit:

```sh
git diff --check
scripts/verify
```

The planning review also verifies:

- the diff contains only the three declared documents;
- all 13 original AC IDs appear exactly once in the disposition matrix;
- every graph node and dependency exists and the graph is acyclic;
- all parked children have an explicit recommendation;
- local HEAD, pushed branch SHA, and PR `headRefOid` are identical;
- the three artifact blob SHAs are recorded.

### R101 current-inventory evidence slice

R101 preserves the ten component public APIs and adds no product component. Its aggregate runner contract is:

```sh
python3 Tests/Fixtures/Support/run-all.py --platform ios --ci
python3 Tests/Fixtures/Support/run-all.py --platform macos --ci
python3 Tests/Fixtures/Support/run-all.py --platform all --ci
```

R101 implements this repository-owned interface over the ten component-owned fixtures. It creates isolated external output directories, records the clean tested SHA, serializes shared simulator use, names the resolved destinations/runtimes, preserves nonzero command/export failures, and rejects missing fixture cells. Generated projects, DerivedData, result bundles, logs, reviews, and screenshots remain outside git.

Required evidence matrix:

| Platform | Required cells |
|---|---|
| iOS | 320 pt and 430 pt representative widths; light/dark; default, XXXL, and an accessibility Dynamic Type size; native touch/editing/disabled-state actions |
| macOS | 480×320 and 1000×700 windows; light/dark; default and accessibility typography; keyboard focus/activation and resize |
| declared floors | explicit iOS 15 and macOS 12 runtime result, or `unverified` with the AC left open; a newer runtime is not minimum-OS proof |
| accessibility | live VoiceOver label/value/order/state record for the current inventory plus a named independent objective review; screenshots alone are insufficient |

R101 also runs:

```sh
scripts/verify --layer NativeDesignKit
scripts/verify --all
python3 scripts/ci/external-consumer.py --revision "$(git rev-parse HEAD)"
```

The external-consumer command runs only after the candidate is pushed/reachable. Evidence records commands, exit codes, test counts, skipped/cancelled checks, destinations, exact SHA, matrix cells, artifact links/hashes, and reviewer identity/result.

### R201 protected gate declaration

After the exact R101 runner passes, R201 adds one gate entry to `docs/architecture/native-design-kit/tech-context.md`:

```yaml
fixtures: python3 Tests/Fixtures/Support/run-all.py --platform all --ci
```

No existing gate, red line, owner, dependency, workflow, or script changes. Negative proof demonstrates that a missing fixture, failed UI test, missing evidence cell, export failure, or cancelled run fails layer and full verification.

Verification:

```sh
scripts/verify --layer NativeDesignKit
scripts/verify --all
```

### R301 post-merge exact-main integration evidence

R301 runs after R201 is squash-merged. Its sole acceptance target is the exact
R201 `mergeCommit.oid` on `main`, not the retained R201 PR head and not an
unspecified later `main` tip. The verifier fetches that commit into the same
registered, clean workspace, checks it out detached, and records whether the
observed `origin/main` still equals it or has advanced while retaining it as an
ancestor. R301 then runs local verification and reads the workflow/check runs
whose `headSha` is exactly that merge commit:

```sh
git fetch origin main
git switch --detach <R201-main-merge-SHA>
test "$(git rev-parse HEAD)" = "<R201-main-merge-SHA>"
git merge-base --is-ancestor <R201-main-merge-SHA> origin/main
scripts/verify --layer NativeDesignKit
scripts/verify --all
python3 Tests/Fixtures/Support/run-all.py --platform all --ci
python3 scripts/ci/external-consumer.py --revision "$(git rev-parse HEAD)"
gh pr view <R201-PR-number> --repo LeePepe/shared-design-system --json headRefOid,mergeCommit,mergedAt,baseRefName,url,statusCheckRollup
git diff --exit-code <R201-PR-head> <R201-main-merge-SHA> -- docs/architecture/native-design-kit/tech-context.md
git rev-parse <R201-PR-head>:docs/architecture/native-design-kit/tech-context.md <R201-main-merge-SHA>:docs/architecture/native-design-kit/tech-context.md
gh run list --repo LeePepe/shared-design-system --commit <R201-main-merge-SHA> --json databaseId,headSha,event,status,conclusion,url
gh api 'repos/LeePepe/shared-design-system/commits/<R201-main-merge-SHA>/check-runs'
gh api --paginate 'repos/LeePepe/shared-design-system/rulesets?includes_parents=true'
gh api 'repos/LeePepe/shared-design-system/rules/branches/main'
gh api --include 'repos/LeePepe/shared-design-system/branches/main/protection/required_status_checks'
```

It separately reports:

1. local commands, exit codes, counts, destinations, and skipped/cancelled work;
2. iOS/macOS/minimum-OS/accessibility matrix and independent review;
3. local HEAD = R201 `mergeCommit.oid`, plus the observed `origin/main` tip and
   equality-or-ancestry result;
4. byte-identical R201-owned-path provenance between the retained PR head and
   squash commit, using the path diff above and both blob OIDs;
5. exact-main workflow/check names, conclusions, URLs/run IDs, event, and
   `headSha` equal to the R201 merge commit;
6. R201 PR-head checks in a separate table, never substituted for exact-main
   workflow evidence and never claimed SHA-equal to the squash commit;
7. effective ruleset/branch-protection IDs, enforcement, and required contexts;
8. set comparison of required checks, exact-main checks, PR-only checks,
   present-but-unenforced checks, and skipped/cancelled checks;
9. exact dependency/platform/source/contract compatibility and remaining risks.

Squash merge necessarily gives the main commit a different commit SHA from the
R201 PR head; no equality across that boundary is expected or claimed. The
owned-path content comparison is the provenance bridge. Workflow files express
intent but do not prove either exact-main execution or server enforcement. If
the exact-main run is absent, the owned-path content differs, or an API or
permission gap prevents effective enforcement evidence, R301 reports
`unverified` and remains open. It never changes repository settings.

## Contract, release, and product follow-ups

The current released/unreleased documentation split remains unchanged by P100–R301. Before a component release, `D-RELEASE` must establish a reviewed exact version and atomic path set for the registry, schema, examples, checker tests, fixed-version integration, compatibility, migration/rollback, changelog, tag, and release evidence.

Likewise, `D-COMPONENTS` must precede any source work for old missing outcomes. A new plan must define current-theme signatures, token roles supported by the exact dependency, source/test/fixture/contract paths, compatibility, and evidence. Copying old v1 signatures is prohibited.

## Risks and controls

| Risk | Control / owner |
|---|---|
| Historical IDs are mistaken for implementation authorization | Spec uses explicit satisfied/partial/superseded dispositions; Team Lead alone schedules fresh R-nodes after review. |
| Current Chip is misrepresented as StatusBadge | Mapping calls it only a partial analogue; no name or contract substitution occurs. |
| Host tests are misreported as macOS rendered UI | R101 requires a real macOS fixture/window/focus matrix and exact runtime evidence. |
| Screenshots are misreported as VoiceOver proof | R101 requires a live label/value/order/state record and named independent review. |
| Unreleased source is mistaken for a tagged contract | Released registry remains 0.1.0; D-RELEASE is mandatory before tagging components. |
| Fixture work weakens existing gates or broadens source scope | R101 is test-only; R201 is one protected declaration; existing gate inventory must remain intact. |
| CI presence is mistaken for enforcement | R301 reads exact-main workflow/check runs, R201 PR checks, and effective rules separately and compares their sets. |
| Evidence becomes stale after a correction | Any tracked correction produces a new candidate SHA and reruns all affected local, fixture, external, online, review, and SHA-reconciliation evidence. |

## Entry and exit gates

P100 exits only when its exact commit is pushed in a normal non-draft PR to `main`, the three blobs match, and AI Reviewer returns `PASS` on that immutable revision. Planner then returns the SHA, blob set, AC mapping, graph, and child recommendations to Team Lead; Planner does not merge or mutate child issues.

R101–R301 have no entry authorization until Team Lead explicitly schedules them after reviewed planning. D-COMPONENTS and D-RELEASE remain Owner decisions, not inferred implementation work.
