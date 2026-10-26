# StrataSearchField and StrataNumberSlot — unreleased

These native SwiftUI controls require an explicit `StrataTheme` and caller-owned
values, labels, localization, and actions. `StrataSearchField` provides a
solid 44 pt search surface, optional result and validation text, and a separate
44 pt clear button when text is populated. `StrataNumberSlot` provides a solid
numeric slot with optional L/R badge and unit, monospaced digits, active and
invalid outlines, and a caller-owned tap action.

```swift
let search = try StrataSearchFieldConfiguration(
    label: "Search exercises", placeholder: "Find an exercise",
    clearLabel: "Clear search", resultSummary: "12 results")
StrataSearchField(theme: theme, text: $query, configuration: search)

let weight = try StrataNumberSlotConfiguration(
    label: "Left weight", displayValue: "20", prefixBadge: "L", unitLabel: "kg",
    isActive: true)
StrataNumberSlot(theme: theme, configuration: weight) { beginEditing() }
```

The controls never import product models, invent labels, or provide a default
theme. Empty numeric values render the caller-provided placeholder (default
`—`), never a fabricated zero. Disabled controls preserve visible values and
do not dispatch actions. This API is additive and unreleased.
