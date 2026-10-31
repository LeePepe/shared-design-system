# Consumer Design Contract

This document defines the contract between the upstream
`shared-design-system` package and a downstream product repository. It is a
consumer-facing specification, not a product screen specification.

## Upstream and downstream responsibilities

The upstream package owns the `DesignTokens` token vocabulary, the
`Strata` component APIs, the web `Basalt` component APIs where
applicable, and the accessibility and platform floors of those APIs. It
provides the stable primitives and their light/dark behavior; it does not
choose a product's brand, page hierarchy, business terminology, or required
content.

Each downstream product owns a thin `docs/design-contract.md`. That document
locks the exact upstream package revision or release, records the product's
brand and business-semantic token bindings, describes the page and component
structure, and names the CI checks that prove compliance. It must not copy the
upstream token table or redefine upstream component behavior.

The downstream contract is the handoff consumed by design and implementation
agents. A product may add requirements, but it must preserve the required
sections, the four required view states, both appearance modes, and the
upstream accessibility guarantees.

Before adapting a consumer screen, R11 exploration must verify the consumer
repository's pinned `shared-design-system` revision (or local `DesignKit`
parity) and check whether the required UI pattern already exists in `Strata`
or `DesignTokens`. When a consumer screen needs a reusable component variant,
layout primitive, or more than 15 lines of custom layout or chrome glue that
`Strata` does not provide, the Designer and TL must split an upstream
`shared-design-system` task first rather than authoring an app-local workaround
such as negative margins, ad-hoc toolbar capsules, or raw colors. Reusable
layout and motion primitives validated in a downstream product task must be
backported to `shared-design-system`, after which the downstream local glue is
removed.

## Round 1 interaction contracts

### Rule 1 — System Chrome & Toolbar Integration Contract (Zero Double-Chrome)

Consumers must not apply custom `.background(..., in: Capsule())` or
`.overlay(Capsule().stroke(...))` inside `.toolbar` or `ToolbarItem` views.
Consumers must not pack multiple bordered or filled capsule buttons inside a
single shared toolbar glass pill. The system toolbar chrome is the sole outer
bezel.

### Rule 2 — Token Contrast Matrix (WCAG AA ≥ 4.5:1)

Primary filled controls, including detached UIKit `inputView` custom keyboard
`Done` keys and floating dock confirmation pills, must bind foreground and
background to `onInteractiveAccent` and `interactiveAccent`. They must never
pair a surface-tinted `primaryText` token with an accent fill or use
low-contrast gray-on-gray disabled pills.

### Rule 3 — Inline Status Ring Optical Center Alignment

Status and metric rows combining progress rings (`Circle().trim`), icons,
monospaced digits, and unit labels must align on one `.center` vertical axis.
Progress rings use a 14×14 frame with `lineWidth: 2`, and the row uses a
unified `minHeight: 24`.

### Rule 4 — Single-Line Filter Chip Rail (`StrataFilterBar`)

Filter chip collections must use `StrataFilterBar` or an equivalent single-line
horizontal scroll rail. Chips must never wrap onto multiple rows; each chip
keeps a minimum 44pt touch target and exposes selection through accessibility
semantics.

### Rule 5 — Single-Trailing-Action Card Ergonomics (`StrataActionCardRow`)

Cards in lists and sheets must not stack two trailing buttons such as `Detail`
and `Select`. Use `StrataActionCardRow` with a text column at
`layoutPriority(1)` and one visually and interactively separate 44×44 trailing
action slot.

### Rule 6 — Keyboard-Persistent Vertical Space Budget & Flush Keypad Matrix

When snackbars or banners are `.none`, consumers must reserve zero dead space
for their hidden slot. Custom multi-column keypads must distribute their
columns across the same grid height so the top and bottom edges align.

### Rule 7 — Sticky Section Header Compactness & Hit-Target Separation

Sticky section headers use the same strict header contract as Rule 9: no more
than `4pt` total vertical padding or outer vertical padding on either edge,
a maximum total height of `44pt`, and visual chrome compact inside that
44×44 hit envelope. A pinned header must never inflate to 52pt or more or
crowd the first row.

### Rule 8 — Narrow Sidebar Rail CJK Ergonomics & Multi-State/RTL Verification

Narrow CJK rails (`64pt`) must use no more than `2pt` of inner horizontal
padding to maximize glyph capacity per line. Stateful or filterable views must
use reduce-motion-aware spring choreography through `StrataMotion` and verify
Light, Dark, Large-Font, and RTL (`layoutDirection = .rightToLeft`) snapshots.

