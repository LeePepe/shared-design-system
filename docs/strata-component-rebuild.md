# Strata component rebuild

The Owner's current request supersedes the old v1 component list and all old
unmerged component implementations. Rebuild from the released color bridge and
preserve the Foundations / Controls / Components / Patterns organization, the published
resolver, exact token pin, platform floors and repository red lines. No old
component source is copied into the rebuild.

These are internal source groups within the single `NativeDesignKit` layer.
The historical [v1 specification](native-design-kit-v1-spec.md),
[plan](native-design-kit-v1-plan.md) and [tasks](native-design-kit-v1-tasks.md)
are superseded for this rebuild and retained only for history.

Each component has one writer, one worktree, one branch, one PR and its own
consumer contract. The first Button PR supplies only the minimum common theme,
material and test-only SwiftUI fixture UI support that the other components
need. Public API changes are recorded as unreleased; no version/tag is created.

The first batch contains ten components selected from the HeroUI component
catalogue. That catalogue informs names and inventory only. Native behavior
and rendering use SwiftUI and the accepted Strata v0.2 rules. Real SwiftUI PNG
evidence is generated outside git for each PR by XCTest UI automation of
standalone SwiftUI iOS fixture apps. The [portable runner and reuse
instructions](../Tests/Fixtures/Support/README.md) let each component add its
own fixture without editing shared support. No native hosting/window helpers
are used. Screenshots alone do not claim VoiceOver or minimum-OS acceptance.

| First-batch component | Delivery |
| --- | --- |
| Button | This foundation/Button candidate |
| Card | Separate component PR |
| TextField | Separate component PR |
| Switch | Separate component PR |
| Checkbox | Separate component PR |
| RadioGroup | Separate component PR |
| Slider | Separate component PR |
| ProgressBar | Separate component PR |
| Avatar | Separate component PR |
| Chip | Separate component PR |

Theme and brand are explicit. The exact provider supports ocean/graphite only;
the broader five-color theme direction is a documented gap, never a local
palette. On iOS, semantic fonts scale with Dynamic Type; the Button fixture UI
test measures localized long-label height growth at accessibility2 in a 320 pt
board, verifies full-label/frame containment and captures the actual iOS app.
The previous macOS host snapshots are superseded; macOS semantic fonts do not
demonstrate iOS Dynamic Type scaling and no macOS rendered UI evidence is
claimed. The [Button fixture record](../Tests/Fixtures/ButtonReview/README.md)
maps each moved hosting-based check to its equivalent or stronger UI test.
Content/main-action surfaces
remain readable and solid; suitable outer surfaces may opt into native material
with a Reduce Transparency solid path. Review must distinguish screenshots
of actual glass from screenshots of the solid fallback.

Contrast tests use actual DesignTokens RGBA values for accent/onAccent and
foreground/surface in both provider brands and themes, requiring at least
4.5:1 for normal text. These opaque-pair checks do not establish contrast on
every composited Glass background.
