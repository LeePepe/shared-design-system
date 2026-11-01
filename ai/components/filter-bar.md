# StrataFilterBar

`StrataFilterBar` is a single-line horizontal filter rail. It accepts
`StrataFilterItem` values, an optional `All` item, and either a binding or
callback selection model. The compatibility alias `StrataFilterChipRail`
resolves to the same public type.

Every chip preserves a minimum 44 pt target, exposes selected state to
accessibility, and uses the caller's explicit `StrataTheme`. Items do not wrap;
long titles remain single-line and scroll horizontally.

```swift
StrataFilterBar(theme: theme, items: filters, selection: $selectedFilter)
```
