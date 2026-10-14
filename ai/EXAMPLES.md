# Executable external consumer

The fixture at [examples/consumer](examples/consumer/Package.swift) is a separate
Swift package. [SamplePalette.swift](examples/consumer/Sources/SamplePalette/SamplePalette.swift)
uses only public products. Its [tests](examples/consumer/Tests/SamplePaletteTests/SamplePaletteTests.swift)
cover every token/light-dark combination and unchanged unknown-token errors.
It is not a graphical demo and does not prove visual/interaction acceptance.

From this repository, validate the exact 0.1.0 release with:

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
The fixture defaults to exact `0.1.0`; the Tokens pin remains exact `0.1.1`.

Do not report a revision run as release-tag validation. Git/Xcode caches may
be shared by the tools; source, build outputs and DerivedData for the consumer
are per-run. The runner does not launch a simulator or a host app.
