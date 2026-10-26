# StrataSnackbar — unreleased

`StrataSnackbar` is a caller-owned, bottom single-item feedback surface. It
requires an explicit `StrataTheme` and a binding to an optional
`StrataSnackbarItem`; the component owns placement, the close affordance, and
the five-second timeout for items without an action.

```swift
let item = try StrataSnackbarItem(
    message: "Set deleted",
    closeLabel: "Dismiss",
    action: try StrataSnackbarAction(label: "Undo") { restoreSet() }
)

let configuration = try StrataSnackbar<Text, EmptyView>.Configuration(
    theme: theme,
    item: $item,
    content: { WorkoutView() },
    bottomBar: { EmptyView() }
)
StrataSnackbar(configuration: configuration)
```

Blank messages, close labels, and action labels throw
`StrataSnackbarConfigurationError`. `StrataSnackbarDismissal` reports
`.timeout`, `.action`, `.close`, or `.escape`. Focus, hover, inactive scenes,
and modal/presentation visibility pause the timeout. Items with actions remain
visible until the caller or user dismisses them.

The content and bottom-bar slots are caller-owned SwiftUI views. The component
does not own business state, localization, a global queue, or a default theme.
