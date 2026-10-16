# Strata fidelity foundation repair

This additive scope follows the accepted Strata v0.2 reference at
`b4bff430517ed2e2944f814d8b5ab89a1866ee33`. The earlier restriction that provider
work remain out of scope is superseded for this explicit five-family repair.

## Contract and acceptance

The native library consumes explicit five-family provider IDs at exact 0.2.0;
legacy ocean/graphite behavior remains. Public surface roles expose neutral
region/card/inset/hover/selected colors without introducing a palette table.
Brand states and seed use named provider roles. Errors propagate unchanged.

An explicit region uses a 32pt caller contour and one native regular material
blur backed by provider panel RGBA, a fine rim, top highlight and low contact
shadow. A nested card uses a 24pt caller contour and denser content RGBA over
that inherited blur, with a weaker edge. Standalone cards may supply their own
single blur. Inset/hover/selected roles remain opaque and do not float. Existing
no-role calls preserve their original treatment while component adoption is
reviewed independently. Solid and Reduce Transparency use opaque surfaces and
remove material decoration; fixture ambient also disappears. Layout, brand and
mode remain explicit and unchanged. No CSS/native blur equivalence is claimed.

Tests cover fresh provider role resolution, exact errors, legacy behavior,
neutral state planes, one inherited blur, and solid/fallback equivalence. Native
runtime specimens separately check actual composites, hierarchy and geometry.
`Tests/Fixtures/Shared/StrataSpecimen.swift` is a reusable test-only SwiftUI
composition. Fixture targets include it explicitly and use DEBUG testability;
it owns no business data or UIKit/AppKit hosting code. Component fixtures retain
their interaction and accessibility evidence.

## Candidate provenance

Local candidate rendering can use an isolated bare Git mirror tagged v0.2.0 at
the frozen provider candidate SHA, with task-scoped SwiftPM mirror/cache paths.
That tag is never pushed and does not establish a provider release. Every run
records native/provider SHA and candidate-only provenance. A final committed
lockfile and remote required checks wait for a separately authorized immutable
provider release; source or visual success alone does not satisfy that gate.

Explicit legacy Card planes use 94% of the existing raised-surface provider
color, with the same shared material edge/shadow roles. Tests composite against
both black and white extremes and require secondary text >=4.5. Existing no-role
legacy callers retain their previous treatment; no legacy RGB values change.
