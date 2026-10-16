#!/usr/bin/env bash
# Explicit local-only provider fixture. No dependency resolution or publishing.
set -euo pipefail
cd "$(dirname "$0")"
provider="${1:?usage: prepare.sh /path/to/reviewed/shared-design-tokens}"
provider="$(cd "$provider" && pwd)"
mkdir -p StyleProvider
cp "$provider/dist/styles.resolved.json" StyleProvider/styles.resolved.json
git -C "$provider" rev-parse HEAD > StyleProvider/provider-revision.txt
shasum -a 256 StyleProvider/styles.resolved.json > StyleProvider/provider-sha256.txt
if [ -n "$(git -C "$provider" status --porcelain -- tokens/styles.json dist/styles.resolved.json)" ]; then
    printf '%s\n' 'UNCOMMITTED provider styles: record JSON hash; this is not exact-commit integration evidence.' >> StyleProvider/provider-revision.txt
fi
xcodegen generate --spec project.yml
