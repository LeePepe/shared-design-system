# StrataNumericKeypad (unreleased)

`StrataNumericKeypad` is a compact SwiftUI numeric input surface for detached
input hosts. It uses an explicit `StrataTheme` and `ColorScheme`, a fixed
`232pt` three-column matrix, and `StrataNumericKeypadMetrics` for shared
geometry. The central grid is 3x4; side columns are `68pt` wide and the Done
key uses `theme.interactiveAccent` with `theme.onInteractiveAccent`.

```swift
let keypad = try StrataNumericKeypad(theme: theme, configuration: .init(mode: .decimal),
                                     colorScheme: .light) { key in
    // Apply the key to caller-owned input state.
}
```

`StrataNumericKeypadKey` reports digits, decimal separator, backspace, side
actions, and Done. Labels remain single-line and use a `0.85` minimum scale
factor; keypad cells are solid token surfaces rather than Glass.
