# NativeDesignKit v1 reconciliation specification

Status: normative planning reconciliation; implementation is not authorized

Issue: MY-1569

Evidence base: `main@6d8dbe1ef5753978bc3a5e0b472af829819537ac`

Repository: `LeePepe/shared-design-system` (`1380829390`)

Normative dependency: `shared-design-tokens` exact `0.1.1` at `234b7d0b058474f1aa3f0edeab1be6084ad7eca5`

## Intent

This revision reconciles the original 13 MY-1569 acceptance IDs with current repository truth after the Owner-authorized Strata rebuild. It replaces the obsolete implementation meaning of the former v1 documents; it does not reinstate their component list, APIs, branches, pull requests, or task numbers.

The result is an evidence and disposition contract:

- preserve the released `NativeTokenColor` 0.1.0 behaviour and exact package/platform contracts;
- recognize the ten additive, unreleased Strata components now on `main`;
- distinguish current evidence from evidence that remains incomplete;
- identify which old outcomes were superseded before release rather than misreporting them as failed current APIs;
- define the decisions and fresh verification work required before any further dispatch.

This is repository-native planning. Spec Kit is intentionally not used. This document does not authorize implementation, release, tracker mutation, repository-setting changes, or changes to `shared-design-tokens`.

## Authority and supersession

The accepted authority chain is:

1. released 0.1.0 color bridge;
2. Strata v0.2 visual direction in `docs/strata-theme-v0.2.md`;
3. Owner-authorized fresh rebuild recorded by PRs #16–#25;
4. inventory and changelog convergence in PR #26, merged as the evidence base above.

`docs/strata-component-rebuild.md` and `ai/COMPONENTS.md` explicitly superseded the original v1 component list and all old unmerged implementations. PR #11 remains closed and unmerged. The original planned `NativeMetric`, `NativeStatusBadge`, `NativeChartContainer`, and `NativeContentStateView` APIs therefore have no implementation authority. Their absence is recorded below, but is not a defect in the accepted ten-component rebuild.

## Current behaviour

### Released contract

NativeDesignKit 0.1.0 continues to expose:

```swift
public enum NativeTokenColor {
    public static func resolve(_ id: String, theme: Theme) throws -> SwiftUI.Color
}
```

The caller supplies `Theme`; there is no system-theme lookup, fallback, default, or cross-call cache. Unknown IDs preserve the provider `TokenError`. Encoded sRGB channels are divided by 255 and alpha is unchanged. Existing tests cover all IDs and themes, alternating theme resolution, exact error propagation, asymmetric RGB, and alpha values.

The package continues to use Swift tools 6.0, iOS 15+, macOS 12+, and exact `shared-design-tokens` 0.1.1 at the resolved commit above.

### Unreleased Strata contract

Current `main` also contains these additive, explicitly unreleased SwiftUI surfaces:

- foundations: `NativeDesignTheme` and `NativeSurfaceStyle`;
- controls: `NativeButton`, `NativeTextField`, `NativeSwitch`, `NativeCheckbox`, `NativeRadioGroup`, `NativeSlider`, and `NativeProgressBar`;
- components: `NativeCard`, `NativeAvatar`, and `NativeChip`.

`NativeDesignTheme` requires explicit `Theme` and provider brand, resolves fresh token-backed values, and propagates provider errors. `NativeCard` is a noninteractive four-slot caller-content surface with a content-only convenience initializer. These accepted APIs intentionally replace the old planned one-argument theme and one-slot Card shapes.

Every current component has source, package tests where applicable, an `ai/components/*.md` consumer contract, and a component-owned synthetic iOS fixture. The shared fixture runner produces exact-SHA result records and named PNGs outside the repository. PRs #16–#25 record review of the component evidence; PR #26 records 72/72 gallery PNG hashes matching their source artifacts.

### Released and unreleased contract split

The machine registry, schema, general integration examples, and checker intentionally describe released 0.1.0 and register only `NativeTokenColor`. `ai/COMPONENTS.md`, the ten component contract files, and the Unreleased changelog separately describe the Strata source on `main`.

That two-track state is coherent while the components remain unreleased. It does not satisfy the old staged-0.2.0 registry/checker requirement, which is superseded. A future release must receive a new reviewed version and contract-publication decision; this plan does not infer a version or edit the registry.

