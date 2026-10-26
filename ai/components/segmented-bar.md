# StrataSegmentedBar — unreleased

`StrataSegmentedBar` is a caller-driven single-selection control. Items use
stable string IDs, support horizontal or vertical layout, and may expose a
positive badge count. Selection is supplied as a `Binding<String>`; the
component does not own the selected domain state.

```swift
let items = [
    StrataSegmentedItem(id: "all", title: "All", badgeCount: 7),
    StrataSegmentedItem(id: "legs", title: "Legs")
]

StrataSegmentedBar(
    theme: theme,
    items: items,
    selection: $selection,
    axis: .horizontal
)
```

Selected state and badge counts are exposed to accessibility, text grows
naturally with Dynamic Type, and disabled bars do not write to the binding.
