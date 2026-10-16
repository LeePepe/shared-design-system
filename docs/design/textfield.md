# TextField native design review

This slice refines `NativeTextField` and its focused, synthetic review board.
It inherits the [accepted component baseline](native-components-baseline.md)
and leaves secure, search and multiline editors with their existing owner.

## Sources

Read on 2026-10-16:

- [Apple HIG Text fields](https://developer.apple.com/design/human-interface-guidelines/text-fields):
  request short values, retain a separate label when placeholder text disappears,
  group labels and fields with consistent spacing, preserve logical tab order,
  and validate at a time appropriate to the context. Use a text view for longer
  passages. A long title is still a single value, rather than a multiline editor.
- [Apple HIG Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility):
  support larger text and keyboard navigation, label controls for assistive
  technology, and communicate state through more than color. Its platform tables
  recommend default type sizes of 17 pt on iOS and 13 pt on macOS, and default
  control sizes of 44 pt and 28 pt respectively. These are distinct from the
  smaller minimum sizes in those tables.
- [Apple HIG Color](https://developer.apple.com/design/human-interface-guidelines/color):
  maintain meaning and contrast across light/dark and increased-contrast
  contexts; pair status color with words or symbols. System color values should
  not be copied into local constants.
- [SwiftUI TextField](https://developer.apple.com/documentation/swiftui/textfield),
  [rounded-border style](https://developer.apple.com/documentation/swiftui/roundedbordertextfieldstyle),
  [focused](https://developer.apple.com/documentation/swiftui/view/focused(_:)), and
  [onSubmit](https://developer.apple.com/documentation/swiftui/view/onsubmit(of:_:)):
  the actual API documentation and examples, including label/prompt behavior,
  continuous string binding updates, focus binding and hardware/software Return.
- [Finesse v0.20.0, revision 5050b6c](https://github.com/mouse-lin/finesse-skill/tree/5050b6c71e27b829d1b3087d2be889d29c60db00):
  `SKILL.md`, component-scope, anti-cheap, audit and preflight. The native board
  is the component preview. No page skeleton, hero engine, palette rotation,
  HTML imitation or build-log entry applies.

## HIG recommendations, API facts and team adaptations

**HIG recommendations:** the persistent visible labels and useful placeholders
serve different purposes. Vertically stacked fields have consistent widths;
labels and helpers can grow with Dynamic Type. Validation explains both the
cause and the correction. Keyboard traversal and native editing remain intact.
These recommendations do not require an eight-state enum or a specific border
color, radius, shadow or validation timing for every text field.

**SwiftUI API facts:** a string `TextField` updates its binding as editing takes
place. The rounded-border style supplies a system-defined border and native
bezel insets. `.focused` binds the caller's focus state; `.onSubmit` receives
hardware/software Return, and `.disabled` supplies native disabled semantics.
The wrapper retains the existing initializer and single-line editing behavior.
It adds no formatter, validation, submission callback or asynchronous work. The
caller can continue applying ordinary SwiftUI modifiers, including `.focused`.

**Team adaptations:** `NativeTextField` replaces its plain field plus custom
`FieldChrome` with `.roundedBorder`. It uses the explicit theme's primary text,
secondary text when disabled, and information tint. Native placeholder,
selection and bezel appearance receive a local color scheme derived from that
same explicit theme, even when the surrounding app has the opposite appearance.
It neither detects nor changes the surrounding app's theme. Native system bezel
colors remain system-owned, as they are for the accepted native Button styles;
there is no new local color table or fallback.

The control uses `nativeMinimumHitTarget` to reserve the supplied minimum layout
bounds and content shape. A content shape alone does not make the native field's
extra surrounding space focusable: the macOS host experiment found a 24 pt native
bezel inside a 44 pt frame. The component therefore binds a private `FocusState`
to its native field and uses a simultaneous tap gesture across the supplied
target to request native editing focus. An enabled-state guard prevents disabled
target activation. The gesture does not replace native selection/editing gestures
or draw focus feedback. The board uses the component without a hit-target gesture.

The private state is only the component's target-to-native-focus adapter. Caller
`.focused` still sets, clears and observes actual native focus; it remains the
owner of application focus policy, traversal and validation-related requests.
Host tests prove both direct component activation at opposite corners outside the
native bezel and interoperability with a caller focus binding. No explicit focus
input, initializer change or migration is necessary. The board's caller focus
binding handles empty submission through ordinary `.focused`.

Native styles own bezel insets, border thickness and radius, so `metrics.padding`,
`borderWidth` and `cornerRadius` do not add a second chrome layer. This is a
visual change with no public API change. The board uses the shared
`r.reviewMetrics`, regular control size, provider-backed body/caption typography
and spacing. It adds no shadow, material, fake focus ring or custom animation.

The generic library does not force a persistent label/helper/error into every
call. The board composes them publicly, and supplies an `accessibilityLabel`
matching each visible label. The long Chinese value is backed by mutable state
so native caret movement, selection, input methods and horizontal scrolling can
actually be reviewed; it is not a constant imitation of an editable field.

Finesse's fixed helper/error geometry is adapted with hidden layout-only copies
of the two actual message strings in an overlapping stack. This reserves their
maximum height at the current width and text size. Those measuring copies are
hidden from accessibility; the visible helper or error remains accessible. The
error uses an exclamation symbol and full cause/correction text in the primary
text color, avoiding dependence on either red or a low-contrast status token.
The native bezel is unchanged by validation, so its border and focus feedback
cannot jump or compete with a drawn error ring.

Finesse's literal CSS outline, cursor, opacity and active-transform rules yield
to platform focus, pointer, disabled and text-selection behavior. Its web rule
against wrapped labels yields to Dynamic Type and localization. Contrast ratios
and assistive-technology behavior require actual rendered/runtime inspection;
native styling alone does not establish those passes.

## Eight-state ownership

| State | Owner and behavior | Review path |
| --- | --- | --- |
| Default | Library renders a real native field with explicit theme and a string binding; caller supplies its value and label. | Empty and filled specimens. |
| Hover | Native field/pointer system owns pointer feedback. No forced hover or color animation. | Move the pointer over the live macOS field. |
| Focus-visible | Native field owns caret, selection and keyboard focus ring. Caller owns `.focused`, focus sequence and dismissal. | Click/tab into fields; inspect the actual native ring and edit. |
| Active | Library target taps request native editing focus through private `FocusState`; a simultaneous gesture preserves native insertion and selection. Caller `.focused` remains supported. No pressed transform applies. | Click the target outside the bezel, type, select and move the caret. |
| Disabled | Caller supplies `.disabled`; native semantics block editing. Library uses explicit secondary text with native unavailable styling. | Disabled specimen and native-host assertion. |
| Loading | No inherent loading state for a synchronous text binding. Caller owns any remote validation/task lifetime and adjacent progress, and decides whether editing stays available. | Not fabricated by this local title example. |
| Error | Caller validates on submission and renders the cause plus correction as words and a symbol. Library retains the native focused field. | Submit an empty/whitespace-only Title, then correct and resubmit. |
| Success | Caller renders the submitted value beside the field; there is no success animation or temporary toast. | Type `Draft`, press Return, and observe exactly `Submitted: Draft`. |

## Live board contract

Use `FIXTURE_PAGE=TextField`. The first editable controls appear in the first
section. All data is synthetic and remains local to the board.

| Control ID | Persistent label | Initial value |
| --- | --- | --- |
| `review-field-empty` | Name | Empty |
| `review-field-filled` | Display Name | Studio Notes |
| `review-field-disabled` | Unavailable Name | Read Only, disabled |
| `review-field-long` | 文稿名称（保留完整标题，便于稍后识别和查找） | Long Chinese title |
| `review-field-context` | Title | Empty |

Visible labels have IDs `review-field-empty-label`, `review-field-filled-label`,
`review-field-disabled-label`, `review-field-long-label` and
`review-field-context-label`. Other IDs are `review-field-helper`,
`review-field-long-helper`, `review-field-context-helper`,
`review-field-context-error` and `review-field-result`.

The context initially shows `Not submitted` and the helper “Enter a title, then
press Return to submit.” Submitting an empty or whitespace-only value retains
focus, keeps `Not submitted`, and shows “Title is empty. Enter a title, then press
Return.” The caller keeps that error until a successful resubmission. Submitting
`Draft` produces exactly `Submitted: Draft` and restores the helper in the same
reserved area. It accepts the original nonempty string without silently trimming
or rewriting the user's input. No timer or task survives the view lifetime.

## Verification and remaining evidence

`NativeTextFieldDesignTests` uses real SwiftUI native hosts to check that explicit
light/dark themes reach the editor inside an oppositely themed host, the native
bezel/focus capability remains, disabled reaches the native control, and native
bezel sizing does not also consume metrics padding. Four additional macOS-only
interaction tests send native-window mouse/key events to verify direct library
target activation outside the bezel, caller `.focused` set/clear/observation,
disabled target/input/submission blocking, and native double-click word selection
followed by typing and a single Return submission. The selection test observes
the native editor's selected range and the caller string binding. These are real
host interactions, not visual acceptance or proof of full keyboard navigation.

The author runs SwiftPM build/tests and a host typecheck of the fixture sources.
The lead owns fixture Xcode integration, simulator use, central UI interaction
tests and all real captures. Full `scripts/verify` includes simulator tests and
remains a lead integration gate; it is not claimed by this author handoff.

The independent reviewer must inspect before/after, iPhone and macOS light/dark,
large-type growing labels and long Chinese input, plus real focus/edit/Return
behavior. iOS hit testing across the reserved target, focus-ring visibility,
helper/error layout stability, measured contrast, VoiceOver/Full Keyboard Access,
Increase Contrast, input-method composition and minimum-OS runtime remain explicit
integration/review checks. No screenshot is committed and no compiler/test pass
is presented as visual acceptance.