## Terminology

| Term | Meaning |
|---|---|
| released contract | The tagged 0.1.0 `NativeTokenColor` API represented by the machine registry and general `ai/` integration documents. |
| unreleased Strata contract | The exact-revision component APIs on `main`, represented by `ai/COMPONENTS.md`, `ai/components/**`, and the Unreleased changelog. |
| original AC | One of the 13 stable acceptance IDs from MY-1569 planning input v1. IDs are retained for traceability; retaining an ID does not revive its superseded implementation. |
| satisfied | Current-main source and evidence satisfy the behavioural acceptance without relying on obsolete code. |
| satisfied, replaced shape | The behavioural outcome exists, but an Owner-authorized current API replaces the old planned source signature. |
| partial | Reusable evidence exists, but the original observable evidence requirement is incomplete. |
| superseded | The old outcome or evidence model was removed from scope before release by later Owner authority. It is neither a shipped regression nor permission to implement it. |
| exact-head evidence | Evidence names one immutable pushed commit and reconciles local HEAD, remote branch, PR head, checks, and effective server-side enforcement. |

## Compatibility and removed behaviour

- Released source compatibility: `NativeTokenColor` 0.1.0 is unchanged.
- Platform compatibility: Swift 6, iOS 15+, and macOS 12+ declarations are unchanged.
- Dependency compatibility: exact DesignTokens 0.1.1 / `234b7d0b058474f1aa3f0edeab1be6084ad7eca5` is unchanged.
- Current component compatibility: the ten Strata surfaces are additive and unreleased; consumers must use an explicitly reviewed immutable revision until a release exists.
- Rollback: remove unreleased component call sites and return to a released revision. No data or configuration migration exists.

Removed released behaviour: **none**.

Superseded before release: the old v1 component inventory, its exact planned signatures, its single dual-platform showcase, and old T201–T501. The fresh Card contract expressly replaces the old planned Card shape. No old unmerged API is treated as a deprecation or compatibility promise.

## Boundaries and red lines

This planning revision may change only:

- `docs/native-design-kit-v1-spec.md`;
- `docs/native-design-kit-v1-plan.md`;
- `docs/native-design-kit-v1-tasks.md`.

It must not change source, tests, fixtures, `ai/`, manifests, locks, gates, workflows, policies, repository settings, tags, releases, token sources, or issue state outside the normal planning publication. It must not revive PR #11, its branch, MY-1707, or MY-1708–MY-1712.

Any future work remains subject to the repository red lines:

- SwiftUI-only presentation concerns; no business/data/navigation ownership;
- every color from DesignTokens; no local palette, fallback, or default theme;
- explicit theme/brand construction and unchanged token errors;
- exact dependency pin and unchanged iOS/macOS floors unless separately approved;
- public API and its applicable consumer contract change atomically;
- generated fixture evidence stays outside git;
- protected contract, architecture, and gate paths receive Owner review;
- repository settings are observed read-only, never changed by an evidence task.

## Original acceptance mapping at current main

