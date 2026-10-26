# Foundation runtime specimen

Test-only SwiftUI application for actual surface evidence; it supplies synthetic
reading content without implementing or testing a component. Generate its Xcode
project from `project.yml`. Include `../Shared/StrataSpecimen.swift` and enable
DEBUG testability for internal native surface composition. No native hosting
helpers are used.

Launch arguments are required: `--brand strata-blue --mode light --surface glass`.
Supported mode/material values are explicit light/dark and glass/solid. Add
`--reduce-transparency` for the same-theme opaque fallback. The internal preference
override is fixture-only; shipping views follow the system setting.

Resolve the containing `shared-design-system` revision and its repository-local
`Packages/DesignTokens` target. The historical external DesignTokens 0.2.0
tag remains immutable compatibility history, not the active provider route.
Record the exact root/provider revisions and source-bound proof.
Do not commit generated projects, screenshots, caches or runtime logs. Fixture
compilation alone does not establish rendered component or interaction acceptance;
those remain with the original component authors on their final merged base.
