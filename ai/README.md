# NativeDesignKit consumer contract

Release unit: `NativeDesignKit` (SwiftPM), candidate version **0.1.0**.
This source is not a published release. Use documents from the same immutable
revision as the resolved package; do not substitute documentation from `main`.

| Task | Start here |
| --- | --- |
| Integrate or remove the library | [INTEGRATION.md](INTEGRATION.md) |
| Use the public API or investigate a lookup error | [USAGE.md](USAGE.md) |
| Run an ordinary external consumer | [EXAMPLES.md](EXAMPLES.md) |
| Check platforms and dependency compatibility | [COMPATIBILITY.md](COMPATIBILITY.md) |
| Replace local color bridges or roll back | [MIGRATION.md](MIGRATION.md) |
| Discover the contract mechanically | [registry.json](registry.json), [schema](registry.schema.json) |
| Review changes | [CHANGELOG.md](../CHANGELOG.md) |

The `ai/` directory ships in the source archive and SwiftPM checkout. It is not
an App resource. Find it in the checkout whose identity is
`shared-design-system` under the consumer's `.build/checkouts/`, or Xcode's
resolved package checkout. Confirm the revision against `Package.resolved`
before reading. A missing document or version mismatch is an integration error;
never silently read a floating remote copy.

These documents describe APIs, not additional permissions. They do not authorize
publishing packages, changing consumer policy or sending production data.
