# Changelog

## Unreleased

- Explicit `NativeDesignTheme` and native solid/Glass surface policy for the
  [Strata rebuild](docs/strata-component-rebuild.md), preserving exact
  DesignTokens 0.1.1 and the released color resolver.
- Ten independently delivered SwiftUI components: Button, Card, TextField,
  Switch, Checkbox, RadioGroup, Slider, ProgressBar, Avatar and Chip. See their
  [consumer contracts](ai/COMPONENTS.md) for APIs and native platform adaptation.
- Component-owned pure SwiftUI fixtures, XCTest UI interaction checks and actual
  simulator screenshot evidence. Components remain unreleased; no new package
  version, tag or product adoption is declared.

## 0.3.0 — consolidated Native release unit

- Publish stable `DesignTokens` and `NativeDesignKit` products from one package;
  NativeDesignKit uses the local data target with unchanged APIs and behavior.
- Preserve iOS 15/macOS 12 floors, add the DesignTokens-only watchOS 8 boundary,
  and reject NativeDesignKit watchOS selection with a stable diagnostic.
- Move new DesignTokens consumers to exact `shared-design-system` revisions or
  version 0.3.0 while preserving immutable historical provider routes and
  private npm identity.

This source boundary defines the 0.3.0 release contract. It does not claim that
the corresponding Git tag or GitHub release already exists.

## 0.1.0 — first release (Git tag v0.1.0)

- SwiftUI `NativeTokenColor.resolve(_:theme:)` bridge over exact DesignTokens
  0.1.1, with explicit themes, encoded sRGB conversion and unchanged errors.
- Versioned AI-contract entry, integration/migration guidance, machine registry
  and an ordinary external SwiftPM consumer fixture.

NativeDesignKit is MIT licensed, and the initial bridge (#1) is retained.
Git tag `v0.1.0` marks the merge commit of the release pull request.
Exact-tag external consumer validation runs against `v0.1.0`; its results are
recorded in the GitHub release notes, not claimed here. UI demos/style acceptance and unmeasured 6DQ dimensions remain
separate from build/test success.
