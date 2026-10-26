# StrataDialog — unreleased

`StrataDialog` is a caller-owned, centered modal surface for focused content
such as RPE selection. It requires an explicit `StrataTheme` and an optional
`StrataDialogPresentation` binding. The presentation validates its title,
close label, loading/error status text, guard reason, unique action IDs, and
single-primary-action rule before rendering.

The presentation supports `.populated`, `.loading(message:)`, and
`.error(message:)` states. Dismissal is either `.dismissible` or
`.guarded(reason:)`; guarded close, cancel, Escape, and optional outside-tap
attempts remain presented and expose the guard reason. Actions return
`.stayPresented` or `.dismiss`, and UUID checks preserve a replacement
presentation when an action changes the binding re-entrantly.

`StrataAlertDialog` is the native SwiftUI confirmation variant for destructive
or irreversible operations. Both components use caller-owned state, explicit
theme resolution, accessible labels, and native platform interaction semantics.
They do not own business state, localization, navigation, persistence, or a
default theme.