| ID | Disposition | Current-main evidence | Remaining gap or replacement rule |
|---|---|---|---|
| `AC-BASE-01` | satisfied | `NativeTokenColor.swift`, its regression tests, `Package.swift`, `Package.resolved`, and the public consumer fixture preserve 0.1.0 semantics, floors, and the exact token pin. | Fresh exact-head verification is still required for any later candidate. |
| `AC-BOUNDARY-01` | satisfied | Production remains one SwiftUI presentation layer with no local RGB palette, Web runtime, navigation, networking, persistence, or business model. | Any future diff is re-audited against the same negative boundary. |
| `AC-THEME-01` | satisfied, replaced shape | `NativeDesignTheme(theme:brand:)` performs fresh throwing resolution; tests cover order, alternating reconstruction, and exact provider errors. | The old `init(theme:)` shape is not reinstated. Any change to brand or theme semantics needs a new contract. |
| `AC-CARD-01` | satisfied, replaced shape | Current `NativeCard` is generic caller-owned content, semantic surface styling, and no implicit activation; package and fixture tests cover construction, action independence, and scalable layout. | The old one-slot API is not reinstated. |
| `AC-METRIC-01` | superseded; absent | No Metric source, tests, or active contract exists in the accepted ten-component inventory. | Requiring a Metric needs a new Owner product decision and fresh API/evidence plan. |
| `AC-BADGE-01` | superseded; partial analogue | `NativeChip` has a critical tone, paired critical colors, and a non-color cue, but no info/warning StatusBadge contract exists. | Chip is not relabelled as the old StatusBadge. A three-tone badge needs fresh authorization. |
| `AC-CHART-01` | superseded; absent | No ChartContainer source, tests, dependency, or active contract exists. | A chart shell needs a new Owner product decision and fresh API/evidence plan. |
| `AC-STATE-01` | superseded; absent | No generic four-phase content-state API exists; component-specific loading states do not satisfy it. | A shared content-state primitive needs a new Owner product decision and fresh API/evidence plan. |
| `AC-A11Y-01` | partial | Ten iOS fixtures exercise accessibility labels/values, native actions, Dynamic Type growth and containment; light/dark screenshots received independent review. | Live VoiceOver label/value/order/state evidence and the original complete size matrix are absent. Screenshots cannot establish speech order. |
| `AC-PLATFORM-01` | partial | Package gates cover macOS host and iOS simulator paths; iOS fixtures exercise touch, editing, disabled states, and native actions. | All rendered fixtures are iOS-only. macOS rendering, keyboard focus/activation, resize/window matrix, external-keyboard evidence, and minimum-OS runtime evidence are unverified. |
| `AC-FIXTURE-01` | partial, replaced topology | Ten standalone synthetic iOS fixture apps use portable relative package references, a shared runner, external outputs, named screenshots, and exact-SHA run records. | The old single showcase is superseded. There is no macOS rendered fixture, consolidated exact-final-head run, or fixture command in the repository gate. |
| `AC-CONTRACT-01` | superseded; current split is coherent | Released registry/general docs remain correct for 0.1.0; `ai/COMPONENTS.md`, ten component contracts, and changelog accurately mark Strata as unreleased. | Unreleased component files are not machine-enumerated by the current registry/checker. Before release, Owner must approve version, registry/schema/examples/checker, integration, migration, and rollback scope in a fresh plan. |
| `AC-VERIFY-01` | partial | Exact-main CI passed package/contract/external-consumer verification. Effective ruleset `23925002` requires `quality / aggregate` and `codex-review-gate`; other internal jobs ran without separate enforcement. | No exact-final-head run covers all ten fixtures or macOS rendering, and no consolidated required/unrequired/skipped/cancelled evidence table exists. |

## Remaining decisions and evidence gaps

### Product decisions, not implementation tasks

The Owner must separately decide whether Metric, a three-tone StatusBadge, ChartContainer, or a four-phase content-state primitive belongs in a future Strata batch. Until then, their correct disposition is superseded/absent. A decision to add any of them starts a fresh specification against the current theme, surface, component, contract, and fixture architecture.

The Owner must also approve a release/version contract before any component tag. That decision names the version and whether the machine registry represents released-only surfaces or a staged candidate; it also names required schema, examples, checker, compatibility, integration, migration, and changelog changes.

### Evidence work eligible for later scheduling

Subject to Team Lead scheduling after this exact planning revision passes review, the smallest replacement verification graph is:

1. complete current-inventory iOS accessibility evidence and add macOS rendered fixture coverage through the component-owned fixture system;
2. only after that runner exists and passes, declare its aggregate command in the protected NativeDesignKit gate;
3. run one read-only exact-SHA integration gate with all local, fixture, external-consumer, online-CI, and effective-ruleset evidence.

The detailed path ownership, dependencies, commands, and child dispositions are normative in `docs/native-design-kit-v1-tasks.md`. None of those nodes is authorized merely by this document.

## Reconciliation acceptance

This planning reconciliation passes only when:

1. all 13 original IDs have an evidence-backed disposition;
2. completed Strata work is not relabelled as an old task;
3. no missing old component is silently authorized;
4. the replacement graph is acyclic and gives every future node one owner, path set, verification contract, and final evidence owner;
5. MY-1707 and PR #11 remain abandoned, and MY-1708–MY-1712 receive explicit Team Lead disposition recommendations without tracker mutation by Planner;
6. the planning diff contains only these three documents, is published through a normal PR to `main`, and receives AI Reviewer `PASS` on the exact commit and artifact blobs.
