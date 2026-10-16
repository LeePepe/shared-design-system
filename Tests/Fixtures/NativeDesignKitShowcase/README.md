# NativeDesignKit showcase

This sample-only SwiftUI catalog renders all C01–C08 controls and representative
foundation layouts/surfaces/motion with synthetic, caller-owned state. It imports
public `NativeDesignKit` / `DesignTokens`, uses a relative local package reference,
and performs no network operation or product integration. Production library
sources remain SwiftUI-only. UIKit/AppKit are not used by the sample sources.

## Prepare and run

Use Xcode, XcodeGen and a reviewed checkout of the style provider. First run the
library's `swift build` and `swift test` from the repository root. Then, here:

```sh
./prepare.sh /path/to/reviewed/shared-design-tokens
./verify macos --output /tmp/ndk-showcase/review-macos
./verify ios --device <dedicated-iPhone-UDID> --output /tmp/ndk-showcase/review-iphone
./verify ios --device <dedicated-iPad-UDID> --output /tmp/ndk-showcase/review-ipad
# Both UI-test platforms (requires an active macOS desktop session):
./verify all --device <dedicated-iPhone-UDID> --output /tmp/ndk-showcase/review-all
# Separately labelled headless native rendering evidence:
./verify macos-render --output /tmp/ndk-showcase/review-mac-render
```

`prepare.sh` copies the provider's actual `dist/styles.resolved.json` into ignored
`StyleProvider/`, records its Git revision and SHA256, and regenerates the checked-in portable
Xcode project/shared schemes from canonical `project.yml`. Regenerate after adding
files and commit the project changes. Relative local-package references remain
portable; generated workspace user state and resolution cache stay ignored. The JSON adapter validates required
fields and reports setup failure instead of applying fallback styles. It maps
provider typography to SwiftUI font categories/weights, leading, tracking and
monospaced digits. These mappings are platform adapters, not a local value table.

The main library's published dependency remains exact Tokens 0.1.1. This sample's
style JSON integration is **local-only** evidence for the separately recorded
provider revision/hash, not consumption of a published style release. No generated
style artifact, screenshot, baseline, DerivedData or xcresult is committed. The
generated project and shared schemes are committed alongside canonical YAML.

`verify` is the fixture build/test entry point. `macos`, `ios` and `all` build
and test the named app/UI-test schemes; errors, missing schemes/destinations and
macOS UI-session failures return nonzero. Result summaries must show all four UI
tests (or the one render test) passing with no skips or expected failures.
`macos-render` builds/tests the separate
hostless render target and does not satisfy macOS UI interaction acceptance. No
mode substitutes rendering for failed UI tests. Output includes the exact Git
revision, dirty status, provider revision/hash, environment, resolved destination,
log, dedicated DerivedData and xcresult; an existing result path fails rather
than overwriting evidence. Use a fresh revision-specific `--output` directory.
Without `--device`, iOS requires one available simulator named
`NDK-Controls-Narrow`. `--device` explicitly selects an available dedicated phone
or tablet. The runner does not create, erase or shut down user simulators.

Use a dedicated iPhone and iPad simulator for narrow/wide iOS coverage. Preserve
existing user devices. UI tests launch real apps, assert action counts, loading
and disabled states, checkbox/selection bindings, text/secure/search editing,
slider adjustment, tag removal, complete animated-number targets, and sequence
replay. macOS additionally captures narrow (480) and wide (1120) windows. App
state remains ephemeral. Date examples are fixed synthetic dates; tests set the
locale and time zone for reproducible text.

Launch environment controls are `FIXTURE_PAGE=Buttons|Entry|Values|Motion`,
`FIXTURE_APPEARANCE=light|dark`, `FIXTURE_WIDTH=narrow|wide` (macOS),
`FIXTURE_ACCESSIBILITY=1`, and `FIXTURE_RTL=1`. Explicit appearance selects both
resolved theme and native control appearance. Accessibility mode supplies real
SwiftUI accessibility3 Dynamic Type, explicitly requests opaque surfaces/native
bordered buttons, and passes reduced motion to sequence replay. This caller policy
mode is distinct from changing OS Reduce Motion/Transparency preferences; the
library also reads those native preferences, whose acceptance needs a separate
OS-setting run. No host accessibility settings are changed by the sample.

