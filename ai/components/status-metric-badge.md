# StrataStatusMetricBadge

`StrataStatusMetricBadge` centers a `StrataProgressRing` and monospaced value
in a row with a 24 pt minimum height. The ring is a 14 by 14 pt optical box
with a 2 pt stroke and accepts `nil` progress for an indeterminate state.

`StrataStatusRing` is a compatibility typealias for `StrataProgressRing`.
Values and formatting remain caller-owned; the explicit theme is required.
