#!/usr/bin/env bash
# NativeDesignKit layer gates (called through the tech-context gate map).
#   scripts/ci/swift-package.sh build   swift build (macOS host)
#   scripts/ci/swift-package.sh test    swift test (macOS host, AppKit path)
#   scripts/ci/swift-package.sh ios     xcodebuild build + test on an iPhone simulator (UIKit path)
# Before the first package lands the repository has no Package.swift; then there
# is nothing to build and the gate passes, unless package sources already exist
# without a manifest (that fails).
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
mode="${1:?usage: swift-package.sh build|test|ios}"

if [ ! -f Package.swift ]; then
    if [ -n "$(git ls-files Sources Tests)" ]; then
        echo "[swift] Sources/ or Tests/ are tracked but Package.swift is missing" >&2
        exit 1
    fi
    echo "[swift] no Package.swift yet; nothing to $mode"
    exit 0
fi

case "$mode" in
    build) swift build ;;
    test) swift test ;;
    ios)
        device="$(xcrun simctl list devices available -j | python3 -c '
import json, sys
devices = json.load(sys.stdin)["devices"]
for runtime in sorted(devices, reverse=True):
    if ".iOS-" in runtime:
        for d in devices[runtime]:
            if d["name"].startswith("iPhone"):
                print(d["udid"]); sys.exit(0)
sys.exit("no available iPhone simulator")')"
        scheme="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["name"])' < <(swift package dump-package))"
        echo "[swift] iOS simulator $device, scheme $scheme"
        xcodebuild -scheme "$scheme" -destination "id=$device" -skipPackagePluginValidation test ;;
    *) echo "[swift] unknown mode: $mode" >&2; exit 2 ;;
esac
