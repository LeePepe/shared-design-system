# NativeDesignKit v1 implementation plan

Status: proposed for independent spec-gate review

Specification: `docs/native-design-kit-v1-spec.md`

Task graph: `docs/native-design-kit-v1-tasks.md`

## Planning provenance

| Field | Value |
|---|---|
| issue | `MY-1569` / `01a0c22f-c77d-7813-8fda-f1086df78681` |
| planning input | issue body revision 9 plus Owner decision `01a1380b-5264-7e90-9708-0917f7868c67` and repository correction `01a13857-9460-7cf4-a78e-e2d603caec32` |
| canonical repository | `https://github.com/LeePepe/shared-design-system.git` (`1380829390`) |
| approved base | `main@850fc34b36d495572fcc3634f4f4e3b4a5f6606c` |
| local layer | `NativeDesignKit` |
| current release | `0.1.0` (`4f7fd4f66cb9091704a57add96b42c0ed2058932`) |
| target | additive `0.2.0` candidate; release/tagging is a later workflow |
| external dependency | `shared-design-tokens` exact `0.1.1`, resolved `234b7d0b058474f1aa3f0edeab1be6084ad7eca5` |
| platforms | Swift 6, iOS 15+, macOS 12+ |

The repository is publicly reported by GitHub even though the original issue called for a private repository. This plan records the mismatch and does not change repository visibility or settings.

## Planning decisions

1. **Repository-native documents.** The spec, plan, and task graph live in `docs/`; no `.specify/**` tree or external planning system is introduced.
2. **One deep error boundary.** `NativeDesignTheme.init(theme:) throws` performs all token lookup once for an explicit theme. Components accept the resulting immutable value and keep non-throwing SwiftUI bodies. The value has no default, global cache, automatic theme observation, or fallback.
3. **Presentation-only components.** Card, Metric, StatusBadge, ChartContainer, and ContentStateView accept caller content. They do not absorb product models or workflows.
4. **Pinned vocabulary.** Status tone is limited to info/warning/critical because those are the only paired status roles in Tokens 0.1.1. A success tone requires a future reviewed token/spec change.
5. **Keep platform floors.** ChartContainer is generic caller content. NativeDesignKit does not add Swift Charts and therefore does not raise iOS 15/macOS 12.
6. **Native visual baseline.** System semantic typography and internal layout constants are acceptable because the dependency supplies colors only. Visual evidence is reviewed for hierarchy, readability, clipping, overlap, and native behaviour—not pixel equivalence to an absent design file.
7. **Separate fixture contract.** The showcase belongs under `Tests/Fixtures/**`, with a real iOS/macOS scheme and deterministic runner. Existing package gates are not misrepresented as showcase coverage.
8. **Same-revision consumer contract.** Each public-API publication includes matching `ai/**`, registry/schema/examples, changelog, and checker coverage in the same PR.
9. **Explicit unreleased lifecycle.** The first public slice moves the shipped registry/schema/checker to `version: 0.2.0` with `releaseStatus: unreleased` and creates `Unreleased — 0.2.0` changelog content. Later slices extend that same state; only the release workflow may mark it released/tagged.
10. **No inspection dependency.** Internal pure role/symbol/phase-routing models and a test-only resolver injection cover unit-testable policy. Named fixture UI-test targets cover rendered hierarchy, focus, actions, and selected-branch presence without changing the package manifest.

## Architecture

```text
caller-owned Theme
       │ explicit, throwing construction
       ▼
NativeDesignTheme ── fresh semantic lookup ──► DesignTokens 0.1.1
       │ explicit value injection
       ├── NativeCard<Content>
       ├── NativeMetric<...>
       ├── NativeStatusBadge<Label>
       ├── NativeChartContainer<...>
       └── NativeContentStateView<...>
                │
                └── caller-owned localized content, actions, data and controls
```

The theme seam hides token-role wiring and makes failure explicit before view rendering. No component reaches into an application environment, and no shared layer is added. The dependency remains external and therefore does not appear in the repository's local `depends_on` list.

### Error and lifecycle model

- The caller executes `try NativeDesignTheme(theme: selectedTheme)` at a boundary that can handle failure.
- A token failure returns the exact `TokenError`; it is not converted to an empty/error content phase.
- Components receive the successfully resolved value and never perform a hidden fallback in `body`.
- A caller light/dark change constructs a new value and new component tree. Values are never mutated or automatically invalidated.
- Each construction resolves all required roles again. The implementation may store those resolved render values in that instance but may not share them through static/global memoization.

### API design constraints

- Generic `@ViewBuilder` content preserves localization and native controls without adding string or business-model types.
- Public API exposes the component intent, not token IDs, spacing values, or platform implementation details.
- StatusBadge maps its finite presentation tone internally to paired semantic IDs and a shape cue.
- ChartContainer has no series/domain API. ContentStateView receives a finite presentation phase and four caller-owned builders.
- Components add no implicit button, navigation, selection, retry, timing, analytics, persistence, or network semantics.

