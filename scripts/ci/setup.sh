#!/usr/bin/env bash
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
cd "$root/Packages/DesignTokens"
exec ./scripts/ci/setup.sh
