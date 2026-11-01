# StrataTabularLayout

`StrataTabularRowMetrics` centralizes dense row geometry such as index width,
checkbox target, minimum row height, control spacing, compact badge height,
cell radius, and border hairline. Its throwing initializer resolves metrics
from the local DesignTokens target.

`StrataInlineHint` provides compact inline metadata and `StrataBottomSlot`
omits inactive bottom content instead of reserving hidden height. Keep rows on
one shared horizontal grid and pass an explicit theme to consuming controls.
