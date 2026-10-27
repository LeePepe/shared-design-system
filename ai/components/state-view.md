# StrataStateView — unreleased

`StrataStateView` is a solid, caller-owned card for empty, loading, and error
states. The caller supplies localized title/message strings and an optional
action. Loading renders a non-interactive progress state; error remains
visually distinct from empty and can expose a retry action.

```swift
try StrataStateView(
    theme: theme,
    kind: .error,
    title: "Could not load history",
    message: "Try again to refresh this workout.",
    actionTitle: "Retry",
    action: retry
)
```

The initializer is throwing because it resolves DesignTokens-backed component
metrics.

The view owns no network request, persistence, navigation, localization, or
business state. It uses only the explicit theme and local DesignTokens-backed
surface metrics.
