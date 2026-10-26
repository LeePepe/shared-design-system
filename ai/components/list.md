# StrataList (unreleased)

This additive SwiftUI component is absent from the Strata 0.3.0
release. Evaluate the reviewed component revision together with its required
Strata foundation revision and exact DesignTokens dependency. It introduces
no released package version, business model, storage or navigation destination.

`StrataList<Data, ID, Header, Leading, Primary, Secondary, Trailing, Footer>`
accepts any `RandomAccessCollection`, a caller-supplied stable ID key path,
and caller-owned selection. All six content slots are generic SwiftUI views.

```swift
StrataList(
    theme: theme,
    surface: .glass,
    items: notes,
    id: \.id,
    selection: .single($selectedID),
    selectedLabel: Text("Selected"),
    isRowEnabled: { $0.canSelect }
) {
    Text("Design notes")
} leading: { note in
    Image(systemName: note.symbol)
} primary: { note in
    Text(note.title)
} secondary: { note in
    Text(note.summary)
} trailing: { note in
    Text(note.metadata)
} footer: {
    Text(selectionContext)
}
```

`theme` and `surface` are required. `notes`, all of its fields, `selectedID`
(of type `Note.ID?`) and `selectionContext` belong to the caller. Resolve
`StrataTheme(theme:brand:)` outside rendering and handle unchanged
provider errors there. The List never resolves tokens, invents colors or chooses
an ambient mode or brand. Use provider-supported `strata-blue`, `strata-green`,
`strata-pink`, `strata-yellow` or `strata-purple` with the required foundation;
legacy supported brands remain foundation-defined.

The header/footer-free overload requires the same arguments and four row
builders, beginning with `leading`. Use `EmptyView` for an unused slot. Supply
localized content; `selectedLabel` defaults to localized SwiftUI `Text("Selected")`
and may be replaced. `isRowEnabled` defaults to `true` for each item.

`StrataListSelection<ID: Hashable>` has exactly three cases:

| Case | Behavior |
| --- | --- |
| `.single(Binding<ID?>)` | Activating a row selects that identity. Repeating the selected row leaves it selected and makes no redundant binding write. The caller may clear selection externally. |
| `.multiple(Binding<Set<ID>>)` | Activating a row toggles that identity, preserving all other identities. |
| `.readOnly(Set<ID>)` | Static rows display the supplied selection without button or activation semantics. |

Identity never comes from the row index. Reordering items preserves selection
by ID. The component does not prune IDs that disappear from the collection,
automatically select the first item, or validate caller uniqueness. Keep IDs
unique and maintain any desired validity policy at the caller boundary.
Bindings are read afresh; external changes appear on the next view update.
Constructing the component does not write selection.

Interactive rows use native `Button` activation and disabled input semantics.
`.disabled(true)` blocks all row activation; `isRowEnabled` blocks individual
rows. Read-only is a presentation mode, separate from disabled interactive
rows. Header/footer descendants remain caller views. Row builders are labels:
use text, images or other noninteractive content; place independent controls
outside the row label to avoid nesting native buttons.

Selected rows use the neutral `.selected` surface, a checkmark, the visible
selected label and the accessibility selected trait. Selection replaces the
trailing metadata. Hover/press uses neutral `.hover`; it never tints the whole
row with the brand color. Native focus is retained with a continuous 2pt
accent focus outline. Native tab/activation behavior is system-managed; no
arrow-key selection policy, automatic focus movement or keyboard shortcut is
installed. Read-only rows retain combined text and selected semantics.

The reading plane uses the shared `.card` surface recipe and a continuous
24pt corner, 12pt inset and 4pt row gaps. Rows have 16pt corners and 12pt
padding, with at least 44 × 44pt interactive targets. A suitable caller-owned
32pt outer region supplies the single blur; the List adds no material blur.
Glass/solid and Reduce Transparency follow the shared foundation, preserving
explicit palette/mode and layout. The fixture composes through shared
`StrataSpecimen`, rather than copying its outer shell or material recipe.

Primary text uses semibold `.body`; secondary text uses `.subheadline` and
metadata/selected labels use `.caption`, all from explicit theme roles.
Header uses `.headline`; footer uses `.caption`. Text grows vertically without
a line limit or fixed row height. At accessibility sizes, primary/secondary
copy uses the full row width, with the icon and metadata/selection below it. Leading
content is decorative for accessibility; put meaningful icon information in
the primary or secondary slot. Caller content may override semantic styling.

The [fixture](../../Tests/Fixtures/ListReview/README.md) contains actual SwiftUI
selection, disabled/read-only/multiple, external-state, reorder and narrow-text
checks. The twenty palette/mode/material captures, ten forced fallbacks and
actual simulator Reduce Transparency check are specified there. Runtime text
bounds accompany captures for inspecting full-coverage text against actual
composited surfaces. Verified SHA, dependency provenance and raw PNG paths
belong in the PR/evidence receipt. No VoiceOver, keyboard, hover,
minimum-OS or physical-device acceptance is inferred from source or screenshots.
Rollback removes these additive call sites and restores a reviewed revision;
there is no stored data to migrate.
