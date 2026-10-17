---
layer: Tokens
owns:
  - Packages/DesignTokens/tokens/**
  - Packages/DesignTokens/dist/**
  - Packages/DesignTokens/ai/**
  - Packages/DesignTokens/scripts/*.mjs
  - Packages/DesignTokens/tests/*.mjs
  - Packages/DesignTokens/tests/consumer/**
  - Packages/DesignTokens/examples/data/*.mjs
  - Packages/DesignTokens/examples/data/*.ts
  - Packages/DesignTokens/examples/data/*.json
  - Packages/DesignTokens/package.json
  - Packages/DesignTokens/package-lock.json
  - Packages/DesignTokens/Sources/DesignTokens/GeneratedColors.swift
  - Packages/DesignTokens/Sources/DesignTokens/GeneratedStyles.swift
depends_on: []
gate:
  test: npm --prefix Packages/DesignTokens test
  generate: npm --prefix Packages/DesignTokens run generate:check
  consumer: npm --prefix Packages/DesignTokens run test:consumer
  pack: npm --prefix Packages/DesignTokens run test:pack
  ai: npm --prefix Packages/DesignTokens run check:ai
  ai-checker: npm --prefix Packages/DesignTokens run test:ai-checker
  contract: npm --prefix Packages/DesignTokens run test:contract
red_lines:
  - Nested tokens/colors.json and tokens/styles.json are the only editable color and style authorities; generated files are never hand-edited.
  - Unknown IDs, missing modes, invalid colors or references and generation drift fail closed.
  - The runtime package has zero dependencies; Ajv and TypeScript stay dev-only.
---

# Tokens

Source, validation, generation, package contract and Node tests for the
imported `@leepepe/design-tokens` v0.2.0 release unit.
