# StrataIndexRail — unreleased

`StrataIndexRail` is a 24 pt-wide caller-driven quick index. Each item has an
identifier, short visual label, and full accessibility title; tapping or
vertically dragging an item invokes `onSelect` with its identifier. Empty item
arrays render no placeholder rail.

```swift
let items = [StrataIndexRailItem(id: "bar", shortLabel: "B", fullTitle: "Barbell")]
StrataIndexRail(theme: theme, items: items, activeID: "bar", showsHUD: true) { id in
    selectedID = id
}
```

The active item uses the theme accent and may show a full-title HUD pill. The
rail owns no filtering, scrolling, timer, or localization state.
