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

Follow `LeePepe/shared-ci@6e354f476bc53d68f0f09fc231d5cd938466af9c/ai/agent-protocol.md`
(https://github.com/LeePepe/shared-ci/blob/6e354f476bc53d68f0f09fc231d5cd938466af9c/ai/agent-protocol.md).
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
- `codex-review-gate`

`codex-review-gate` becomes ruleset-required after positive/negative probe
acceptance, as a separate Owner ruleset step.

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

## Dependencies

- `shared-ci` `6e354f476bc53d68f0f09fc231d5cd938466af9c` — https://github.com/LeePepe/shared-ci/blob/6e354f476bc53d68f0f09fc231d5cd938466af9c/ai/
- `shared-design-tokens` `0.1.1` — `LeePepe/shared-design-tokens@0.1.1/ai/`
  (tag `v0.1.1`: https://github.com/LeePepe/shared-design-tokens/tree/v0.1.1/ai; SwiftPM `exact: "0.1.1"`, product `DesignTokens`)

## Delivery

- One task → one branch + worktree → one PR using `.github/pull_request_template.md`.
- Done = required checks green on the PR head SHA; a new push invalidates old evidence.
- CODEOWNERS paths (`.github/**`, `.githooks/**`, AGENTS.md, tech-context,
  `scripts/verify`, `scripts/ci/`, manifests and lockfiles, `ai/`) need Owner
  approval; until enforced, add the `owner-review` label.
- Public API changes update `ai/` in the same PR.
