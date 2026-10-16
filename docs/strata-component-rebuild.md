# Strata component rebuild

The Owner's current request supersedes the old v1 component list and all old
unmerged component implementations. Rebuild from the released color bridge and
preserve only Foundations / Controls / Primitives organization, the published
resolver, exact token pin, platform floors and repository red lines. No old
component source is copied into the rebuild.

Each component has one writer, one worktree, one branch, one PR and its own
consumer contract. The first Button PR supplies only the minimum common theme,
material and test-only SwiftUI screenshot support that the other components
need. Public API changes are recorded as unreleased; no version/tag is created.

The first batch contains ten components selected from the HeroUI component
catalogue. That catalogue informs names and inventory only. Native behavior
and rendering use SwiftUI and the accepted Strata v0.2 rules. Real SwiftUI PNG
evidence is generated outside git for each PR. Mac screenshots alone do not
claim device interaction, VoiceOver or minimum-OS acceptance.

Theme and brand are explicit. The exact provider supports ocean/graphite only;
the broader five-color theme direction is a documented gap, never a local
palette. Semantic fonts scale with Dynamic Type. Content/main-action surfaces
remain readable and solid; suitable outer surfaces may opt into native material
with a Reduce Transparency solid path. Review must distinguish screenshots
of actual glass from screenshots of the solid fallback.
