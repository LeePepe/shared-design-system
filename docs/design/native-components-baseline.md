# Native component review slice

Scope: Button, Toggle, TextField only; no merge, release or consumer adoption.
This branch is a temporary review slice based on Controls PR #13 at a7ca241.
Existing Controls/Foundations owners retain their branches and prerequisite lifecycle.

## Visual baseline

- Use native SwiftUI control styles, system font roles and native interaction feedback.
  Provider body/headline/caption roles map onto Dynamic Type; the macOS review body uses typography.footnote (13 pt) and iOS uses typography.body (17 pt), matching the platform defaults. No display hero.
- Same group, same metrics and control size. iOS target comes from dimension.hit.minimum
  (44); macOS uses dimension.control.compact (28). Values are provider fixture inputs,
  not new library defaults. Native control bezel/padding remains system-owned.
- Use spacing.sm/lg/xl for label, section and canvas spacing. Flat canvas and raised
  groups only; no content shadows, glow, custom motion or decorative glass shell.
- Colors resolve from exact released DesignTokens 0.1.1. Unreleased style provider
  18c979c62e28c005eb3b988fcaacd343e5359d66 is clearly fixture-only, SHA256
  772a99933fb7f2cee3fc19e2c72f2e7357464e6c3d9960d5b676a27f5f240eeb.
- Glass is a native floating control over recognizable neutral content; older SDK/OS
  and Reduce Transparency use labeled bordered fallbacks. Headless macOS bitmaps
  cannot establish compositor Glass. No screenshot of fallback is labeled Glass.
- Native press, hover, focus and switch motion stay system-owned. No custom success
  animations. Business validation, async work, recovery and success belong to callers.

## Sources and native adaptation

Apple HIG Buttons, Toggles, Text fields, Accessibility, Color, Materials and Motion,
plus SwiftUI Applying Liquid Glass to custom views were read on 2026-10-16.
Official sources: https://developer.apple.com/design/human-interface-guidelines/buttons,
https://developer.apple.com/design/human-interface-guidelines/toggles,
https://developer.apple.com/design/human-interface-guidelines/text-fields,
https://developer.apple.com/design/human-interface-guidelines/accessibility,
https://developer.apple.com/design/human-interface-guidelines/color,
https://developer.apple.com/design/human-interface-guidelines/materials,
https://developer.apple.com/design/human-interface-guidelines/motion,
https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views.

Finesse v0.20.0 at 5050b6c71e27b829d1b3087d2be889d29c60db00:
https://github.com/mouse-lin/finesse-skill/tree/5050b6c71e27b829d1b3087d2be889d29c60db00.
Read skills/finesse-ui/SKILL.md and component-scope, anti-cheap, audit, preflight.
Use the component state audit, fixed state geometry, inherited tokens and visible
helper/error explanations. Web pseudo-classes become native pointer/keyboard/press
behavior. Native disabled semantics replace cursor requirements; no HTML mockup,
page skeleton, grain, hero, palette rotation or .finesse/log.json entry is applicable.
Native accessibility text growth takes precedence over the web one-line-label rule.
Apple control semantics and repository token ownership take precedence over Finesse
literal color/outline instructions. Reviewer opens actual SwiftUI screenshots.

## Responsibility

Lead owns integration, common fixture resources/routes, tests and consumer contract.
Each author works in a separate branch/worktree on its component and board. An
independent reviewer checks source and actual screenshots; author self-review is
not acceptance. Button is reviewed before Toggle/TextField parallel implementation.

Engineering checks and visual observations are reported separately, with exact SHAs,
forced versus interactive states, renderer limitations and untested OS/settings.
