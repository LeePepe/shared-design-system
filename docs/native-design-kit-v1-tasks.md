# NativeDesignKit v1 task graph

Status: proposed for independent spec-gate review

Specification: `docs/native-design-kit-v1-spec.md`

Plan: `docs/native-design-kit-v1-plan.md`

## Execution rules

- This graph is planning input, not authorization to implement. Team Lead dispatches only after this exact revision passes the AI Reviewer spec gate and the planning PR merges to `main`.
- One dispatchable implementation task owns one branch/worktree, one fixed candidate, one independent content review, and one normal PR. Internal steps are not separate tasks or separately publishable candidates.
- Tasks are sequential where they update the shared `ai/` contract. No parallel branch may publish a stale registry/schema.
- All feature implementation belongs to the existing `NativeDesignKit` layer. The pinned `DesignTokens` package is an external dependency, not a local layer or a task to modify.
- No task changes `Package.swift`, `Package.resolved`, token data, repository settings, or a business application. A concrete need stops that task for reviewed plan revision and Owner approval.
- Protected `ai/**`, `scripts/ci/**`, `scripts/verify`, and `docs/architecture/**` paths receive repository Owner review. Gates may be extended for real coverage but never weakened.
- Every task records commands, exit codes, test counts, skipped/cancelled checks, tested SHA, and local/remote/PR SHA equality. Skipped, cancelled, package-only, or macOS-only work is not fixture/iOS success.

## Dependency graph

```text
planning docs → planning PR → exact-revision AI Reviewer PASS → merge to main
    → T101 theme + Card + atomic consumer contract
        → T201 Metric + StatusBadge + atomic consumer contract
            → T301 ChartContainer + states + atomic consumer contract
                → T401 dual-platform showcase + fixture-local runner
                    → T402 protected fixture-gate declaration
                        → T501 exact-SHA integration and independent evidence review
```

The graph is acyclic. `T101`, `T201`, `T301`, `T401`, and `T402` are the only dispatchable implementation tasks and each maps to exactly one PR. `T501` is a read-only acceptance gate, not an implementation branch or PR.

## Planning publication gate

Planner Lead owns the current planning publication as one existing issue/run, not as additional implementation tasks. It must:

1. change only `docs/native-design-kit-v1-spec.md`, `docs/native-design-kit-v1-plan.md`, and `docs/native-design-kit-v1-tasks.md`;
2. run `git config core.hooksPath .githooks`, `git diff --check`, and `scripts/verify`;
3. publish one Conventional Commit in a normal non-draft PR to `main` with complete template and exact tested SHA;
4. request AI Reviewer `PASS` on the exact commit and three artifact blob SHAs;
5. hand PASS and byte-identical merge evidence to Team Lead before implementation dispatch.

Planner does not merge, implement, tag, publish, or create implementation children before PASS.

The exact shared public-contract path set `C1` is: `ai/README.md`, `ai/USAGE.md`, `ai/INTEGRATION.md`, `ai/EXAMPLES.md`, `ai/COMPATIBILITY.md`, `ai/MIGRATION.md`, `ai/registry.json`, `ai/registry.schema.json`, `ai/examples/consumer/Sources/SamplePalette/SamplePalette.swift`, `ai/examples/consumer/Tests/SamplePaletteTests/SamplePaletteTests.swift`, `CHANGELOG.md`, `scripts/ci/check-ai.py`, `scripts/ci/test-ai.py`, and `scripts/ci/external-consumer.py`. Each public task changes only the members that require content updates, but audits every `C1` member and names unchanged members in its evidence.

## `T101` — Theme, Card, and S1 consumer contract

