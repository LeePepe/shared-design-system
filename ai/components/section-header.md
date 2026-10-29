# StrataSectionHeader — unreleased

`StrataSectionHeader` is a borderless semantic heading for caller-owned
sections. It accepts a required title, optional subtitle and badge text, and a
trailing view for caller-owned actions.

```swift
StrataSectionHeader(theme: theme, title: "Barbell", subtitle: "Chest", badgeText: "3") {
    Button("More") {}
}
```

The title is exposed with the `.isHeader` accessibility trait. Nil or empty
optional values do not create placeholder text or layout gaps.

The outer row uses `.center` alignment without a subtitle and
`.firstTextBaseline` when a subtitle exists, so single-line titles align with
44pt trailing controls while multiline headings retain their text baseline.
