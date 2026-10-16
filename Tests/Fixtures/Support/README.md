# Native SwiftUI fixture UI verification

Rendering, layout and interaction checks run in standalone SwiftUI fixture
apps driven by XCTest UI automation. Package tests retain pure behavior,
provider/contrast checks and the existing numeric color extraction tests.
UIKit/AppKit hosting is not used. No production app or product data is involved.

Requires Xcode, an available iPhone simulator, Python 3 and `xcodegen` on PATH.
The canonical app configuration is each fixture's `project.yml`; the runner
generates its ignored Xcode project and shared scheme before testing.

From the repository root:

```sh
python3 Tests/Fixtures/Support/run.py ButtonReview \
  --results /tmp/ndk-button-review/Results.xcresult \
  --screenshots /tmp/ndk-button-review/screenshots
```

Use new output paths for each run. `--scheme` defaults to the fixture directory
name. `--derived-data` may name a separate isolated build directory; otherwise
it is created beside the result bundle. All build/evidence outputs must be
outside the repository. Capture stdout/stderr to an external log. This runner
does not add or replace a CI gate: run the repository's full verification too.

The device policy matches `scripts/ci/swift-package.sh`: select the first
available iPhone in the newest iOS runtime and pass its explicit UUID to
`xcodebuild`. `--device <UUID>` selects another available iPhone for a deliberate
additional run. The runner does not create/delete simulators or alter host
accessibility preferences. Serialize simulator runs externally when sharing a
host; it does not acquire a machine-specific lock itself.

Xcode tests run with isolated DerivedData and `.xcresult`, UI parallelism off
and simulator signing disabled. The runner preserves the test command's exit
code; export failures also fail an otherwise successful run. It exports failure
attachments when available, as well as successful evidence.

## Add another component without shared-file edits

1. Create `Tests/Fixtures/<Component>Review/`. Copy ButtonReview's `project.yml`
   and replace project/target/scheme names and generic bundle identifiers.
   Keep `packages.NativeDesignKit.path: ../../..`; it refers to this checkout.
   Keep fixture sources under `App/` and UI automation under `UITests/` so
   SwiftPM's `NativeDesignKitTests` target does not compile either app entry.
2. Supply one SwiftUI `@main App` importing only `SwiftUI` and
   `NativeDesignKit`. Resolve theme/brand explicitly from `NDK_*` launch
   environment values. Show resolution/configuration errors as visible text;
   never supply fallback token colors. Use synthetic caller-owned state.
3. Give important controls stable accessibility identifiers. Use readable
   stacks/ScrollView layouts, and assert each captured element's entire frame
   is within the visible viewport before taking its screenshot. Test actual
   actions, disabled input, state changes and long labels as appropriate.
4. UI tests import only `XCTest`. Use `XCUIApplication`, element queries,
   frames, taps/coordinate taps, `typeText` where needed and
   `XCTAttachment(screenshot: app.screenshot())`. Set attachment `name` to an
   exact lowercase hyphenated name and `lifetime = .keepAlways`.
5. Add that fixture's `screenshots.json` containing every expected attachment
   name, e.g. `card-ocean-light`. The generic runner needs no component registry
   or source edits. Add localizations/resources within the component fixture.
6. Run the package gates and this runner at the final commit. Inspect the
   exported images for clipping/overlap; static screenshots do not establish
   VoiceOver, keyboard/focus, physical-device or minimum-OS acceptance.

`ButtonReview` demonstrates launch configuration, stateful interaction,
localized accessibility typography and the four brand/theme captures. Tests
must not import UIKit/AppKit or use native hosting/window/screenshot helpers.
Numeric color extraction remains confined to its preexisting package tests.

## Attachment export

`xcrun xcresulttool export attachments` writes raw PNGs and a `manifest.json`
beside the results in `<result-name>.attachments/`. The runner matches each
fixture-declared name against `suggestedHumanReadableName`, requires exactly
one matching PNG for each name on success, and copies it to
`<screenshots>/<name>.png`. Missing/duplicate names fail export; no synthetic
image, cropping or renaming based on file order is used. `attachments.json`
records the source test and exported attachment filename. The original result
bundle and raw attachments remain available for independent inspection.

`<result-name>.summary.json` contains the xcresult test summary and
`<result-name>.run.json` records tested SHA, dirty state, device/runtime,
commands' outcomes, summary and attachment mapping. A development run on a
dirty tree is diagnostic only; final evidence must name the frozen clean head.
