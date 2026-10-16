# NativeDesignKit v1 reconciliation and replacement graph

Status: proposed for independent exact-revision spec-gate review

Specification: `docs/native-design-kit-v1-spec.md`

Plan: `docs/native-design-kit-v1-plan.md`

## Execution rules

- This graph records disposition and recommends fresh work; it does not authorize implementation, release, merge, or tracker mutation.
- The completed Strata PRs remain their own deliveries. They are evidence inputs and are never relabelled as old T101–T501.
- MY-1707 remains cancelled and PR #11 remains closed/unmerged. MY-1708–MY-1712 remain untouched until Team Lead applies the reviewed recommendations below.
- Every dispatchable replacement task owns one branch/worktree, one fixed candidate, one independent content review, and one normal PR. Internal steps are not separate publishable candidates.
- All replacement implementation remains within the existing `NativeDesignKit` layer. `DesignTokens` is an exact external dependency and has no task to modify it.
- `Package.swift`, `Package.resolved`, production source, `ai/**`, changelog, scripts outside fixture support, workflows, policies, token sources, and repository settings are inspection-only for R101–R301.
- Protected `docs/architecture/**` work is isolated in R201 and requires Owner review. No existing gate or red line may be removed or weakened.
- Every evidence owner records exact commands, exit codes, test counts, destinations, skipped/cancelled checks, tested SHA, and local/remote/PR SHA equality. A skipped, cancelled, package-only, screenshot-only, or newer-runtime result is not success for the missing evidence it does not cover.

## Graph

```text
completed Strata graph + main@6d8dbe1 evidence
  → P100 planning reconciliation
    → exact-revision AI Reviewer PASS
      → Team Lead child disposition and scheduling decision
        → [explicit later authorization]
          → R101 accessibility + dual-platform component-fixture evidence
            → R201 protected aggregate fixture-gate declaration
              → R301 read-only exact-SHA integration evidence

D-COMPONENTS Owner decision ──yes──→ fresh component spec/plan/tasks
D-RELEASE Owner decision ─────yes──→ fresh release/contract plan
```

The graph is acyclic. P100 is the only active task in this planning revision. R101 and R201 are conditional future one-PR tasks; R301 is a future read-only gate. D-COMPONENTS and D-RELEASE are decision boundaries, not implementation tasks.

## `P100` — Exact-main reconciliation planning

- **Owner:** Planner Lead
- **Kind:** current planning publication; one planning branch and normal non-draft PR
- **Outcome:** Replace historical v1 meaning with an exact-main disposition of all 13 stable AC IDs, a truthful completed-delivery graph, a conditional replacement verification graph, and child recommendations.
- **Depends on:** `main@6d8dbe1ef5753978bc3a5e0b472af829819537ac`
- **Only paths:** `docs/native-design-kit-v1-spec.md`, `docs/native-design-kit-v1-plan.md`, `docs/native-design-kit-v1-tasks.md`
- **Covers:** reconciliation of all original ACs; no component implementation AC is claimed by this docs change
- **Required checks:**

  ```sh
  git diff --check
  scripts/verify
  ```

- **Required publication evidence:** planning diff contains only the three paths; one Conventional Commit; local HEAD = pushed branch = PR `headRefOid`; base is `main`; artifact blob SHAs for all three documents; AI Reviewer exact-revision Standards `PASS` and Spec `PASS`.
- **Excludes:** source/tests/fixture/contract/gate/manifest/token edits; old branch/PR revival; child status changes; merge; implementation; release.
- **Invalidation:** any byte change to the commit or bound artifacts requires a fresh exact-revision review.

## `R101` — Current-inventory accessibility and dual-platform fixture evidence