## Screenshot evidence and regression comparison

`testScreenshotMatrix` captures actual `XCUIApplication.screenshot()` PNGs as
XCTest `.keepAlways` attachments: every section in light/dark, top/lower scroll
positions, macOS narrow/wide, large-type caller accessibility policy and RTL.
Interaction tests attach resulting state. Inspect the saved PNGs for hierarchy,
missing content, clipping, overlap and readable states. Export them with the
installed Xcode version's command (check `xcrun xcresulttool export attachments
--help`), retaining test identifiers and names alongside each result bundle.
Record native/provider SHAs, JSON hash, Xcode/OS versions, device/scale, appearance,
window dimensions and preference policy in the external evidence manifest.

**Attachments alone are not regression tests.** `compare-snapshots.py` implements
actual pixel comparison against a separately reviewed PNG and exits nonzero on
dimension mismatch or differences above explicit thresholds. It never records or
updates a baseline, resizes images, or silently approves a new OS appearance.
Example after installing Pillow in the caller's environment:

```sh
python3 compare-snapshots.py /reviewed/baseline.png /captured/actual.png \
  --channel-delta 0 --max-changed-fraction 0
```

Optional `--masks reviewed-masks.json` accepts explicit pixel rectangles
`[[left,top,right,bottom]]`. Mask only known nondeterminism such as an indeterminate
spinner/caret; masks and tolerances need the same review as baselines. Freeze
animation endpoints, locale, simulator status bar and time zone before baseline
capture. Compare the same OS build, SDK, device, scale and viewport; native Glass,
font rasterization and native controls intentionally vary across OS versions.
A new platform build requires baseline review. Initial attachments establish
review evidence; no committed golden baseline or CI pixel-regression gate is
claimed. Wire any future required gate separately under Owner policy.

The matrix does not establish minimum-OS runtime, physical device, VoiceOver
navigation, keyboard traversal, performance or released-provider acceptance.

## Native macOS rendering without a desktop session

`ShowcaseRender-macOS` is a hostless XCTest target that compiles the same
`ShowcaseCatalog.swift` and `FixtureStyle.swift` sources, loads the same explicit
provider JSON, and captures `NSHostingView` through AppKit into PNG attachments.
This test-only renderer supplies the key control-active state and explicit Aqua/
Dark Aqua appearance, and explicitly requests bordered/opaque fallbacks because
Glass uses compositor layers that bitmap cache capture cannot represent; it does not establish macOS keyboard/pointer interactions
or active-window Glass composition. It is useful on hosts where XCUIAutomation
cannot obtain a display. Run it using `./verify macos-render`; export attachments from its xcresult. AppKit is confined
to `RenderTests/`. Native controls are rendered by macOS, not drawn mockups.


The library's package rendering tests additionally force the real legacy
TextEditor background route on current macOS/iOS runtimes. They host explicit
dark under light native appearance and explicit light under dark native
appearance, assert editable native views, retained text, native appearance and
text/background contrast, and attach actual PNGs. They do not claim execution on
iOS 15/macOS 12 themselves. The Controls fixture does not finish the original
T401 full component/keyboard matrix; that acceptance remains unverified.

## Focused component design review

`FIXTURE_PAGE=Button|Toggle|TextField` selects the component review boards, separate
from the retained plural catalog. `ComponentReviewUITests` captures matching light,
dark and accessibility3 iPhone boards and performs real native actions, switch
changes and text submission. Button tests tap unavailable targets and repeat a tap
during loading, checking action counts and geometry before completion. The native
render target captures the same focused boards in a 480x1000-point macOS viewport.

For these singular pages, `FIXTURE_ACCESSIBILITY=1` means a forced SwiftUI
accessibility3 text environment only; it does not force reduced transparency or
motion. Glass captions reflect the actual selected native/fallback path. macOS
Dynamic Type environment injection does not itself establish larger desktop text.
Hostless desktop rendering is static evidence; keyboard, hover and live compositor
Glass require a functioning desktop UI session. Raw captures and recordings are
external review evidence, never generated library assets or golden baselines.
