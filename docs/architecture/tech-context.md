---
# Root layer map (repo-kit format). Every tracked path resolves to exactly one
# layer (leaf `owns`) or one `support` exclusion; `scripts/context/audit` checks it.
layer: _root
support:
  - patterns: ["*.md", "LICENSE", ".gitignore", "docs/**", ".github/**", ".githooks/**", "scripts/verify", "scripts/ci/**"]
    reason: documentation and CI wiring; checked by the contract audit and workflow-lint, not a layer gate
  - patterns: ["Packages/DesignTokens/README.md", "Packages/DesignTokens/CHANGELOG.md", "Packages/DesignTokens/LICENSE", "Packages/DesignTokens/THIRD_PARTY_NOTICES.md", "Packages/DesignTokens/docs/**", "Packages/DesignTokens/specs/**", "Packages/DesignTokens/scripts/verify", "Packages/DesignTokens/scripts/ci/**"]
    reason: imported provider documentation, provenance, specifications and nested repository verification support
red_lines:
  - Dependencies point only in the direction listed in the table below.
  - Color values come only from the nested DesignTokens authorities; no duplicate token tables.
---

# shared-design-system tech context

| Layer | Responsibility | tech-context | depends_on |
|---|---|---|---|
| Tokens | Nested color/style sources, generators, JS/TS/CSS/JSON artifacts, AI contract and Node tests | `docs/architecture/tokens/tech-context.md` | (none) |
| DesignTokens | Nested UI-free Swift data target, XCTest and disposable local-path consumer | `docs/architecture/design-tokens/tech-context.md` | Tokens |
| NativeDesignKit | SwiftUI design-system library (iOS, macOS): explicit-theme bridges over DesignTokens, tests, shipped `ai/` contract | `docs/architecture/native-design-kit/tech-context.md` | DesignTokens |

The root package publishes both products. `NativeDesignKit` uses the local
`DesignTokens` target; consumers pin one exact `shared-design-system` revision.
The old provider repository remains immutable compatibility history only.