### Rule 9 — Compact Unified-Surface Section Headers

`StrataSectionHeader` and `StrataStickySectionHeader` keep the title on one
line (`lineLimit(1)`, tail truncation when necessary), use compact vertical
padding of no more than `4pt` per edge and a strict total height envelope of
`44pt` maximum, and bind their fill to the same `theme.surface` token as the
adjacent card or row. Trailing accessories may use a `44×44` hit target, but
their visual chrome stays compact and contributes no extra vertical padding.
Trailing actions remain compact and must not consume the title's horizontal
budget with full-width text pills.

### Rule 10 — Single-Axis Tabular Rows & Inline Hints

Dense data-entry rows use one horizontal grid:
`[Index/Tag] -> [Checkbox] -> [Input + Inline Hint] -> [Input + Inline Hint] -> [Badge/Menu]`.
Warm-up, RPE, and progressive-overload recommendations remain compact inline
metadata; recommendations must not render as a row-bottom banner. Inputs,
badges, and trailing actions preserve the row's shared center axis and minimum
touch target.

### Rule 11 — Shared-Grid Sub-Rows & Motion

Sub-rows such as drop sets reuse the parent row's column geometry rather than
adding a nested card or secondary indentation. Insertions and removals use
`StrataMotion.subRowAnimation(reduceMotion:)` together with
`StrataMotion.subRowTransition(reduceMotion:)`. Motion allowed uses
`.spring(response: 0.30, dampingFraction: 0.82)`; reduced motion uses
`.linear(duration: 0.12)`, with an opacity transition.
Containers must not clip the expanding row or its footer action.

### Rule 12 — Zero-Height Inactive Slots & Seamless Docks

Inactive bottom slots are conditionally omitted (`StrataBottomSlot(isActive:)`)
and must never use `.opacity(0)` to hide a view that still reserves height.
Custom keyboard or bottom docks use one continuous `theme.surface` plane,
extend through the bottom safe area, and expose at most one token-backed top
hairline. Content-layer rows and key cells remain solid rather than glass.

### Rule 13 — Container-Driven Width Budget & Three-Tier Text Constraints

Every compact layout starts with a top-down width budget:
`Available Single-Line Width = Container Width - Outer Padding - Column Gaps - Fixed Control/Icon Widths`.
For AppKit/UIKit fixed-width hosts such as `NSHostingView` and `NSPopover`,
apply `.padding(P).frame(width: W)` so padding lives inside `W`; the rendered
bitmap must satisfy `bitmap.pixelsWide == W * scale`.

- **Tier 1 - Schema Labels:** In compact or half-width Bento cards
  (`~140-170pt`) and narrow rails (`64-72pt`), cap labels at CJK <= 4
  characters or EN <= 6-8 characters (for example, `Load` or `负载`, never
  `Load 1/5/15m`). Move longer schema descriptions to section subtitles or
  semantic icons.
- **Tier 2 - Metric Readouts:** Lock a deterministic upper-bound format
  template with explicit decimal precision such as `%.1f` and compact units
  such as `16.8 / 24.0 GB`, and apply `.layoutPriority(1)`. Numeric values
  and units must never truncate with an ellipsis (`…`). Side-by-side Bento
  cards in an `HStack` must lock matching row heights so card bottoms align
  within `<= 1px`.
- **Tier 3 - Unbounded Dynamic Titles:** Never place unbounded titles
  (exercise names, file paths, or localized error explanations) in the same
  single-line `HStack` competing with multiple fixed buttons. Give them a
  dedicated line or use `ViewThatFits(in: .horizontal)` with a one-line
  compact form and a two-line fallback, as in `StrataStickySectionHeader`,
  together with `lineLimit(2)` and `minimumScaleFactor(0.8-0.85)`, or enforce
  an input character cap on user-created labels.
- **No Placeholder/Unit Duplication:** In custom numeric inputs, never set the
  placeholder string to the same unit or label already rendered as an inline
  persistent suffix (`lb lb`, `次数 次数`).

## Scenario-to-Pattern, Component, and Motion Decision Matrix

Use the following prescriptive mapping before introducing a new layout,
component, or animation. The anti-pattern column is a redline, not a
suggestion.

