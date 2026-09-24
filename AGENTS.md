# AGENTS.md — shared-design-system

Shared SwiftUI design-system library (`NativeDesignKit`) for iOS and macOS,
built on the color data from `shared-design-tokens`. Every agent that edits
this repository follows the protocol below. Tool-specific files (CLAUDE.md
etc.) only point here.

## Read first

1. `docs/architecture/tech-context.md` — layer table: layer → paths → depends_on
2. The leaf `tech-context.md` of every layer you touch (`NativeDesignKit`)
3. Consumer-facing contract: `ai/` (ships with every release)

## Protocol

Follow `LeePepe/shared-ci@761fe6b0b3ca5e2c57d244182d495ab8041851fa/ai/agent-protocol.md`
(https://github.com/LeePepe/shared-ci/blob/761fe6b0b3ca5e2c57d244182d495ab8041851fa/ai/agent-protocol.md).
It must be the same SHA as the `uses:` pins in `.github/workflows/`.

## Verify

```sh
git config core.hooksPath .githooks   # once per clone
scripts/verify                        # contract checks + changed layers vs origin/main (what pre-push runs)
scripts/verify --all                  # contract checks + every layer (what CI runs)
scripts/verify --layer NativeDesignKit
```

Needs Xcode with Swift 6 and an iOS simulator runtime. Never `--no-verify`,
never weaken or skip tests, never edit policy/gates to pass.

## Required checks

Merging to `main` requires (target ruleset; applying it is an Owner step):

- `quality / aggregate`

`quality / aggregate` fails unless every lane of the shared-ci quality gate
passed on the PR head: `scripts/verify --all` on macOS (host build and test,
iOS simulator build and test), contract audit, workflow-lint and the PR-body check.

## Red lines

- SwiftUI library only. UIKit/AppKit only in tests. No business data, screens
  or product integration; consumer adoption happens in each product repository.
- Color values come only from `DesignTokens` at an exact version. No local
  token tables, fallback colors or default theme; theme is explicit on every call.
- Token errors propagate unchanged.
- Releases are immutable semver tags with release notes and external-consumer
  evidence (shared-ci W5).
- Non-public project configuration never enters git: keep it in a gitignored
  local file with a committed `.example` template.
- No personal account names, credential-profile paths or local home paths in the repo.

Approved exceptions:

- No `codex-review-target` review caller: this repository has no self-hosted
  review runner (S7 rollout decision). The required list above omits
  `codex-review-target / codex-review` until one exists.

## Dependencies

- `shared-ci` `761fe6b0b3ca5e2c57d244182d495ab8041851fa` — https://github.com/LeePepe/shared-ci/blob/761fe6b0b3ca5e2c57d244182d495ab8041851fa/ai/

## Delivery

- One task → one branch + worktree → one PR using `.github/pull_request_template.md`.
- Done = required checks green on the PR head SHA; a new push invalidates old evidence.
- CODEOWNERS paths (`.github/**`, `.githooks/**`, AGENTS.md, tech-context,
  `scripts/verify`, `scripts/ci/`, manifests and lockfiles, `ai/`) need Owner
  approval; until enforced, add the `owner-review` label.
- Public API changes update `ai/` in the same PR.
