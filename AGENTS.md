# AGENTS.md — shared-design-system

Shared Apple/SPM design system with the UI-free `DesignTokens` product and the
SwiftUI `NativeDesignKit` product for iOS and macOS. Every agent that edits this
repository follows the protocol below. Tool-specific files (CLAUDE.md etc.) only
point here.

## Read first

1. `docs/architecture/tech-context.md` — layer table: layer → paths → depends_on
2. The leaf `tech-context.md` of every layer you touch (`NativeDesignKit`)
3. Consumer-facing contract: `ai/` (ships with every release)

## Protocol

Follow `LeePepe/shared-ci@fd8a187ef4872aa1aa69c4e9afec9782183cc02d/ai/agent-protocol.md`
(https://github.com/LeePepe/shared-ci/blob/fd8a187ef4872aa1aa69c4e9afec9782183cc02d/ai/agent-protocol.md).
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
- Color values come only from the local `DesignTokens` target. No duplicate
  token tables, fallback colors or default theme; theme is explicit on every call.
- Token errors propagate unchanged.
- Releases are immutable semver tags with release notes and external-consumer
  evidence (shared-ci W5).
- Non-public project configuration never enters git: keep it in a gitignored
  local file with a committed `.example` template.
- No personal account names, credential-profile paths or local home paths in the repo.

## Dependencies

- `shared-ci` `fd8a187ef4872aa1aa69c4e9afec9782183cc02d` — https://github.com/LeePepe/shared-ci/blob/fd8a187ef4872aa1aa69c4e9afec9782183cc02d/ai/
- `NativeDesignKit` depends on the repository-local `DesignTokens` target.
- The root package publishes both stable products from one exact
  `shared-design-system` revision. The nested npm artifact remains
  `@leepepe/design-tokens` 0.2.0 and is not registry-published.
- Historical provider tags remain immutable and readable; they are compatibility
  history, not the active development or root-package dependency route.

S200/PR #37 uses its Owner-approved exception to atomically replace the external
exact dependency and obsolete lock resolution with the repository-local
`DesignTokens` target while updating the root manifest and authoritative
architecture/contracts to the same truth. This scoped transition is not a
general dependency-policy exception; every other dependency change remains
subject to the existing exact-pin rule.

## Delivery

- One task → one branch + worktree → one PR using `.github/pull_request_template.md`.
- Done = required checks green on the PR head SHA; a new push invalidates old evidence.
- Changes to policies, gates, CI, hooks, manifests, lockfiles and `ai/`
  must state their rationale and verification evidence in the PR.
- Public API changes update `ai/` in the same PR.
