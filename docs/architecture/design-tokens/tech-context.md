---
layer: DesignTokens
owns:
  - Packages/DesignTokens/Sources/DesignTokens/DesignTokens.swift
  - Packages/DesignTokens/Sources/DesignTokens/StyleTokens.swift
  - Packages/DesignTokens/tests/DesignTokensTests/**
  - Packages/DesignTokens/examples/data/swift/**
  - Packages/DesignTokens/Package.swift
depends_on: [Tokens]
gate:
  build: swift build --package-path Packages/DesignTokens
  test: swift test --package-path Packages/DesignTokens
  consumer: npm --prefix Packages/DesignTokens run test:swift-local-consumer
red_lines:
  - The DesignTokens target imports Foundation only; UIKit, AppKit and SwiftUI are forbidden.
  - GeneratedColors.swift and GeneratedStyles.swift belong to Tokens and are never hand-edited.
  - The root target reuses these sources directly; no copied or fallback data is allowed.
---

# DesignTokens

UI-free Swift data product under `Packages/DesignTokens`. Its generated Swift
data depends on Tokens; the root package publishes this target for iOS 15,
macOS 12 and watchOS 8.
