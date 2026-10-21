# Strata v0.2 geometry and style CSS

This additive specification records the web geometry and typography tokens used
by the Strata v0.2 visual baseline. Existing style IDs and values remain
unchanged.

The source adds `radius.control` (16), `radius.card` (24),
`radius.container` (32), and `dimension.control.strata` (40). It also adds the
web typography IDs `typography.strata.body`, `title`, `section`, and `meta`,
whose sizes are 14, 32, 18, and 12 respectively. The generated
`@leepepe/design-tokens/styles.css` asset exposes namespaced `--lp-*` custom
properties for spacing, geometry, and typography. It is a data asset, not a
Tailwind preset or a default theme.

Web consumers may import the CSS subpath directly:

```css
@import '@leepepe/design-tokens/styles.css';
```

Adapters remain responsible for applying these values and for native platform
scaling and Dynamic Type behavior.
