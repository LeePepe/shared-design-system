---
# Root layer map (repo-kit format). Every tracked path resolves to exactly one
# layer (leaf `owns`) or one `support` exclusion; `scripts/context/audit` checks it.
layer: _root
support:
  - patterns: ["*.md", ".gitignore", "docs/**", ".github/**", ".githooks/**", "scripts/verify", "scripts/ci/**"]
    reason: documentation and CI wiring; checked by the contract audit and workflow-lint, not a layer gate
red_lines:
  - Dependencies point only in the direction listed in the table below.
  - Color values come only from shared-design-tokens at an exact version; no local token tables.
---

# shared-design-system tech context

| Layer | Responsibility | tech-context | depends_on |
|---|---|---|---|
| NativeDesignKit | SwiftUI design-system library (iOS, macOS): explicit-theme bridges over DesignTokens, tests, shipped `ai/` contract | `docs/architecture/native-design-kit/tech-context.md` | (none) |

External dependency: `DesignTokens` from `LeePepe/shared-design-tokens`, pinned
by exact version in `Package.swift` and declared in `AGENTS.md` → Dependencies.
It is described here in prose, not in `depends_on`, which only names local layers.
