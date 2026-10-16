# Executable external consumer

The fixture at [examples/consumer](examples/consumer/Package.swift) is a separate
Swift package. [SamplePalette.swift](examples/consumer/Sources/SamplePalette/SamplePalette.swift)
uses only public products. Its [tests](examples/consumer/Tests/SamplePaletteTests/SamplePaletteTests.swift)
cover every token/light-dark combination and unchanged unknown-token errors.
It is not a graphical demo and does not prove visual/interaction acceptance.

From a clean checkout of the historical NativeDesignKit `v0.1.0` tag, validate
that release with its own fixture and runner (which retain exact Tokens0.1.1):

```sh
python3 scripts/ci/external-consumer.py --version 0.1.0
```

This release validation runs after Git tag `v0.1.0` is created on the PR's
merge commit. Its results are recorded in the GitHub release notes; the
command here does not claim that tag-time validation has already run.

For pushed PR/pre-release revisions, use revision mode instead:

```sh
python3 scripts/ci/external-consumer.py --revision <full-40-character-commit-SHA>
```

The runner copies the fixture to its own temporary directory, replaces only
the shared-design-system dependency requirement with the requested exact
version or immutable SHA, resolves from the public repository, checks the
actual resolved version or SHA and shipped `ai/` entry,
then runs `swift build`, `swift test` and an iOS-simulator compile with an
isolated DerivedData directory. It never uses a local path dependency. Failure
of any command, missing docs, or a resolution mismatch fails the run. Version
mode also requires the resolved registry's release status to be `released`.
The current runner replaces the fixture's native requirement with the requested
immutable revision. Its direct Tokens requirement is exact `0.2.0`; use revision
mode after the provider release is available. Historical native tag validation
uses the fixture and runner from that same tag.

Do not report a revision run as release-tag validation. Git/Xcode caches may
be shared by the tools; source, build outputs and DerivedData for the consumer
are per-run. The runner does not launch a simulator or a host app.

The exact 0.2.0 provider adoption is a candidate until its authorized immutable
release is retrievable. The last released NativeDesignKit 0.1.0 retains its own
0.1.1 provider contract. Isolated local Git mirrors are test-only evidence;
remote dependency checks and release notes must name the final provider SHA.