## Layer, ownership, and planned paths

The repository has one local layer, `NativeDesignKit`, with owned paths declared by `docs/architecture/native-design-kit/tech-context.md`.

| Category | Planned paths | Ownership / rule |
|---|---|---|
| planning | `docs/native-design-kit-v1-{spec,plan,tasks}.md` | root support; planning-only PR |
| source | `Sources/NativeDesignKit/NativeDesignTheme.swift`, `NativeCard.swift`, `NativeMetric.swift`, `NativeStatusBadge.swift`, `NativeChartContainer.swift`, `NativeContentStateView.swift` | `NativeDesignKit` layer |
| tests | corresponding `Tests/NativeDesignKitTests/*Tests.swift` plus unchanged `NativeTokenColorTests.swift` | `NativeDesignKit` layer |
| fixture | `Tests/Fixtures/NativeDesignKitShowcase/**`, including fixture-local `verify` | `NativeDesignKit` layer; portable project, two app/UI-test target pairs, two shared schemes |
| shipped contract | `ai/{README,USAGE,INTEGRATION,EXAMPLES,COMPATIBILITY,MIGRATION,registry.json,registry.schema.json}` and applicable consumer examples | `NativeDesignKit`; Owner review required by CODEOWNERS |
| release history | `CHANGELOG.md` | root support |
| contract checker support | `scripts/ci/check-ai.py`, `scripts/ci/test-ai.py`, `scripts/ci/external-consumer.py` | root support; updated atomically with public API when required; Owner review |
| fixture gate declaration | `docs/architecture/native-design-kit/tech-context.md` only | separate protected T402 PR adds the merged fixture-local runner; no `scripts/verify`/workflow edit |

`Package.swift` and `Package.resolved` are inspection-only for this feature because the correct package/product, platform floors, and exact dependency already exist. Any newly discovered need to change them stops the affected slice for a specification revision and Owner approval.

The base has no repository development guide or PR-kind taxonomy even though the pinned shared-ci protocol expects one. This is a pre-existing governance gap. The explicitly authorized planning PR proceeds as a one-goal docs PR using the existing template, normal `main` base, hooks, and verification; it does not invent a taxonomy. Team Lead/Owner owns any later governance remedy.

The planning PR changes only the three `docs/native-design-kit-v1-*.md` files. It does not edit implementation, manifests, tokens, `ai/`, gates, policy, or repository settings.

## Publication strategy

Implementation uses sequential, independently reviewable vertical PR slices. Each dispatchable implementation task owns exactly one branch/worktree and one PR. Public tasks are serialized because every public API change must update the same shipped `ai/` contract and registry in the same PR; pretending those shared paths are parallel would create an invalid contract window.

| Slice | Outcome | Publication constraint |
|---|---|---|
| `S1 / T101` theme + Card | explicit theme seam, preserved baseline, Card, matching unreleased 0.2.0 contract/examples | one API task/PR; exact Tokens pin retained |
| `S2 / T201` Metric + StatusBadge | two complete primitives, exhaustive status mapping, matching contract/examples | one API task/PR based on merged S1; no success tone |
| `S3 / T301` Chart + states | generic chart shell and four structural content phases, matching contract/examples | one API task/PR based on merged S2; no chart dependency |
| `S4a / T401` fixture feature | portable sample project, two app targets, two UI-test targets, shared schemes, fixture-local deterministic runner | one feature task/PR based on merged S3; no protected gate change |
| `S4b / T402` fixture gate | declare the existing fixture-local runner in NativeDesignKit tech-context | separate protected governance task/PR; no feature code |
| `S5 / T501` integration proof | exact-SHA full gates, external consumer, objective independent evidence review | read-only final gate; no implementation PR or feature expansion |

Each implementation task is one purpose, one local layer, one branch/worktree, and one PR. A later release workflow decides the final `0.2.0` tag; these slices do not publish automatically.

## Verification contracts

### Planning publication

Before the planning commit and again against its final commit:

```sh
git config core.hooksPath .githooks
scripts/verify
```

Review also checks that all AC IDs have implementation and evidence owners, every task dependency exists, the graph is acyclic, and the planning diff contains only the three declared docs.

### Per implementation slice

Minimum local layer gate:

```sh
scripts/verify --layer NativeDesignKit
```

When exact host counts and exit codes are reported:

```sh
scripts/ci/swift-package.sh build
scripts/ci/swift-package.sh test
scripts/ci/swift-package.sh ios
```

Contract changes also run:

```sh
python3 scripts/ci/check-ai.py
python3 scripts/ci/test-ai.py
```

