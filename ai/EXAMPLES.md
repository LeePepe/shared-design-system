# Executable external consumer

The fixture at [examples/consumer](examples/consumer/Package.swift) is a separate
Swift package. [SamplePalette.swift](examples/consumer/Sources/SamplePalette/SamplePalette.swift)
uses only public products. Its [tests](examples/consumer/Tests/SamplePaletteTests/SamplePaletteTests.swift)
cover every token/light-dark combination and unchanged unknown-token errors.
It is not a graphical demo and does not prove visual/interaction acceptance.

After a separately authorized NativeDesignKit `v0.3.0` tag exists, validate that
release from a clean checkout with its own fixture and runner:

```sh
python3 scripts/ci/external-consumer.py --version 0.3.0
```

This release validation runs only after Git tag `v0.3.0` is separately created
on the merge commit. Its results belong in the GitHub release notes; the command
here does not claim that the tag exists or that tag-time validation has run.

For pushed PR/pre-release revisions, use revision mode instead:

```sh
python3 scripts/ci/external-consumer.py --revision <full-40-character-commit-SHA>
```

The runner copies the fixture to its own task-local evidence directory, replaces only
the shared-design-system dependency requirement with the requested exact
version or immutable SHA, resolves from the public repository, checks the
actual resolved version or SHA and shipped `ai/` entry,
then runs `swift build`, `swift test` and an iOS-simulator compile with an
isolated DerivedData directory. It never uses a local path dependency. Failure
of any command, missing docs, or a resolution mismatch fails the run. Version
mode also requires the resolved registry's release status to be `released`.
The current runner selects both `NativeDesignKit` and `DesignTokens` from the
same immutable `shared-design-system` revision. Historical native tag validation
uses the fixture and runner from that same tag.

The historical NativeDesignKit `v0.1.0` tag retains its own fixture, runner and
exact DesignTokens 0.1.1 dependency.

Do not report a revision run as release-tag validation. Git/Xcode caches may
be shared by the tools; source, build outputs and DerivedData for the consumer
are per-run. The runner does not launch a simulator or a host app.
