# StrataNumberSlot

`StrataNumberSlot` is a token-backed numeric input slot configured through
`StrataNumberSlotConfiguration`. Configuration errors propagate from the
provider and construction requires an explicit `StrataTheme`.

The caller owns editing state, formatting, validation messaging, and
localization. The slot is a compact control and must retain its minimum
interactive target without adding surrounding layout chrome.
