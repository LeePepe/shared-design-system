# Consolidate design-token authority into shared-design-system

Status: proposed; requires exact-revision architecture/spec review and Team Lead acceptance

The Owner has chosen `LeePepe/shared-design-system` as the sole future development
authority for design-token data and Apple components. We will import
`LeePepe/shared-design-tokens@87bef8fbab5bf67a748815d7ed04d7ae199f760a`
under `Packages/DesignTokens/`, retain one root Swift package that publishes the
existing `DesignTokens` and `NativeDesignKit` products/modules, and enforce the
acyclic layer direction `Tokens -> DesignTokens -> NativeDesignKit`. This keeps
platform-neutral data and generation separate from the UI-free Swift facade and
from SwiftUI components while removing the target package's remote dependency on
the old repository.

## Considered options

- Keep two writable repositories or mirror generated outputs between them:
  rejected because it leaves two authorities and permits drift.
- Copy token values into NativeDesignKit or add runtime fallbacks: rejected
  because it collapses the data/component seam and weakens fail-closed errors.
- Import both repositories at their current roots: rejected because their
  manifests, `ai/` contracts, repository rules, and `v0.1.0` tags collide.
- Keep the target review caller's default 200,000-byte complete-diff budget, or
  raise it inside S100: rejected because the exact relocated mechanical import
  is already 619,833 bytes and `pull_request_target` loads the trusted caller
  from target `main`, so S100 cannot bootstrap its own review capacity.
- Split source moves or omit generated data to fit review capacity: rejected
  because it would evade complete review and break one observable import goal.
- Nest the provider release unit and publish both Swift products from the root:
  selected because the npm artifact can still be packed from its own root while
  SwiftPM gets one package graph with a local `DesignTokens` target.

## Consequences

- `tokens/colors.json` and `tokens/styles.json` beneath
  `Packages/DesignTokens/` become the only editable visual-data authorities;
  generated JS/TS/CSS/JSON and Swift outputs remain reproducible and never
  hand-edited.
- `DesignTokens` remains Foundation-only and UI-free. `NativeDesignKit` remains
  SwiftUI-only and depends on the local `DesignTokens` target. Token or style
  code never imports component code.
- S100 must merge before a separate provider-quiescence PR starts. That PR is
  based on the exact provider revision and changes only `AGENTS.md`,
  `docs/constitution.md`, and `README.md`: it removes permission for ordinary
  provider development, identifies the target as the future development
  authority, and states that future adopters must use a version-matched target
  migration contract after activation without claiming a target SHA or public
  route before S200/T260. It preserves old exact pins, tags, releases, public
  APIs/data, and URL resolution. It requires ordinary exact-head independent review,
  CODEOWNERS/delegated Owner approval, required CI, PR Manager merge, and
  merged-main/blob readback before S200 may start. It does not change provider
  source, generated data, manifests, gates, provider shared-ci pin
  `42d1704a5690ab5890657feaadb8929384632766`,
  rulesets, settings, credentials, releases, tags, archive state, or repository
  identity.
- P175 records the exact three pre-change provider blobs. If Root abandons
  activation after P175 but before S200, rollback is a separate ordinary
  exact-head provider PR that restores only those three blobs, with the same
  Owner approval, CI, merge, and readback. That restore must merge before the
  inert S100 import is removed, so rollback never leaves a falsely writable
  target or silently reopens provider development.
- The provider becomes quiescent when that prerequisite merges; development
  authority becomes active in the target at the reviewed S200 activation
  revision. S200 atomically removes the old executable dependency and the stale
  root `AGENTS.md`/README authority declarations. A later Owner-authorized
  archive only enforces the already-made authority decision in GitHub settings;
  it does not control historical fetch availability or postpone the transfer.
- The nested provider release unit retains its npm name, exports, licenses,
  versioned `ai/` contract, and independent Node/Swift-data gates. The root
  contract remains the NativeDesignKit entry and gains a deterministic pointer
  to the nested DesignTokens contract.
- After this four-document planning revision passes exact-head review, required
  checks, delegated Owner approval, and its own merge/readback with byte-identical
  reviewed blobs, one separately reviewed governance PR changes only the target
  caller's `max-diff-bytes` input to `1000000` and must actually merge before
  S100. The
  value covers the measured 619,833-byte relocated mechanical baseline with
  380,167 bytes of bounded adaptation headroom. It changes capacity, not review
  semantics: the complete diff remains untruncated; critical/high findings and
  tool/setup/parse failures remain blocking; the exact shared-ci pin, trusted
  rules, timeout semantics, Owner-decision handling, and `codex-review-gate`
  remain unchanged. A frozen S100 diff above the ceiling blocks and replans.
- A Git repository has one SwiftPM version namespace. Future consolidated Swift
  releases therefore use one shared tag for both products. Existing tags are
  never moved or recreated: NativeDesignKit `v0.1.0` remains in this repository;
  DesignTokens `v0.1.0`, `v0.1.1`, and `v0.2.0` remain in the old repository.
  `v0.3.0` is the recommended first consolidated release candidate, not release
  authorization.
- Existing NativeDesignKit and DesignTokens source imports remain stable, but a
  consumer moving DesignTokens from the old URL must change its SwiftPM package
  URL/identity to `shared-design-system`. Revision-mode external consumers prove
  this route before any release decision.
- The old repository stays fetchable for historical exact versions. Its
  three-file quiescence notice is an ordinary reviewed implementation
  prerequisite, not an archive/settings action. Archive remains a later,
  explicit Owner settings decision after the consolidated revision, consumer
  migration evidence, release decision, and rollback packet pass. The provider
  is never deleted, renamed, tag-rewritten, or treated as a live mirror.

The stable acceptance, compatibility, retirement, and rollback boundaries are
specified in `docs/design-tokens-consolidation-spec.md`.
