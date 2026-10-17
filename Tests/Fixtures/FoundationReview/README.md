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

Resolve the public exact DesignTokens 0.2.0 release at
`87bef8fbab5bf67a748815d7ed04d7ae199f760a` without package-root or generated-workspace
mirrors. Record the exact native/provider revisions and public-origin proof.
Do not commit generated projects, screenshots, caches or runtime logs. Fixture
compilation alone does not establish rendered component or interaction acceptance;
those remain with the original component authors on their final merged base.
