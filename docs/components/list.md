# List implementation and acceptance

The [consumer contract](../../ai/components/list.md) defines the additive public
API. HeroUI supplies the inventory name only; native SwiftUI implementation
follows the accepted [Strata rules](../strata-theme-v0.2.md) and prototype
`b4bff430517ed2e2944f814d8b5ab89a1866ee33`.

The List owns collection presentation and selection activation. Callers own
all identities, values, bindings and row/header/footer content. The native
Button remains the interaction boundary. Single/multiple/read-only selection
is explicit; a read-only row is not a disabled button. Reordering never maps
selection by position, and collection changes never silently prune state.

Only the shared foundation supplies color and material. The List uses one
24pt reading plane containing 16pt neutral row surfaces. It adds no blur,
shadow or palette map. A shared fixture provides the 32pt outer region and
page backdrop. Primary/secondary/trailing typography is semantic, and long
rows grow and reflow at accessibility sizes.

Selection tests check exclusive replacement, repeat-activation writes,
multiple toggling, external changes, preservation of unavailable IDs,
disabled writes and read-only behavior. Public-import tests exercise custom
identity, empty data, all five palettes, explicit solid/glass, and both full
and header/footer-free APIs without writing selection during construction.
The real [ListReview fixture](../../Tests/Fixtures/ListReview/README.md) checks
native activation, disabled coordinate taps, stable identity after reorder,
external binding state, multiple selection, static rows and 44pt targets.

Verification uses SwiftPM build/tests followed by the actual SwiftUI fixture.
Text-frame telemetry is attached with raw screenshots to inspect primary,
secondary, metadata and context contrast on their actual composites.
Final evidence must name clean component head and dependency SHA, distinguish
candidate mirrors from released resolution, and preserve raw PNG provenance.
No gate/policy, shared foundation or existing component source is changed here.