The fixture feature task adds `Tests/Fixtures/NativeDesignKitShowcase/verify`, which is the only sanctioned fixture build/test entry point. It accepts `macos`, `ios`, or `all`; no task records ad-hoc `xcodebuild` as verification. It builds and tests the independent fixture's named app/UI-test schemes, not merely the package scheme. Simulator destination is a named available iPhone selected by the pinned repository protocol; logs record the resolved destination. The follow-up protected gate task adds `showcase: Tests/Fixtures/NativeDesignKitShowcase/verify all` to NativeDesignKit's tech-context, after which `scripts/verify --layer NativeDesignKit` and `--all` include it without editing `scripts/verify`.

### Full candidate and pushed revision

```sh
scripts/verify --all
python3 scripts/ci/external-consumer.py --revision "$(git rev-parse HEAD)"
```

The external-consumer command is valid only for a revision reachable by the consumer checkout (normally the pushed PR head). Evidence records commands, exit codes, test counts, skipped/cancelled checks, and exact SHA. Before any review or shipping handoff, local `HEAD`, remote branch SHA, and PR `headRefOid` must match byte-for-byte.

## Fixture and evidence plan

The fixture presents all components with conspicuously synthetic sample values and includes controls that exercise theme changes and all content phases. It provides caller-owned buttons inside Card/Chart/State content to verify that containers preserve interaction.

Evidence matrix:

| Platform | Theme | Size | Required evidence |
|---|---|---|---|
| iOS simulator | light, dark | 320 pt and 430 pt widths | build/test log, screenshots, touch-control result |
| iOS simulator | light, dark | accessibility Dynamic Type | screenshots and clipping/reading-order notes |
| macOS | light, dark | 480×320 and 1000×700 | build/test log, screenshots, resize result |
| macOS | light, dark | accessibility Dynamic Type | screenshots, keyboard focus/activation notes |

Every screenshot filename or PR-attachment manifest entry includes platform, theme, size/content phase, and tested SHA. Generated screenshots/logs are not committed. VoiceOver evidence records the observed order and labels. A named independent reviewer applies the objective checklist; absence is reported as unreviewed and blocks the affected ACs and S5 rather than being self-scored as passing.

## Compatibility and migration plan

- `0.1.0` behaviour remains covered continuously while additions are made.
- S1 changes the registry/schema/checker to `version: 0.2.0`, `releaseStatus: unreleased`, and creates `Unreleased — 0.2.0`; S2/S3 extend that same staged contract without claiming a tag.
- Checker positive/negative fixtures distinguish unreleased from released state; the later release workflow alone may flip the status and require matching tag evidence.
- Final `0.2.0` release notes describe additive APIs, unchanged platform/dependency requirements, exact-version integration, upgrade, and rollback.
- No data migration exists. Source rollback means removing calls to new types before pinning `0.1.0` again.
- Existing product adoption is scheduled separately and must not be smuggled into fixture or component PRs.

Removed or weakened behaviour/tests/policy: `none`.

## Risks and controls

| Risk | Control / owner |
|---|---|
| SwiftUI `body` cannot throw while token lookup can | Planner contract selects one throwing `NativeDesignTheme` construction seam; implementation tests exact propagation. |
| A resolved theme could be mistaken for an ambient cache | Spec forbids global/static memoization and requires fresh construction and explicit replacement on theme change. |
| Status vocabulary outruns Tokens 0.1.1 | v1 exposes only info/warning/critical; token additions require dependency/spec review. |
| Visual metrics lack a token/design oracle | System semantic typography + native layout is the accepted baseline; screenshots test readability/behaviour and record reviewer status. |
| Fixture appears covered by package simulator gate | `S4` owns a real project/scheme and exact commands; protected runner/context changes require Owner review. |
| Public API and shipped `ai/` drift | Sequential public slices include contract/schema/checker changes in the same PR. |
| Platform floor accidentally rises | No Swift Charts dependency; manifest remains unchanged and is diff-audited. |
| Repository visibility differs from original request | Record only; Team Lead/Owner owns repository settings outside this plan. |
| Final evidence becomes stale after a tracked correction | Any source, test, docs, registry, checker, changelog, fixture, or gate correction creates a new candidate SHA and repeats all affected checks, independent review, and SHA reconciliation. |

## Entry and exit gates

Implementation entry requires:

1. this exact planning revision is pushed in a normal PR to `main`;
2. AI Reviewer returns `PASS` on that exact revision;
3. the planning PR merges to `main` and Team Lead dispatches implementation from the reviewed artifacts;
4. no newer repository contract invalidates the base assumptions.

Each implementation slice exits only when its mapped ACs pass, public API and `ai/` are synchronized, exact verification evidence is attached, independent content review grants publication permission, and the normal PR path is used. Team Lead owns scheduling; Planner does not merge, ship, tag, or start implementation.