- **Owner:** one Fullstack Engineer selected by Team Lead after explicit authorization
- **Kind:** conditional future `NativeDesignKit` test/evidence task; one branch/worktree/PR
- **Outcome:** Extend the accepted component-owned fixture system so one aggregate command verifies all ten current Strata components on iOS and macOS and produces the missing accessibility/platform evidence on one frozen SHA.
- **Depends on:** P100 reviewed and reconciled by Team Lead; explicit Team Lead scheduling; no newer contract invalidating the plan
- **Covers:** remaining evidence for `AC-A11Y-01`, `AC-PLATFORM-01`, and `AC-FIXTURE-01`; fixture portion of `AC-VERIFY-01`
- **Allowed paths:**
  - `Tests/Fixtures/Support/**`
  - `Tests/Fixtures/AvatarReview/**`
  - `Tests/Fixtures/ButtonReview/**`
  - `Tests/Fixtures/CardReview/**`
  - `Tests/Fixtures/CheckboxReview/**`
  - `Tests/Fixtures/ChipReview/**`
  - `Tests/Fixtures/ProgressBarReview/**`
  - `Tests/Fixtures/RadioGroupReview/**`
  - `Tests/Fixtures/SliderReview/**`
  - `Tests/Fixtures/SwitchReview/**`
  - `Tests/Fixtures/TextFieldReview/**`
- **Interface impact:** test/fixture tooling only; no production or public API change
- **Required runner interface:**

  ```sh
  python3 Tests/Fixtures/Support/run-all.py --platform ios --ci
  python3 Tests/Fixtures/Support/run-all.py --platform macos --ci
  python3 Tests/Fixtures/Support/run-all.py --platform all --ci
  ```

- **Runner contract:** discover exactly the ten declared fixture directories; create isolated external build/evidence directories; serialize shared simulator use; resolve and print destination/runtime; record clean SHA and dirty state; fail on missing schemes, fixtures, cells, attachments, exports, tests, or commands; never commit generated projects, DerivedData, `.xcresult`, logs, or PNGs.
- **Required iOS evidence:** 320 pt and 430 pt representative widths; light/dark; default, XXXL, and accessibility Dynamic Type; native touch/editing/actions; disabled/loading state behaviour where supported; complete-content containment.
- **Required macOS evidence:** 480×320 and 1000×700 windows; light/dark; default and accessibility typography; keyboard focus/activation; resize; complete-content containment.
- **Required accessibility evidence:** fixture accessibility identifiers/labels/values/states; live VoiceOver label/value/order/state record; named independent objective review of screenshots and interaction evidence. Screenshots alone never pass VoiceOver.
- **Minimum-OS evidence:** execute on iOS 15 and macOS 12 runtimes where available and name the runtime. If either cannot be run, report `unverified`; do not substitute a newer runtime or change platform declarations.
- **Additional commands:**

  ```sh
  scripts/verify --layer NativeDesignKit
  scripts/verify --all
  python3 scripts/ci/external-consumer.py --revision "$(git rev-parse HEAD)"
  ```

  The external consumer runs only after the exact candidate is pushed/reachable.
- **Completion evidence:** command/exit/count table; ten-fixture discovery list; destination/runtime and matrix manifest; artifact links and hashes; live VoiceOver record; named independent review result; unchanged source/manifest/lock/token pin inspection; local/remote/PR SHA equality; independent publication permission.
- **Excludes:** a revived `NativeDesignKitShowcase`; public API/component work; registry/version/release changes; gate/tech-context/workflow edits; business apps/data; repository settings; synthetic VoiceOver or minimum-OS claims.

## `R201` — Protected aggregate fixture-gate declaration

- **Owner:** one Fullstack Engineer selected by Team Lead after R101 merges
- **Kind:** conditional future protected-governance task; one branch/worktree/PR
- **Outcome:** Make the already-merged, passing aggregate fixture runner part of resolver-driven NativeDesignKit verification.
- **Depends on:** merged R101 with complete evidence and exact runner interface
- **Covers:** gate portion of `AC-FIXTURE-01`, `AC-PLATFORM-01`, and `AC-VERIFY-01`
- **Only changed path:** `docs/architecture/native-design-kit/tech-context.md`
- **Exact declaration:**

  ```yaml
  fixtures: python3 Tests/Fixtures/Support/run-all.py --platform all --ci
  ```

