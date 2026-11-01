# StrataStickySectionHeader

`StrataStickySectionHeader` is a compact, one-line section header with an
optional accessory. It keeps a strict 44 pt maximum envelope, no more than 4 pt
outer vertical padding, and uses the supplied theme surface. Accessory hit
targets may be 44 by 44 pt, but visual chrome cannot increase header height.
Its DesignTokens-backed initializer throws, so construct it with
`try StrataStickySectionHeader(...)`.

Long dynamic titles belong in a dedicated dynamic row; this header is not a
two-line title container.
