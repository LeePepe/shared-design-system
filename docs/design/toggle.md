# Toggle native design review

This slice refines `NativeToggle` and its focused live review board. It inherits
the accepted Button baseline at `f50ed71`, keeps the existing constructor, and
leaves Checkbox, RadioGroup and Picker unchanged.

## Sources and decisions

Read on 2026-10-16:

- [Apple HIG Toggles](https://developer.apple.com/design/human-interface-guidelines/toggles):
  a toggle controls two opposing values; clearly identify the affected setting
  and distinguish states beyond color. On iOS, use switches in list rows. On
  macOS, use switches in the window body for settings deserving emphasis; mini
  switches can suit subordinate settings in grouped forms.
- [Apple HIG Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility):
  support larger text, readable contrast, descriptive accessibility labels,
  keyboard access and comfortably sized controls. Its platform defaults are
  44 points on iOS and 28 points on macOS, distinct from its smaller minimums.
- [Apple HIG Motion](https://developer.apple.com/design/human-interface-guidelines/motion):
  native components already provide familiar feedback; avoid unnecessary motion
  on frequently used controls and communicate important changes without relying
  on animation.
- [SwiftUI Toggle](https://developer.apple.com/documentation/swiftui/toggle)
  and [SwitchToggleStyle](https://developer.apple.com/documentation/swiftui/switchtogglestyle):
  read the official DocC API text as well as the HIG.
- [Finesse v0.20.0, commit 5050b6c71e27b829d1b3087d2be889d29c60db00](https://github.com/mouse-lin/finesse-skill/tree/5050b6c71e27b829d1b3087d2be889d29c60db00):
  read `skills/finesse-ui/SKILL.md`, `component-scope.md`, `anti-cheap.md`,
  `audit.md` and `preflight.md`. Apply component scope, inherited tokens,
  explicit state ownership, stable geometry and an actual native preview.

**SwiftUI API facts:** `Toggle(isOn:label:)` binds a Boolean and accepts generic
label content. `.toggleStyle(.switch)` selects the platform's native switch
style, whose documented arrangement is a leading label and trailing switch.
Native styles own interaction and accessibility state; `.disabled(true)` disables
the real control. A larger outer frame alone does not establish a larger active
label or switch. The wrapper supplies no replacement gesture, synthetic
accessibility value or custom keyboard handler.

**Team choices:** use the same explicit theme and platform review metrics as
Button, with a regular native switch on both platforms. The label receives
primary text when enabled and secondary text when disabled; the switch receives
the supplied information tint. These are repository token choices, not Apple
color prescriptions. Native switch styling owns track, thumb, focus and disabled
appearance; `metrics.disabledOpacity` is deliberately not applied over it a
second time. Native colors that form part of the OS control remain system-owned.
No new token, dependency, default theme, Glass shell, shadow or custom motion is
introduced. The color dependency remains exact DesignTokens 0.1.1.

The minimum target is inside the native label, with unlimited vertical text
growth. Native switch dimensions remain system-owned. This establishes label
layout bounds, not a promise that surrounding group padding is interactive.
The live board expands each label across its preference row; native style
semantics still decide label/switch activation. Independent interaction checks
must distinguish the label, switch and inactive group margins. The HIG's iOS
list-row guidance is represented by grouped preference rows in the inherited
`ReviewSection` scaffold, rather than a nested SwiftUI `List` in its ScrollView.
Consumer placement remains the caller's responsibility.

Finesse's HTML preview becomes the live SwiftUI board. Web hover/focus/active
classes and cursor rules become native pointer, keyboard, press and disabled
semantics. Its one-line-label rule yields to Chinese localization and Dynamic
Type. Native disabled styling replaces its prescribed extra opacity. Page
skeletons, hero engines, palette rotation, decorative imagery and build-log
entries do not apply to this component.

## Eight-state ownership

| Finesse state | Owner and behavior | Review path |
| --- | --- | --- |
| Default | Wrapper selects the native switch, explicit theme colors and label minimum; caller owns the binding and label. | On and off specimens, each with a persistent title and helper. |
| Hover | Native style owns pointer feedback where the platform provides it. | Move a real pointer over the live macOS switch and label; no forced visual state. |
| Focus-visible | Native control owns keyboard focus and focus indication; caller and OS own keyboard navigation policy. | Navigate with keyboard/Full Keyboard Access; no custom focus overlay. |
| Active | Native control owns press feedback and Boolean activation. | Press and release the switch and its label; check the native value and context result. |
| Disabled | Caller sets `.disabled(true)`; native control blocks activation and owns switch appearance. Wrapper uses secondary label text without a second opacity pass. | Disabled-on and disabled-off remain unchanged after attempted activation. |
| Loading | No component loading state applies to an immediate Boolean switch. Caller owns any asynchronous operation, pending explanation and temporary disabling. | No fake spinner or loading animation in this board. |
| Error | Caller owns operation failure, cause and recovery guidance. A generic switch has no business validation. | A consumer with actual failure must explain the cause and remedy beside its setting. |
| Success | The native Boolean value and caller's visible result convey the outcome. | Include Details immediately changes the adjacent result; no celebration or success animation. |

## Live board contract

Use `FIXTURE_PAGE=Toggle`. All data is synthetic and confined to the board's
lifetime. States start on/off as labelled by helper text; the two enabled
specimens and long label use mutable bindings. Disabled bindings stay pinned.
Titles and helper text remain present when values change.

| Identifier | Initial state and purpose |
| --- | --- |
| `review-toggle-on` | Keep Changes, on and enabled. |
| `review-toggle-off` | Include Notes, off and enabled. |
| `review-toggle-disabled-on` | Restore Options, on and disabled. |
| `review-toggle-disabled-off` | Share Options, off and disabled. |
| `review-toggle-context` | Include Details, initially false; immediate observable preference. |
| `review-toggle-long` | Chinese title and helper, initially false; vertical growth at accessibility3. |
| `review-toggle-result` | Exactly `Details excluded` when false and `Details included` when true. |

Each switch has its useful title as its accessible label and its helper as the
hint, avoiding a second title or helper in the accessible label. The on/off
value and disabled semantics remain native. The helper is also a native tooltip
on pointer platforms. `r.reviewBody`, `r.caption`, `r.reviewMetrics` and the
shared raised `ReviewSection` supply typography, spacing and surfaces. No
provider preparation or shared scaffold edit is needed to typecheck this board.

## Verification and remaining evidence

`NativeToggleDesignTests` compares native-host disabled rendering with explicit
metrics opacity inputs of zero and one, for on/off in both themes. This guards
against reintroducing a second opacity pass. It also measures long Chinese text
at 180/480-point widths with `.large` and `.accessibility3`, checking vertical
growth and stable geometry across enabled/disabled and on/off states. These
measurements do not establish a complete hit target, VoiceOver behavior, contrast
acceptance or interactive appearance. On macOS, the Dynamic Type environment is
supplied; it does not establish iOS text scaling from a macOS run.

The author runs `swift build`, `swift test`, the AI contract checks and a direct
Swift typecheck of the existing showcase sources against the built modules.
The Lead owns Xcode integration, central UI tests and actual iPhone/macOS
captures; this author does not launch a competing simulator or regenerate the
project. The final PR must retain the repository's complete required checks and
any consumer-contract updates owned by the Lead.

Before visual acceptance, inspect fresh light/dark and accessibility3 captures
at the integrated SHA, then exercise context state changes, disabled blocking,
label/switch activation, inactive outer margins, pointer and keyboard behavior.
VoiceOver navigation, OS Reduce Motion/Increase Contrast settings, minimum-OS
runtime and measured contrast remain separate evidence. Author tests and source
inspection do not claim independent visual acceptance.
