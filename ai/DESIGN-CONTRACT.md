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
   accessibility/responsive acceptance criteria.
3. **Writer** — Consume `design.md` and the frozen consumer contract. Implement
   the demo or view code with upstream components and tokens, cover every
   required state and appearance, and produce the required light/dark
   screenshots or snapshots. Do not silently expand the contract.
4. **CI & Reviewer** — Run the static design-contract gate and the
   snapshot/screenshot acceptance command. Compare the implementation and
   evidence with `design.md` on two axes: contract/scope compliance and
   quality/accessibility/redlines. A passing static check alone is
   insufficient.

The Explorer receipt and Designer `design.md` are evidence artifacts. They
must identify the same contract revision that the Writer and CI validate.
