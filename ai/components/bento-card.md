# StrataBentoCard

`StrataBentoCard` is a solid, config-only telemetry card for equal-height
side-by-side compositions. `StrataBentoCardConfiguration` accepts a Tier 1
title, an untruncated Tier 2 primary readout, optional status text, a fixed
instrument, metric rows, and an optional fixed host width.

```swift
let configuration = StrataBentoCardConfiguration(
    title: "CPU Load",
    primaryReadout: "16.81 GB",
    instrument: .progressRing(value: 16.81, total: 24),
    rows: [StrataMetricRowItem(key: "Memory", value: "8.00 GB")],
    hostWidth: 169
)
StrataBentoCard(theme: theme, configuration: configuration)
```

The card locks the header to 22pt, every active instrument band to a unified
48pt, and each metric row to 18pt. It applies the required
`.padding(12).frame(width: hostWidth)` host framing and a 16pt solid card
surface. Instrument inputs reject invalid totals rather than silently
substituting values.
