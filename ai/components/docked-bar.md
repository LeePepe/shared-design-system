# StrataDockedBar — unreleased

`StrataDockedBar` is a caller-owned floating container for bottom-docked
controls. It requires an explicit `StrataTheme`, defaults to `.glass`, and
falls back to the same theme's solid region when Reduce Transparency is active.

```swift
StrataDockedBar(theme: theme) {
    HStack { Text("Search"); Button("Done") {} }
}
```

The component owns no product state, actions, labels, timers, or localization.
Its outer radius is 32 pt, inner padding is 16 pt, and horizontal safe margin
is 12 pt.