- **Slice / PR:** `S1`; one `NativeDesignKit` feature/contract PR
- **Outcome:** Add the explicit throwing theme seam and generic Card while preserving all 0.1.0 behaviour; atomically establish the staged 0.2.0 shipped contract.
- **Depends on:** planning PASS and planning artifacts merged byte-identically to `main`
- **Covers:** `AC-BASE-01`, `AC-BOUNDARY-01`, `AC-THEME-01`, `AC-CARD-01`, S1 portions of `AC-A11Y-01`, `AC-PLATFORM-01`, `AC-CONTRACT-01`, `AC-VERIFY-01`
- **Source paths:** `Sources/NativeDesignKit/NativeDesignTheme.swift`, `Sources/NativeDesignKit/NativeCard.swift`; existing `NativeTokenColor.swift` only for an additive internal refactor with unchanged public behaviour
- **Test paths:** `Tests/NativeDesignKitTests/NativeDesignThemeTests.swift`, `Tests/NativeDesignKitTests/NativeCardTests.swift`; existing `NativeTokenColorTests.swift` remains passing
- **Contract paths:** exact path set `C1`
- **Interface impact:** additive exact `NativeDesignTheme` and `NativeCard` signatures from the spec; `NativeTokenColor` unchanged
- **Internal steps:**
  1. Implement `NativeDesignTheme.init(theme:) throws` with no public custom-ID/default/environment API.
  2. Add an internal `@testable` resolver-injection seam and pure role model; resolve exactly the ten specified semantic IDs per construction.
  3. Implement Card with raised background, primary inherited foreground, generic content, and no implicit interaction.
  4. Keep pure mapping/error tests in XCTest; defer rendered hierarchy/focus/action proof to `T401` UI tests.
  5. Set registry/schema/checker to `version: 0.2.0`, `releaseStatus: unreleased`; create `Unreleased — 0.2.0`; document fixed-version upgrade/rollback without claiming a tag.
  6. Update strict contract positive/negative tests and pushed-SHA external consumer for resolver/theme/Card.
- **Required tests:** both themes; exact requested-role order; light → dark → light fresh construction; injected exact `TokenError` identity; no public default/custom-ID surface; all existing all-token/unknown-ID/asymmetric RGB/alpha tests; Card role model and public construction compile test; unreleased registry lifecycle positive/negative fixtures
- **Excludes:** view-inspection dependency, rendered-once/lifecycle promise, default/environment theme, global cache, fallback, local colors, manifest/lock edit, release/tag, product interaction
- **Commands:**

  ```sh
  python3 scripts/ci/check-ai.py
  python3 scripts/ci/test-ai.py
  scripts/verify --layer NativeDesignKit
  scripts/verify --all
  python3 scripts/ci/external-consumer.py --revision "$(git rev-parse HEAD)"
  ```

  The external-consumer command runs only after the candidate is pushed/reachable.
- **Completion evidence:** protected-path Owner review, exact commands/counts/SHA, unchanged platform/token pin inspection, local HEAD = remote branch = PR head, independent publication permission

## `T201` — Metric, StatusBadge, and S2 consumer contract

- **Slice / PR:** `S2`; one `NativeDesignKit` feature/contract PR
- **Outcome:** Add exact Metric and StatusBadge APIs with exhaustive token/symbol mapping and atomically extend the staged 0.2.0 contract.
- **Depends on:** merged `T101` PR; branch from its merged `main`
- **Covers:** `AC-METRIC-01`, `AC-BADGE-01`, S2 portions of `AC-BOUNDARY-01`, `AC-A11Y-01`, `AC-PLATFORM-01`, `AC-CONTRACT-01`, `AC-VERIFY-01`
- **Source paths:** `Sources/NativeDesignKit/NativeMetric.swift`, `Sources/NativeDesignKit/NativeStatusBadge.swift`
- **Test paths:** `Tests/NativeDesignKitTests/NativeMetricTests.swift`, `Tests/NativeDesignKitTests/NativeStatusBadgeTests.swift`
- **Contract paths:** exact path set `C1`, limited to required S2 content/checker additions with every member audited
- **Interface impact:** additive exact Metric overload, `NativeStatusTone` cases, and StatusBadge initializer from the spec
- **Internal steps:**
  1. Implement Metric role/reading-order model: label/supporting → secondary, value → primary; optional supporting slot only through the exact `EmptyView` overload.
  2. Implement exactly info/warning/critical badge mappings and exact SF Symbols: `info.circle.fill`, `exclamationmark.triangle.fill`, `exclamationmark.octagon.fill`.
  3. Add pure exhaustive role/symbol tests and compile/construction tests; rendered wrapping/VoiceOver/focus remains `T401` UI-test evidence.
  4. Extend the same `0.2.0` / `unreleased` registry, docs, examples, changelog, checker fixtures, and external consumer without claiming release.
