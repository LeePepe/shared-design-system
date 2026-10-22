# Spec 004: Strata category colors

Status: Owner-approved and frozen for TK1a on 2026-10-21 (UTC+8).

The public IDs `product.strata.category.1` through
`product.strata.category.8` provide eight classification colors in both
explicit themes. They are presentation roles, not business identities; a
consumer must provide a glyph or text label alongside the color.

## Signed values

| ID | Light | Dark |
| --- | --- | --- |
| 1 | `#39708E` | `ref product.strata.chart.primary` (`#9DC4D6`) |
| 2 | `#9579AE` | `#EAD5FF` |
| 3 | `#03595D` | `#71ABAA` |
| 4 | `#89507A` | `#C48FBF` |
| 5 | `#4B5416` | `#9BA670` |
| 6 | `#B16F48` | `#E3A98A` |
| 7 | `#4A4B7F` | `#A5A8D8` |
| 8 | `#756C61` | `#B8AFA6` |

## Rules

- **R-a:** Every category color contrasts at least 3:1 with each of the five
  `product.strata.<family>.surface.card` surfaces in both themes. These are
  declared as `contrastPairs` with `use: "non-text"`.
- **R-b:** Category glyphs contrast at least 3:1 with a badge background made by
  mixing the category color over the card at 14% in light mode and 24% in dark
  mode. A component using another recipe must re-check this threshold.
- **R-c:** Each category color has CIEDE2000 ΔE00 of at least 15 from Strata
  success, warning and error in both themes.
- **R-d:** Categories 1–3 have pairwise CIELAB ΔL* of at least 10 in both
  themes.
- **R-e:** All category pairs have CIEDE2000 ΔE00 of at least 13 in both
  themes. Color-vision simulation has no threshold; labels remain required.
- **R-f:** This is additive. Existing token IDs and resolved values are
  unchanged; dark category 1 directly references the existing chart primary.

The thresholds are executable in `tests/strata.test.mjs`; generation and
source validation enforce the card gates.
