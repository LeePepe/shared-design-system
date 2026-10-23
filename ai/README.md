# NativeDesignKit consumer contract

Release unit: `NativeDesignKit` (SwiftPM), current release contract **0.3.0**.
Use documents from the same immutable revision as the resolved package; do not
substitute documentation from `main`. The contract does not claim that the
corresponding tag or GitHub release already exists.

| Task | Start here |
| --- | --- |
| Integrate or remove the library | [INTEGRATION.md](INTEGRATION.md) |
| Define or audit a consumer project's design contract | [DESIGN-CONTRACT.md](DESIGN-CONTRACT.md) |
| Use the public API or investigate a lookup error | [USAGE.md](USAGE.md) |
| Evaluate unreleased Strata components | [COMPONENTS.md](COMPONENTS.md) |
| Run an ordinary external consumer | [EXAMPLES.md](EXAMPLES.md) |
| Check platforms and dependency compatibility | [COMPATIBILITY.md](COMPATIBILITY.md) |
| Replace local color bridges or roll back | [MIGRATION.md](MIGRATION.md) |
| Discover the contract mechanically | [registry.json](registry.json), [schema](registry.schema.json) |
| Review changes | [CHANGELOG.md](../CHANGELOG.md) |
| Use DesignTokens directly | [DesignTokens contract](../Packages/DesignTokens/ai/README.md) |

The `ai/` directory ships in the source archive and SwiftPM checkout. It is not
an App resource. Find it in the checkout whose identity is
`shared-design-system` under the consumer's `.build/checkouts/`, or Xcode's
resolved package checkout. Confirm the revision against `Package.resolved`
before reading. A missing document or version mismatch is an integration error;
never silently read a floating remote copy.

These documents describe APIs, not additional permissions. They do not authorize
publishing packages, changing consumer policy or sending production data.
