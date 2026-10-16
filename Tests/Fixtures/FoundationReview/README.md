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

For pre-release provider data use a task-scoped Git mirror, record both source
SHAs, and label screenshots candidate-only. Do not commit mirror configuration,
generated project, screenshots, runtime logs or release claims. Final remote
package verification still requires the authorized provider release.
