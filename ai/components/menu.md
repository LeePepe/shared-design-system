# StrataMenu — unreleased

`StrataMenu` is a caller-owned native SwiftUI menu for compact actions such as
the more-actions control on a workout set. It requires an explicit
`StrataTheme`, a localized accessibility label, and caller-owned
`StrataMenuAction` values. Actions may be standard or destructive and can be
disabled without changing their identity.

```swift
StrataMenu(
    theme: theme,
    label: "More actions",
    actions: [
        StrataMenuAction(id: "copy", title: "Copy set", systemImage: "doc.on.doc") {
            copySet()
        },
        StrataMenuAction(
            id: "delete",
            title: "Delete set",
            systemImage: "trash",
            role: .destructive
        ) {
            deleteSet()
        }
    ]
)
```

The trigger has the token minimum hit size and does not own row completion,
navigation, localization, persistence, or business data.
