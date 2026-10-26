# shared-design-system

One Swift package with two stable products:

- `DesignTokens`: UI-free color and style data for iOS 15, macOS 12 and watchOS 8.
- `Strata`: SwiftUI components for iOS 15 and macOS 12. It depends on
  the local `DesignTokens` target and is intentionally unavailable on watchOS.

- Agents and contributors: start with [AGENTS.md](AGENTS.md).
- Architecture: [layer map](docs/architecture/tech-context.md).
- Visual theme: [Strata v0.2 rules](docs/strata-theme-v0.2.md) (accepted theme baseline).
- Unreleased components: [Strata component contracts](ai/COMPONENTS.md).
- Consumers: read `ai/` from the exact release you pin.
- DesignTokens consumers: read `Packages/DesignTokens/ai/` from that same exact
  revision. See [migration](ai/MIGRATION.md) for the manifest-only repository
  route change and rollback.