| Scenario | Required layout strategy | Required Strata primitives | Required StrataMotion choreography | Explicit anti-patterns |
| --- | --- | --- | --- | --- |
| High-Frequency Live Telemetry Panels | Use a stable metric grid with a deterministic numeric template, matched row heights, and no layout shift during updates. | `StrataStatusRing`, `StrataMetricRow`, and token-backed solid cards. | Use `snappy` for value refreshes; apply `.contentTransition(.numericText())`; use a Reduce Motion crossfade. | Unbounded decimals, ellipsis-truncated values or units, changing card geometry, and Glass-on-Glass telemetry cells. |
| High-Density Single-Hand Entry Lists | Use one shared horizontal grid with compact inline hints, a single trailing action, and a single-line filter rail. | `StrataActionCardRow`, `StrataFilterBar`, and `.strataInputBaseline`. | Use `snappy` for commit and focus changes; use a Reduce Motion crossfade instead of spring travel. | Nested cards, wrapped filter chips, stacked trailing buttons, row-bottom recommendation banners, and oversized hit chrome. |
| Dynamic Expand/Collapse & Sub-Rows | Reuse the parent row's column geometry; reserve no hidden height and never clip the expanding footer action. | `StrataSectionHeader`, `StrataStickySectionHeader`, and shared-grid sub-row primitives. | Use `StrataMotion.subRowAnimation(reduceMotion:)` and `subRowTransition(reduceMotion:)`; use `gentle` for section expansion and Reduce Motion crossfade. | Nested secondary cards, indentation that changes the grid, `.opacity(0)` placeholders, and clipped expansion content. |
| Bottom Multi-Layer Floating Chrome Conflicts | Compose one `Content -> Snackbar -> DockedBar -> Safe Area/Keyboard` stack with one continuous surface plane and zero-height inactive slots. | `StrataBottomSlot`, bottom dock primitives, and token-backed surface/hairline styles. | Use `snappy` for dock appearance and dismissal; use a Reduce Motion crossfade with no vertical travel. | Multiple `safeAreaInset` stacks, floating chrome over floating chrome, duplicate capsules, glass content layers, and hidden views that reserve height. |
| Multi-Dimensional Filter & Substitute Sheets | Use a structured sheet with grouped controls, a single-line filter rail, and explicit empty/loading/error states; keep selection and confirmation separate. | `StrataFilterBar`, `StrataSectionHeader`, `StrataActionCardRow`, and semantic token-backed controls. | Use `gentle` for sheet presentation and group transitions; use `.contentTransition(.numericText())` for numeric summaries and a Reduce Motion crossfade. | Ad-hoc toolbar capsules, filter-chip wrapping, ambiguous multi-action rows, negative-margin positioning, and raw colors. |

## 6-Dimension design specification

- **Visual modes:** `Strata-Core` (native solid foundation), `Strata-Glass`
  (functional-layer material), `Independent-Glass` (detached host material),
  and `Independent-Custom` (consumer-owned detached styling).
- **Two-stage verbal spec workflow:** Stage 1 names the terminology and
  relationships; Stage 2 records the parameter table. Implement directly in
  product or design-system code after the verbal specification. Do not create
  throwaway HTML or `Prototype/` code demos.
- **Size-aware geometry:** concentric radii narrow as `32 -> 24 -> 16 ->
  Capsule`; dense collections and custom keyboards use the `4–8pt`
  `compactCellRadius` resolved from `radius.small`.
- **Alignment:** same-row controls use `.strataControlCenter` or
  `.strataInputBaseline`; icon-and-copy rows use `.firstTextBaseline`.
- **Anti-collision:** Glass is limited to the functional layer while Cards,
  Lists, forms, and keypads remain solid content layers; never use Glass-on-
  Glass. Use one bottom `.safeAreaInset(edge: .bottom)` stack in
  `Content -> Snackbar -> DockedBar -> Safe Area/Keyboard` order. Detached
  hosts such as `UITextField.inputView` receive explicit `theme` and
  `colorScheme`.
- **Macro layouts:** `Compact-Portrait` targets iPhone portrait,
  `Wide-Touch` targets iPhone landscape and iPad, and `Desktop-Pointer`
  targets macOS.

## Required consumer document

Create `docs/design-contract.md` in every consuming repository by copying the
template below and replacing every bracketed value. Keep the headings exactly
as written so shared CI can validate the contract mechanically.