- **Required negative proof:** all existing `docs`, `docs_test`, `build`, `test`, and `ios` gates remain byte-for-byte present; missing fixture/scheme/cell/evidence, nonzero UI test, failed export, or cancelled command makes layer/full verification fail; no skip/cancel-success path exists.
- **Commands:**

  ```sh
  scripts/verify --layer NativeDesignKit
  scripts/verify --all
  ```

- **Completion evidence:** before/after gate inventory; command/exit/count table; exact SHA equality; Owner review of the protected path; independent publication permission.
- **Excludes:** source/tests/fixture/scripts/workflow changes; policy weakening; repository settings; release or component work.

## `R301` — Read-only exact-SHA Strata integration evidence

- **Owner:** Team Lead-assigned read-only verifier after R201 and exact-head online CI conclude
- **Kind:** conditional future acceptance gate; no implementation branch or PR
- **Outcome:** On one clean pushed revision, reconcile the current Strata inventory, all replacement fixture evidence, local/full/external verification, exact-head online CI, effective server enforcement, and residual risks.
- **Depends on:** merged R201; concluded online CI for the exact revision; every effectively required check passing
- **Covers:** final evidence for satisfied/partial original AC dispositions, especially `AC-BASE-01`, `AC-BOUNDARY-01`, `AC-A11Y-01`, `AC-PLATFORM-01`, `AC-FIXTURE-01`, and `AC-VERIFY-01`. It does not convert superseded Metric/Badge/Chart/State or old contract requirements into passes.
- **Commands:**

  ```sh
  scripts/verify --layer NativeDesignKit
  scripts/verify --all
  python3 Tests/Fixtures/Support/run-all.py --platform all --ci
  python3 scripts/ci/external-consumer.py --revision "$(git rev-parse HEAD)"
  gh pr view <PR-number> --repo LeePepe/shared-design-system --json headRefOid,baseRefName,url,statusCheckRollup
  gh api --paginate 'repos/LeePepe/shared-design-system/rulesets?includes_parents=true'
  gh api 'repos/LeePepe/shared-design-system/rules/branches/main'
  gh api --include 'repos/LeePepe/shared-design-system/branches/main/protection/required_status_checks'
  ```

- **Evidence:**
  1. local command/exit/test-count/destination table and every skipped/cancelled lane;
  2. exact dependency, platform, source-boundary, released/unreleased contract, compatibility, and rollback audit;
  3. complete fixture matrix, exact-SHA manifest, artifact hashes, live VoiceOver record, and named independent review;
  4. local HEAD = remote branch = PR head/main proof;
  5. exact-head online check table with name, conclusion, URL/run ID, and observed SHA;
  6. effective ruleset/branch-protection table with rule IDs, enforcement, and actually required contexts;
  7. set comparison naming required checks, checks that ran, present-but-unenforced checks, skipped/cancelled checks, and any permission/API gap;
  8. residual gaps, including any unavailable minimum-OS or keyboard evidence.
- **Blocking rules:** workflow-file presence is not enforcement proof; package success is not fixture success; screenshots are not VoiceOver evidence; a newer OS is not minimum-OS evidence; unavailable server evidence is `unverified`. Any of these prevents the mapped partial AC from being closed.
- **Invalidation:** any tracked correction creates a new candidate SHA and repeats all affected local, fixture, external, online, review, and SHA-reconciliation evidence. There is no docs-only exception.
- **Excludes:** self-approval, source changes, merge, tag, publication, product adoption, settings changes, waivers, or claims for superseded outcomes.

## Decision boundary `D-COMPONENTS`

Owner decides separately whether any of these outcomes enter a future Strata batch:

- Metric with label/value/supporting content;
- three-tone info/warning/critical status badge;
- caller-owned generic chart shell;
- caller-owned four-phase content-state view.

