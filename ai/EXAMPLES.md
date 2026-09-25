# Executable external consumer

The fixture at [examples/consumer](examples/consumer/Package.swift) is a separate
Swift package. [SamplePalette.swift](examples/consumer/Sources/SamplePalette/SamplePalette.swift)
uses only public products. Its [tests](examples/consumer/Tests/SamplePaletteTests/SamplePaletteTests.swift)
cover every token/light-dark combination and unchanged unknown-token errors.
It is not a graphical demo and does not prove visual/interaction acceptance.

From this repository, evaluate a pushed candidate with:

```sh
python3 scripts/ci/external-consumer.py --revision <full-40-character-commit-SHA>
```

The runner copies the fixture to its own temporary directory, replaces only
the dependency revision with the supplied immutable SHA, resolves from the
public repository, checks the actual resolved SHA and shipped `ai/` entry,
then runs `swift build`, `swift test` and an iOS-simulator compile with an
isolated DerivedData directory. It never uses a local path dependency. Failure
of any command, missing docs, or a resolution mismatch fails the run. The
fixture's checked-in SHA is the initial color-bridge baseline, not a claim
that baseline has the complete AI contract.

After publication, repeat with `--version 0.1.0`; this generates an exact
version dependency and checks the resolved version. Do not report a revision
run as release-tag validation. Git/Xcode caches may be shared by the tools;
source, build outputs and DerivedData for the consumer are per-run. The runner
does not launch a simulator or a host app.
