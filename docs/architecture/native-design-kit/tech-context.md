---
layer: NativeDesignKit
owns:
  - Package.swift
  - Package.resolved
  - Sources/**
  - Tests/**
  - ai/**
depends_on: []
gate:
  build: scripts/ci/swift-package.sh build
  test: scripts/ci/swift-package.sh test
  ios: scripts/ci/swift-package.sh ios
red_lines:
  - SwiftUI only; UIKit and AppKit appear only in tests for color extraction.
  - Every color comes from DesignTokens; no local token table, fallback color or default theme.
  - Theme is explicit on every call; no environment detection or caching.
  - Token errors propagate unchanged.
  - The DesignTokens dependency is an exact version, never a branch or range.
---

# NativeDesignKit

SwiftPM package `NativeDesignKit`, one library product and module of the same
name, declared platforms iOS 15 and macOS 12. It depends on the
`DesignTokens` product of `shared-design-tokens`.

- **Sources:** `Sources/NativeDesignKit/`. The public API is described in `ai/USAGE.md`.
- **Tests:** `Tests/NativeDesignKitTests/`. They extract native sRGB through
  AppKit on macOS and UIKit on iOS.
- **Gates:** `build` and `test` run on the macOS host. `ios` builds and tests
  the package scheme on the newest available iPhone simulator. All three run
  in CI through `scripts/verify --all`.
- **Contract:** `ai/` travels with each release tag; update it in the same PR
  as any public API change.
