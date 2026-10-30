---
layer: Strata
owns:
  - Package.swift
  - Package.resolved
  - Sources/**
  - Tests/**
  - ai/**
depends_on: [DesignTokens]
gate:
  docs: python3 scripts/ci/check-ai.py
  docs_test: python3 scripts/ci/test-ai.py
  swift_package_test: python3 scripts/ci/test-swift-package.py --integration
  build: scripts/ci/swift-package.sh build
  test: scripts/ci/swift-package.sh test
  ios: scripts/ci/swift-package.sh ios
  watch_boundary: python3 Tests/Fixtures/PlatformBoundary/verify.py
red_lines:
  - SwiftUI only; UIKit and AppKit appear only in tests for color extraction.
  - Every color comes from DesignTokens; no local token table, fallback color or default theme.
  - Theme is explicit on every call; no environment detection or caching.
  - Token errors propagate unchanged.
  - DesignTokens is the local root-package target; consumers pin the containing package at an exact revision or version.
---

# Strata

SwiftPM product and module `Strata`, declared for iOS 15 and macOS 12.
It depends on the local `DesignTokens` target. The root package also declares
watchOS 8 for the data-only product; a stable compile guard rejects
Strata on watchOS before component use.

- **Sources:** `Sources/Strata/`. The public API is described in `ai/USAGE.md`.
- **Tests:** `Tests/StrataTests/`. They extract native sRGB through
  AppKit on macOS and UIKit on iOS.
- **Gates:** `build` and `test` run on the macOS host. `swift_package_test`
  proves deterministic complete-scheme selection and executes the two-product
  fixture; `ios` builds and tests the real package on the newest available
  iPhone simulator. All four run in CI through `scripts/verify --all`.
- **Contract:** `ai/` travels with each release tag; update it in the same PR
  as any public API change.

## TK2 dense-header layout contract

`StrataSectionHeader` and `StrataStickySectionHeader` keep a strict `44pt`
maximum total height, with at most `4pt` vertical outer padding. A caller
supplied accessory may retain a `44×44` hit target; visual chrome remains
compact inside the header envelope and must not add outer vertical height.