- **Required tests:** exact initializer compile coverage with and without Metric supporting content; exhaustive three-tone role/symbol mapping; symbol availability on iOS 15/macOS 12 in fixture later; caller-generic content compile coverage; schema rejects success/unknown tone and missing source
- **Excludes:** success/neutral/business status, number/unit formatting, local RGB/hex/opacity colors, implicit button, manifest change, release/tag
- **Commands:** same five commands as `T101`
- **Completion evidence:** protected-path Owner review, mapping table, exact commands/counts/SHA, unchanged manifest/lock and pin, SHA equality, independent publication permission

## `T301` — ChartContainer, content states, and S3 consumer contract

- **Slice / PR:** `S3`; one `NativeDesignKit` feature/contract PR
- **Outcome:** Add the one-content ChartContainer and four-branch ContentStateView exact APIs, then atomically complete the staged v1 public contract.
- **Depends on:** merged `T201` PR; branch from its merged `main`
- **Covers:** `AC-CHART-01`, `AC-STATE-01`, S3 portions of `AC-BOUNDARY-01`, `AC-A11Y-01`, `AC-PLATFORM-01`, `AC-CONTRACT-01`, `AC-VERIFY-01`
- **Source paths:** `Sources/NativeDesignKit/NativeChartContainer.swift`, `Sources/NativeDesignKit/NativeContentStateView.swift`
- **Test paths:** `Tests/NativeDesignKitTests/NativeChartContainerTests.swift`, `Tests/NativeDesignKitTests/NativeContentStateViewTests.swift`
- **Contract paths:** exact path set `C1`, limited to required S3 content/checker additions with every member audited
- **Interface impact:** additive exact ChartContainer, NativeContentPhase, and ContentStateView signatures from the spec
- **Internal steps:**
  1. Implement ChartContainer raised/primary defaults around one generic composition; caller places title/legend/controls/renderer inside it.
  2. Implement a pure phase-routing model and render only the selected branch; do not promise body evaluation counts or caller child-state retention/reset.
  3. Unit-test role/phase policy and public construction; assign selected/prior-branch hierarchy, actions, and focus to named `T401` UI tests.
  4. Extend the same `0.2.0` / `unreleased` contract, strict registry/schema/checkers, compileable examples, changelog, and external consumer.
- **Required tests:** no Swift Charts/new dependency; generic content compile coverage; exhaustive phase mapping; token error not mapped to `.error`; schema/source agreement; external consumer covers complete API
- **Excludes:** chart data/series/axis/legend meaning, persistence, timers/networking, product errors, implicit retry, stale-child-state guarantee, manifest/lock edit, release/tag
- **Commands:** same five commands as `T101`
- **Completion evidence:** protected-path Owner review, dependency diff audit, exact commands/counts/SHA, SHA equality, independent publication permission

## `T401` — Portable dual-platform showcase and fixture-local runner

