# Button native design review

This review slice covers `NativeButton` and its live Button review board. It does
not ship a consumer screen or change the Controls/Foundations prerequisite PRs.

## Sources and decisions

Read on 2026-10-16:

- [Apple HIG Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons):
  distinguish hierarchy with style; give grouped choices the same size; use clear
  action labels, familiar symbols and semantic roles; show activity for delayed work.
- [Apple HIG Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility):
  support larger text, keyboard access and sufficiently sized controls. Its platform
  table gives 28 points as the macOS default and 44 points as the iOS default.
- [Apple HIG Materials](https://developer.apple.com/design/human-interface-guidelines/materials)
  and [Applying Liquid Glass to custom views](https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views):
  Glass belongs to floating interactive controls above identifiable content; use native
  material and interaction behavior instead of drawing a decorative frosted shell.
- [Finesse v0.20.0, revision 5050b6c](https://github.com/mouse-lin/finesse-skill/tree/5050b6c71e27b829d1b3087d2be889d29c60db00):
  read `SKILL.md`, component-scope, anti-cheap, audit and preflight. This is component
  scope: no page skeleton, hero engine, palette rotation or build-log entry. The native
  board replaces the HTML preview. System states replace forced web pseudo-classes.

**SwiftUI API facts:** `Button(role:action:label:)` preserves native cancel and
destructive semantics on the library's iOS 15/macOS 12 floors. The wrapper forwards
an optional `ButtonRole` without inventing a new role type. `.borderedProminent`,
`.bordered`, `.plain` and, with compiler/runtime guards, `.glass` own the bezel,
press, pointer and keyboard-focus feedback. The native disabled environment blocks
activation. The indicator slot keeps a fixed size supplied by the caller.

**Team adaptation choices:** an omitted role means ordinary action semantics; it
does not introduce a theme or token fallback. The activity presentation also defaults
to adjacent progress. Existing calls keep
compiling. A destructive role uses the supplied `statusCritical` tint and, for a
prominent control, the matching `statusOnCritical` label. Other actions retain the
supplied info/on-info pair. These are explicit repository token decisions, not a
claim that Apple specifies these token names or color values. The fixture does not
make deletion the default Return action. Keyboard shortcuts and confirmation remain
caller decisions for the actual context.

Native styles own bezel padding. `metrics.padding` is no longer added inside a
native button; `metrics.minimumHitSize` remains inside the label so the target is
part of the real button, rather than an inactive outer frame. The supplied 28/44
values are minimum label targets, not promised exact bezel heights: a native style
can add its own insets. The review board uses one `.regular` control size and the
same `r.reviewMetrics` throughout. It inherits body/headline/caption typography and
provider spacing, and creates no local style or color table.

Loading keeps the original action label visible beside native circular progress.
The default adjacent activity presentation reserves matching leading and trailing slots, centering the resting label and retaining its position while loading. The trailing indicator slot, sized by the explicit icon metric, is reserved in both
resting and loading states so the indicator cannot overlap or displace the label. The accessible button label remains the
caller label; `loadingLabel` is the accessible value. Icon-only callers select `activityPresentation: .replacingLabel` to center their symbol and replace it with progress without changing geometry. Unavailable labels use the explicit secondary-text token in addition to native disabled semantics and native bezel changes. The native small progress size avoids the desktop regular spinner overflowing its slot. Loading disables the real
button and prevents repeat activation. Native styles decide the disabled appearance.
The library does not start, cancel or retry work.

## Eight-state ownership and evidence

| Finesse state | Owner and native implementation | Review path |
| --- | --- | --- |
| Default | Library selects the native style and explicit themed colors; caller supplies the label/action. | Prominent, bordered, plain and icon specimens. |
| Hover | SwiftUI/native style owns actual pointer feedback and macOS tooltip behavior. No forced hover class, scale or custom gesture. | Move a pointer over live specimens; capture independently. |
| Focus-visible | SwiftUI owns native keyboard focus and its immediate focus ring. Caller owns shortcuts and app keyboard settings. No animated outline or replacement focus layer. | Navigate the live board with keyboard/Full Keyboard Access; capture independently. |
| Active | SwiftUI owns native press/touch feedback and activation semantics. | Hold a real press, then release; check the action count. |
| Disabled | Caller `.disabled(true)` and library loading use native disabled semantics, appearance and focus behavior. A web cursor rule has no native equivalent. | `review-disabled` must leave the count unchanged. |
| Loading | Library preserves geometry, shows progress and disables activation. Caller owns the task, cancellation and status text. | Pinned `review-loading`, plus `review-start-loading` with a real 3-second cancellable `.task`. |
| Error | Caller owns the cause, recovery action and explanatory text. A generic button cannot diagnose an operation. Destructive is a role, not an error state. | Actual failure/retry belongs to the consumer; this synthetic save does not pretend to produce one. |
| Success | Caller owns the observable effect/status; the button returns to resting state. No toast, celebration or custom success animation. | The live example changes its adjacent status to “Copy saved” and keeps the action count visible. |

The Finesse web one-line rule yields to native localization and Dynamic Type:
labels can grow vertically without clipping or forcing a smaller font. Its literal
opacity/cursor, CSS outline and custom active-transform prescriptions are adapted
to native disabled/focus/press behavior. Apple semantics and existing provider tokens
remain authoritative. The localized document action deliberately exercises a long
Chinese label at narrow and accessibility sizes.

## Live board contract

Use `FIXTURE_PAGE=Button`. Identifiers are `review-save`, `review-secondary`,
`review-plain`, `review-icon`, `review-disabled`, `review-loading`,
`review-start-loading`, `review-cancel`, `review-delete`, `review-glass`,
`review-localized`, `review-count` and `review-result`.

Each enabled action increases the shared count. Save a Copy increments it once,
sets loading immediately, then shows Copy saved on completion. Repeated activation
while loading is disabled. The task cancels with the board's lifetime and checks
cancellation before publishing completion. Cancel and Delete Copy have distinct
native roles and visible caller result text. The icon has an explicit accessible
label and tooltip. All data and operations are synthetic.

The floating control uses the native Glass style only with a supporting compiler,
OS, `allowsGlass` and accessibility preference. Hostless rendering explicitly
requests `.bordered` and labels it as fallback. Reduce Transparency and older OSs
also use the labeled bordered fallback. A fallback bitmap does not establish Glass.
The document text supplies recognizable neutral content under the floating control;
there is no decorative material on the surrounding group.

## Verification scope

`NativeButtonDesignTests` measures real SwiftUI hosts to check stable localized
label geometry for ordinary/cancel/destructive roles, the absence of duplicate
metrics padding, and the explicit icon target minimum. Measuring Glass geometry in a native host does not establish
compositor Glass appearance. Role activation, native press/hover/focus, disabled/repeat blocking,
Dynamic Type screenshots and live Glass are integration/reviewer checks; unit geometry
measurements are not evidence for them.

The author runs SwiftPM build/tests. The lead owns the common Xcode fixture build,
UI interaction tests and captures, and an independent reviewer opens the resulting
screenshots. No visual acceptance, contrast measurement, VoiceOver navigation,
minimum-OS runtime or live Glass acceptance is claimed by a compiler/test pass.

The textless activity indicator caps its Dynamic Type at `.large` to keep native
progress inside the explicit icon slot. The action label retains unrestricted
Dynamic Type and its full accessible label/value. This is a layout decision, not
a restriction on user-facing text.
