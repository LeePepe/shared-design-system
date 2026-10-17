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
  consumer: npm --prefix Packages/DesignTokens run test:swift-consumer
red_lines:
  - The DesignTokens target imports Foundation only; UIKit, AppKit and SwiftUI are forbidden.
  - GeneratedColors.swift and GeneratedStyles.swift belong to Tokens and are never hand-edited.
  - S100 does not activate this target in the root package or change NativeDesignKit resolution.
---

# DesignTokens

UI-free Swift data product imported under `Packages/DesignTokens`. Its generated
Swift data depends on Tokens; NativeDesignKit continues to resolve the external
v0.2.0 provider until S200.
