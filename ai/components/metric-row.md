# StrataMetricRow

`StrataMetricRow` is a config-only telemetry row with an explicit
`StrataTheme`. Construct a `StrataMetricRowItem` with a one-line Tier 1 key
(CJK up to 4 characters or English up to 8) and a caller-formatted Tier 2
value. Values use monospaced digits, never render numeric ellipsis, and retain
their intrinsic width.

```swift
let item = StrataMetricRowItem(key: "CPU Load", value: "16.81 / 24.00 GB")
StrataMetricRow(theme: theme, item: item)
```

Rows use the shared control-center alignment guide and an 18pt metric band.
`instrument: true` adds the standard 14pt indeterminate progress ring. Theme
and token errors remain explicit at the caller boundary; no default theme or
business data is introduced.