No current task implements them. A positive decision requires a fresh exact API/token/platform/contract/evidence specification against current `NativeDesignTheme(theme:brand:)`, current surface policy, exact DesignTokens 0.1.1 capabilities, and the component-owned fixture system. Old v1 snippets and closed PR code cannot be copied as authority.

## Decision boundary `D-RELEASE`

Owner decides a release version and contract publication model before tagging the ten components. A positive decision must name the atomic path set and evidence for registry/schema, examples, checker tests, fixed-version integration, compatibility, migration/rollback, changelog, external consumer, tag, and release. Current `ai/registry.json` remains correct for released 0.1.0 until that reviewed work changes it.

## Original AC ownership after reconciliation

| Acceptance ID | Current disposition owner | Conditional gap owner | Final evidence owner |
|---|---|---|---|
| `AC-BASE-01` | completed main evidence | regression inspection in R101/R201 | R301 |
| `AC-BOUNDARY-01` | completed main evidence | negative-scope inspection in R101/R201 | R301 |
| `AC-THEME-01` | completed current replacement API | none; new changes require fresh plan | R301 records current evidence |
| `AC-CARD-01` | completed current replacement API | none; new changes require fresh plan | R301 records current evidence |
| `AC-METRIC-01` | D-COMPONENTS; superseded/absent | fresh task only after Owner yes | new plan, not R301 |
| `AC-BADGE-01` | D-COMPONENTS; superseded/partial analogue | fresh task only after Owner yes | new plan, not R301 |
| `AC-CHART-01` | D-COMPONENTS; superseded/absent | fresh task only after Owner yes | new plan, not R301 |
| `AC-STATE-01` | D-COMPONENTS; superseded/absent | fresh task only after Owner yes | new plan, not R301 |
| `AC-A11Y-01` | partial current evidence | R101 | R301 |
| `AC-PLATFORM-01` | partial current evidence | R101, R201 | R301 |
| `AC-FIXTURE-01` | partial replacement topology | R101, R201 | R301 |
| `AC-CONTRACT-01` | D-RELEASE; superseded/current split coherent | fresh release task only after Owner yes | new release plan, not R301 |
| `AC-VERIFY-01` | partial current evidence | R101, R201 | R301 |

Every ID has an explicit disposition and evidence owner. Superseded IDs deliberately do not receive implementation owners in this graph.

## Existing child recommendations

Planner recommends; Team Lead alone applies tracker changes.

| Child | Current state | Recommendation | Replacement |
|---|---|---|---|
| `MY-1707` | cancelled | preserve cancelled | none; PR #11 remains closed/unmerged |
| `MY-1708` | backlog, unassigned | cancel as superseded | none unless D-COMPONENTS later authorizes fresh Metric/StatusBadge planning |
| `MY-1709` | backlog, unassigned | cancel as superseded | none unless D-COMPONENTS later authorizes fresh Chart/ContentState planning |
| `MY-1710` | backlog, unassigned | cancel as superseded | fresh R101, because current component-owned fixtures replace the old single showcase |
| `MY-1711` | backlog, unassigned | cancel as superseded | fresh R201 after R101; never revive the nonexistent showcase path |
| `MY-1712` | backlog, unassigned | cancel as superseded | fresh read-only R301 bound to this reviewed graph and the current inventory |

No old child is rebound in place: its title, path ownership, dependencies, and AC meaning describe obsolete work. Team Lead may create new children only after the exact P100 revision passes review and decides to schedule the conditional graph.

## Planning publication gate

P100 must:

1. change only the three declared planning documents;
2. run `git diff --check` and `scripts/verify`;
3. publish one Conventional Commit in a normal non-draft PR to `main`;
4. reconcile local HEAD, pushed branch, and PR `headRefOid`;
5. record the spec, plan, and tasks blob SHAs;
6. obtain AI Reviewer Standards `PASS` and Spec `PASS` on the exact commit and blobs;
7. return the reviewed revision, AC mapping, dependency graph, and child recommendations to Team Lead.

Planner does not merge, implement, tag, release, create replacement children, or change existing child status.