- **Slice / PR:** `S4a`; one `NativeDesignKit` feature/test PR, no protected gate/architecture edit
- **Outcome:** Add a portable, sample-only iOS/macOS SwiftUI consumer with named app/UI-test targets, shared schemes, a repository-owned fixture runner, and objective exact-SHA evidence attachments.
- **Depends on:** merged `T301` PR; branch from its merged `main`
- **Covers:** implementation/evidence portions of `AC-A11Y-01`, `AC-PLATFORM-01`, `AC-FIXTURE-01`; fixture portions of `AC-VERIFY-01`
- **Paths:**
  - `Tests/Fixtures/NativeDesignKitShowcase/NativeDesignKitShowcase.xcodeproj/**`
  - `Tests/Fixtures/NativeDesignKitShowcase/Shared/**`
  - `Tests/Fixtures/NativeDesignKitShowcase/iOS/**`
  - `Tests/Fixtures/NativeDesignKitShowcase/macOS/**`
  - `Tests/Fixtures/NativeDesignKitShowcase/NativeDesignKitShowcase-iOSUITests/**`
  - `Tests/Fixtures/NativeDesignKitShowcase/NativeDesignKitShowcase-macOSUITests/**`
  - `Tests/Fixtures/NativeDesignKitShowcase/verify`
- **Project contract:** portable relative local-package reference to repository root; public imports only; no `@testable`, absolute path, home path, business dependency/data, network, analytics, or derived/generated evidence committed
- **Schemes/actions:** shared `NativeDesignKitShowcase-iOS` scheme builds the iOS app and its Test action runs `NativeDesignKitShowcase-iOSUITests`; shared `NativeDesignKitShowcase-macOS` does the same for macOS and `NativeDesignKitShowcase-macOSUITests`
- **Runner contract:**

  ```sh
  Tests/Fixtures/NativeDesignKitShowcase/verify macos
  Tests/Fixtures/NativeDesignKitShowcase/verify ios
  Tests/Fixtures/NativeDesignKitShowcase/verify all
  ```

  It validates relative/public-only integration, selects the named macOS destination or newest available iPhone simulator under the pinned repository policy, prints the resolved destination, and builds/tests the named scheme. Missing scheme/target/destination and nonzero build/test are failures. It is the only sanctioned fixture entry point; no task records ad-hoc `xcodebuild` as verification.
- **Required UI tests:** one structural Card child; Metric reading hierarchy and large-text wrapping; each badge symbol/label and non-color distinction; caller-composed chart title/legend/control and preserved action; only selected phase branch present/accessible after update; iOS touch; macOS keyboard focus/activation; resize; explicit theme reconstruction; public `NativeTokenColor.resolve` invalid-ID error display in a fixture-only diagnostics view
- **Manual/evidence matrix:** iOS 320/430 pt and macOS 480×320/1000×700; light/dark; default/XXXL/accessibility Dynamic Type; VoiceOver order; touch/focus/resize; four phases; invalid-ID path
- **Evidence mechanism:** attach screenshots/logs plus a Markdown manifest to the PR comment/review system; filenames/manifest record platform, theme, size, phase, and tested SHA. Generated evidence is not committed. A named independent reviewer must PASS the objective no-missing-content/no-overlap/no-clipping/correct-theme-phase checklist; `not reviewed` remains reported but blocks the mapped ACs.
- **Additional verification:** `scripts/verify --layer NativeDesignKit`; `scripts/verify --all`; existing pushed-SHA external consumer
- **Excludes:** protected gate/context edits, business app install/launch/data, TestFlight/App Store, visual score, raw ad-hoc xcodebuild, package/lock change
- **Completion evidence:** runner outputs/counts/destination, UI/manual matrix, evidence attachment links and reviewer PASS, exact SHA equality, independent publication permission

## `T402` — Protected fixture-gate declaration

- **Slice / PR:** `S4b`; one protected governance PR, no feature/source/fixture change
- **Outcome:** Make the already-merged fixture runner part of the resolver-driven NativeDesignKit layer gate without editing `scripts/verify` or workflow files.
- **Depends on:** merged `T401` PR with passing fixture runner and evidence
- **Covers:** gate portions of `AC-FIXTURE-01`, `AC-PLATFORM-01`, `AC-VERIFY-01`
- **Only changed path:** `docs/architecture/native-design-kit/tech-context.md`
- **Exact change:** add `showcase: Tests/Fixtures/NativeDesignKitShowcase/verify all` to the existing `gate` mapping and update its prose gate inventory; do not alter red lines, ownership, dependencies, existing gates, workflow, or `scripts/verify`
- **Required negative proof:** before/after gate inventory shows all five existing gates unchanged plus showcase; missing/broken fixture runner causes layer verification to fail; no skip/cancel-success path
- **Commands:**

  ```sh
  scripts/verify --layer NativeDesignKit
  scripts/verify --all
  ```