```markdown
# [Product] Design Contract

## Design system & version

- Package: `shared-design-system` [exact semver or 40-character revision]
- Token source: `DesignTokens` [version/revision]
- Native components: `Strata` [version/revision]
- Web components (if applicable): `Basalt` [version/revision or N/A]
- Platforms: [iOS/macOS/web/etc.]
- Appearance modes: `light`, `dark`
- Minimum accessibility/platform support: [product-specific baseline]

## Semantic token profile

- Brand primary: `color.brand.primary` → [product semantic meaning]
- Brand secondary: `color.brand.secondary` → [product semantic meaning]
- Surfaces:
  - `color.surface.canvas` → [meaning]
  - `color.surface.raised` → [meaning]
  - `color.surface.inverse` → [meaning]
- Text hierarchy:
  - `color.text.primary` → [meaning]
  - `color.text.secondary` → [meaning]
  - `color.text.disabled` → [meaning]
- Product business tokens:
  - `[product.token.id]` → [business meaning and upstream token binding]

All bindings use upstream semantic tokens. Business views must not contain
literal colors or create a second token table.

## Required view states

Every page and reusable component covers all four states:

| State | Required behavior |
| --- | --- |
| `populated` | [representative content and interaction] |
| `empty` | [no-content explanation and next action] |
| `loading` | [progressive/loading treatment] |
| `error` | [recoverable error, message, and retry path] |

- Dynamic Type/text scaling: [supported range and truncation policy]
- Responsive sizes/layouts: [compact/regular widths, web breakpoints, etc.]
- Accessibility: [labels, focus order, contrast, reduced motion behavior]
- Appearance coverage: each state is verified in both `light` and `dark`.

## Redlines & CI gate

- Never use bare `#RRGGBB`, `Color(red:...)`, `UIColor(red:...)`, or `rgb(...)`
  in business views.
- Never create a duplicate or private replacement for an upstream base
  component.
- Static gate: `python3 scripts/ci/design_contract.py --contract docs/design-contract.md`
- Visual gate:
  `python3 scripts/ci/design_contract.py --contract docs/design-contract.md`
  `--visual --states populated,empty,loading,error --appearances light,dark`
- Snapshot evidence: [artifact path or CI job name]
- Reviewer evidence: [design.md path and review job]
```

The exact package, token, and component revisions must be resolved from one
immutable upstream source. Do not claim that a future release is available.
Use semantic token IDs rather than raw color values, and document any
product-specific token as a binding to an upstream semantic token. A view that
has no data still needs an explicit empty state; a request in flight needs an
explicit loading state; and failed data or rendering needs an explicit error
state. State coverage applies to the page shell and to every reusable
component whose content can independently be absent, loading, or failed.

The static gate checks the contract structure, exact upstream pin, token
bindings, required states, appearance declarations, and redlines. The visual
gate captures representative screens or snapshots for every required state in
both `light` and `dark`, with Dynamic Type or responsive-size evidence where
the platform supports it. A green static check is not a substitute for visual
evidence.

## AI collaboration flow

The roles below keep discovery, design, implementation, and acceptance
separate:

1. **Explorer** — Read-only. Inspect the business repository's routes, existing
   upstream components, and `docs/design-contract.md`. Report facts with
   file/line evidence; do not edit product code or propose an unverified
   contract.
2. **Designer** — Do not read business implementation details and do not edit
   code. Consume the Explorer receipt, `docs/design-contract.md`, and the
   upstream `ai/` contract to produce `design.md` with page structure,
   semantic-token bindings, all four states, both appearances, and
   accessibility/responsive acceptance criteria. When a reusable variant,
   layout primitive, or more than 15 lines of unsupported layout/chrome glue
   are needed, escalate upstream first; do not design an app-local workaround.
3. **Writer** — Consume `design.md` and the frozen consumer contract. Implement
   the demo or view code with upstream components and tokens, cover every
   required state and appearance, and produce the required light/dark
   screenshots or snapshots. Do not silently expand the contract.
4. **CI & Reviewer** — Run the static design-contract gate and the
   snapshot/screenshot acceptance command. Compare the implementation and
   evidence with `design.md` on two axes: contract/scope compliance and
   quality/accessibility/redlines. A passing static check alone is
   insufficient.

The TL owns the upstream-first split when the Explorer parity check finds a
missing reusable primitive. After a downstream task validates a reusable
layout or motion primitive, the Writer and CI/Reviewer must record the
backport to `shared-design-system` and remove the downstream local glue before
the product task is considered complete.

The Explorer receipt and Designer `design.md` are evidence artifacts. They
must identify the same contract revision that the Writer and CI validate.
