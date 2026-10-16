# Foundations and Controls execution plan

Status: Owner-approved scope, implementation in progress. This additive revision
records the subsequent instruction to implement all Foundations and Controls in
parallel, provide real rendered screenshots, investigate Xcode snapshot tests,
and use Apple Liquid Glass where appropriate.

## Relationship to existing work

The MY-1569 v1 specification and MY-1707 Theme/Card PR remain authoritative for
their existing APIs and acceptance. This revision expands the previously excluded
control and style-data scope; it does not replace their owner, remove their tests,
or claim their acceptance. Theme/Card is an explicit stacked prerequisite at
`2a22889750404d77e90336b3cb61adfca0a77ad8`. Existing Metric, StatusBadge, ChartContainer
and ContentState tasks retain their original owners and are not duplicated here.

Foundations, Controls, Components and Patterns are internal organization within
the existing NativeDesignKit layer. Layout and Motion support these groups;
they do not introduce unverified repository layers or additional package targets.

## Responsibility and dependency order

| Slice | Repository and unique writer | Outcome | Dependency / next action |
| --- | --- | --- | --- |
| Style data | shared-design-tokens / provider agent | Typed, validated platform-neutral typography, dimensions, surfaces and motion data, generated Swift and web artifacts, public contract and tests | Reviewed source, immutable release, then a separately reviewed exact-version consumer upgrade |
| Foundations | shared-design-system / foundation agent | Explicit style inputs/adapters, adaptive layouts, motion, transitions, interpolation, stagger, accessibility and Glass policy | Theme/Card prerequisite; no invented provider version |
| Controls and validation fixture | shared-design-system / controls agent | Native composable controls and sample-only dual-platform catalog, UI-test screenshot evidence and snapshot capability | Foundation interface first, then integration against its exact commit |
| Review and acceptance | Coordinator plus independent reviewer | Exact-commit verification, rendered screenshot inspection, PR evidence | All implementation slices and real build artifacts |

Independent branches/worktrees are used. Shared interfaces are fixed before
dependent implementation and integrated in dependency order; each path has one
writer. No release, tag, merge, repository setting or product adoption is implied.

## Approved inventory

Foundations cover explicit token-color resolution; scalable typography and
monospaced numbers; spacing/dimensions/hit targets; radius, borders, opacity,
shadows and surfaces; constraints, aspect and alignment; equal/adaptive grids;
wrapping flow; safe-area, keyboard, RTL and long-text behavior; animation curves,
durations and springs; combined/asymmetric transitions; numerical/progress/path
interpolation; stagger, replay and cancellation; complete reduced-motion end
states; keyboard focus, pressed/disabled/pointer/touch behavior; accessibility
labels, values, Dynamic Type and contrast.

Controls cover text/icon/labeled/loading buttons; toggle/checkbox/radio; text,
secure, multiline and search input; picker/segmented selection; slider/stepper;
native date/time/datetime selection; linear/ring/indeterminate progress; and
badge/tag/icon-label/avatar/animated number. Prefer native control semantics and
composable label/content slots. Product state, formatting/localization, network
loading and business behavior stay with callers.

## Style and compatibility contract

All explicit color values continue to come from DesignTokens. There is no local
palette, fallback-on-error, default theme, system-theme inference or cache.
Provider errors retain their original identity. New style values belong to the
provider; the native library adapts typed explicit inputs and must not introduce
a second table of style defaults while a provider release is pending. Integration
evidence using an unreleased provider is labelled local-only, with the exact
source SHA; it does not satisfy published exact-version consumption.

iOS 15/macOS 12 support remains. Liquid Glass is availability-gated to supporting
OS versions and reserved for suitable controls/floating surfaces. Explicit tint
colors use semantic tokens. Reduced transparency uses an opaque token surface;
reduced motion reaches the complete intended static end state. Older systems
retain usable native controls and token surfaces. No production UIKit/AppKit.

## Verification and evidence

- Preserve and run the existing SwiftPM host and iOS package tests and contract
  checks; run scripts/verify before pushing each implementation revision.
- Add a synthetic-data fixture under Tests/Fixtures/NativeDesignKitShowcase with
  portable relative local-package references and public imports only. Real
  screenshots must be rendered from that fixture, not drawn mockups.
- Investigate native XCTest screenshot attachments and regression snapshots.
  State clearly which mechanism exists, what is compared, and its OS/device
  limits. Generated evidence stays outside git; deterministic source fixtures
  and intentional baselines, if adopted, are explicitly documented.
- Cover both themes, representative narrow/wide layouts, scalable type,
  meaningful interaction/state changes, motion/transparency accessibility and
  supported Glass rendering. Record exact SHA, platform, size and appearance.
- A named independent reviewer inspects real screenshot artifacts for required
  content, hierarchy, clipping, overlap and readable states. Missing review or
  a missing platform test remains unverified.
- Public API additions update shipped ai/ in the same PR. Any new CI gate wiring
  is a separate protected change; do not weaken existing checks to pass.

Delivery remains PR-based with required checks on the exact head. Owner review
is retained for protected paths and provider scope/contract changes. A pending
release or approval is reported separately from implemented and tested code.