- **Excludes:** component/fixture code, scripts/CI/workflows, policy weakening, unrelated architecture changes
- **Completion evidence:** Owner review, exact command/count/SHA, gate inventory, SHA equality, independent publication permission

## `T501` — Read-only exact-SHA integration gate

- **Kind:** acceptance verification, not an implementation task/branch/PR
- **Outcome:** On the final pushed candidate/main revision, prove every stable AC, compatibility/rollback, source/contract agreement, unchanged token pin/platform floors, fixture evidence review, and SHA identity before release handoff.
- **Depends on:** merged `T402` PR and green normal CI for the exact revision when CI evidence is an explicit parent acceptance requirement
- **Covers:** final evidence for all ACs, especially `AC-BASE-01`, `AC-BOUNDARY-01`, `AC-CONTRACT-01`, `AC-VERIFY-01`
- **Commands:**

  ```sh
  scripts/verify --layer NativeDesignKit
  scripts/verify --all
  Tests/Fixtures/NativeDesignKitShowcase/verify macos
  Tests/Fixtures/NativeDesignKitShowcase/verify ios
  python3 scripts/ci/external-consumer.py --revision "$(git rev-parse HEAD)"
  ```

- **Evidence:** command/exit-code/test-count and skipped/cancelled tables; exact dependency/manifest inspection; complete AC matrix; PR-attached screenshot/manual manifest and named independent PASS; local HEAD = remote branch = PR head/main evidence; compatibility and rollback audit; residual risks
- **Invalidation:** any tracked correction—source, tests, docs, registry, schema, checker, changelog, fixture, runner, gate, or other file—creates a new candidate SHA and requires all affected contract/full/external/fixture checks, independent exact-revision review, evidence manifest, and SHA reconciliation to run again. No documentation-only exception exists.
- **Excludes:** self-approval, merge, tag, package publication, consumer migration, repository settings, waived/unreviewed acceptance

## Acceptance coverage matrix

| Acceptance ID | Implementation owner(s) | Final evidence owner |
|---|---|---|
| `AC-BASE-01` | `T101`; regression guard in `T201`/`T301` | `T501` |
| `AC-BOUNDARY-01` | `T101`, `T201`, `T301` | `T501` |
| `AC-THEME-01` | `T101` | `T101`, `T401`, `T501` |
| `AC-CARD-01` | `T101` | `T101`, `T401`, `T501` |
| `AC-METRIC-01` | `T201` | `T201`, `T401`, `T501` |
| `AC-BADGE-01` | `T201` | `T201`, `T401`, `T501` |
| `AC-CHART-01` | `T301` | `T301`, `T401`, `T501` |
| `AC-STATE-01` | `T301` | `T301`, `T401`, `T501` |
| `AC-A11Y-01` | `T101`, `T201`, `T301`, `T401` | `T401`, `T501` |
| `AC-PLATFORM-01` | `T101`, `T201`, `T301`, `T401`, `T402` | `T401`, `T501` |
| `AC-FIXTURE-01` | `T401`, `T402` | `T401`, `T501` |
| `AC-CONTRACT-01` | `T101`, `T201`, `T301` | `T501` |
| `AC-VERIFY-01` | every implementation task | `T501` |

Coverage is complete: every stable AC has implementation and evidence ownership, every dispatchable task has exact paths/commands and one PR, and the dependency graph is acyclic. Any split, renumbering, or removal of an AC/task dependency requires a reviewed update to all three planning artifacts.
