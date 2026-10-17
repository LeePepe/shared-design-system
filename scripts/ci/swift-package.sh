#!/usr/bin/env bash
# NativeDesignKit layer gates (called through the tech-context gate map).
#   scripts/ci/swift-package.sh build   swift build (macOS host)
#   scripts/ci/swift-package.sh test    swift test (macOS host, AppKit path)
#   scripts/ci/swift-package.sh ios     xcodebuild build + test on an iPhone simulator (UIKit path)
# Before the first package lands the repository has no Package.swift; then there
# is nothing to build and the gate passes, unless package sources already exist
# without a manifest (that fails).
set -euo pipefail

root="${SWIFT_PACKAGE_ROOT:-$(git rev-parse --show-toplevel)}"
cd "$root"
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
        metadata_dir="$(mktemp -d "${TMPDIR:-/tmp}/swift-package.XXXXXX")"
        trap 'rm -rf "$metadata_dir"' EXIT
        device="$(xcrun simctl list devices available -j | python3 -c '
import json, sys
devices = json.load(sys.stdin)["devices"]
for runtime in sorted(devices, reverse=True):
    if ".iOS-" in runtime:
        for d in devices[runtime]:
            if d["name"].startswith("iPhone"):
                print(d["udid"]); sys.exit(0)
sys.exit("no available iPhone simulator")')"

        swift package dump-package > "$metadata_dir/package.json"
        python3 - "$metadata_dir/package.json" "$metadata_dir/expected-tests.json" <<'PY'
import json
import sys

source, destination = sys.argv[1:]
try:
    with open(source, encoding="utf-8") as stream:
        package = json.load(stream)
    targets = package["targets"]
    names = sorted({
        target["name"]
        for target in targets
        if isinstance(target, dict) and target.get("type") == "test"
    })
    if not names or any(not isinstance(name, str) or not name for name in names):
        raise ValueError("no declared test targets")
except (OSError, KeyError, TypeError, ValueError, json.JSONDecodeError) as error:
    sys.exit(f"[swift] invalid package metadata: {error}")
with open(destination, "w", encoding="utf-8") as stream:
    json.dump(names, stream)
PY

        xcodebuild -list -json > "$metadata_dir/schemes.json"
        python3 - "$metadata_dir/schemes.json" "$metadata_dir/schemes.txt" <<'PY'
import json
import sys

source, destination = sys.argv[1:]
try:
    with open(source, encoding="utf-8") as stream:
        listing = json.load(stream)
    containers = [
        listing[key]
        for key in ("workspace", "project")
        if isinstance(listing.get(key), dict)
    ]
    if len(containers) != 1:
        raise ValueError("expected exactly one workspace or project")
    schemes = containers[0]["schemes"]
    if not isinstance(schemes, list) or not schemes:
        raise ValueError("no generated schemes")
    if any(not isinstance(name, str) or not name or "\n" in name for name in schemes):
        raise ValueError("invalid generated scheme name")
    schemes = sorted(set(schemes))
except (OSError, KeyError, TypeError, ValueError, json.JSONDecodeError) as error:
    sys.exit(f"[swift] invalid Xcode scheme metadata: {error}")
with open(destination, "w", encoding="utf-8") as stream:
    stream.write("".join(f"{name}\n" for name in schemes))
PY

        : > "$metadata_dir/usable-schemes.txt"
        index=0
        while IFS= read -r candidate; do
            enumeration="$metadata_dir/enumeration-$index.json"
            enumeration_result="$metadata_dir/enumeration-$index.xcresult"
            if xcodebuild \
                -scheme "$candidate" \
                -destination "id=$device" \
                -skipPackagePluginValidation \
                -resultBundlePath "$enumeration_result" \
                test \
                -enumerate-tests \
                -test-enumeration-format json \
                -test-enumeration-style hierarchical \
                -test-enumeration-output-path "$enumeration"
            then
                test_results="$metadata_dir/test-results-$index.json"
                if [ ! -f "$enumeration" ] && [ -d "$enumeration_result" ]; then
                    if ! xcrun xcresulttool get test-results tests \
                        --path "$enumeration_result" > "$test_results"
                    then
                        rm -f "$test_results"
                    fi
                fi
                if python3 - \
                    "$metadata_dir/expected-tests.json" \
                    "$enumeration" \
                    "$test_results" <<'PY'
import json
from pathlib import Path
import sys

expected_path, enumeration_path, test_results_path = map(Path, sys.argv[1:])

def contains_test(node):
    if node["kind"] == "test":
        return True
    return any(contains_test(child) for child in node["children"])

def covered_targets(node):
    covered = set()
    if node["kind"] == "target" and contains_test(node):
        covered.add(node["name"])
    for child in node["children"]:
        covered.update(covered_targets(child))
    return covered

def walk(value):
    yield value
    if isinstance(value, dict):
        for child in value.values():
            yield from walk(child)
    elif isinstance(value, list):
        for child in value:
            yield from walk(child)

try:
    with open(expected_path, encoding="utf-8") as stream:
        expected = set(json.load(stream))
    if enumeration_path.is_file():
        with open(enumeration_path, encoding="utf-8") as stream:
            enumeration = json.load(stream)
        if not isinstance(enumeration, dict) or not enumeration:
            raise ValueError("empty test enumeration")
        if (not isinstance(enumeration.get("errors"), list) or
                enumeration["errors"]):
            raise ValueError("test enumeration reported errors")
        values = enumeration.get("values")
        if not isinstance(values, list) or not values:
            raise ValueError("test enumeration has no values hierarchy")
        def validate_node(node):
            if not isinstance(node, dict):
                raise ValueError("test enumeration node is not an object")
            if not isinstance(node.get("kind"), str) or not node["kind"]:
                raise ValueError("test enumeration node has no kind")
            if not isinstance(node.get("name"), str) or not node["name"]:
                raise ValueError("test enumeration node has no name")
            if node["kind"] == "test":
                if "children" in node and node["children"] != []:
                    raise ValueError("test enumeration test node has children")
                node["children"] = []
                return
            if not isinstance(node.get("children"), list) or not node["children"]:
                raise ValueError("test enumeration node has no children")
            for child in node["children"]:
                validate_node(child)
        for plan in values:
            validate_node(plan)
            if plan["kind"] != "plan":
                raise ValueError("test enumeration value is not a plan")
        covered = set()
        for plan in values:
            covered.update(covered_targets(plan))
    elif test_results_path.is_file():
        with open(test_results_path, encoding="utf-8") as stream:
            results = json.load(stream)
        covered = {
            node["name"]
            for node in walk(results)
            if (
                isinstance(node, dict)
                and node.get("nodeType") == "Unit test bundle"
                and isinstance(node.get("name"), str)
                and node["name"]
            )
        }
    else:
        raise ValueError("no test enumeration or result evidence")
except (OSError, TypeError, ValueError, json.JSONDecodeError):
    sys.exit(1)
sys.exit(0 if expected.issubset(covered) else 1)
PY
                then
                    printf '%s\n' "$candidate" >> "$metadata_dir/usable-schemes.txt"
                fi
            fi
            index=$((index + 1))
        done < "$metadata_dir/schemes.txt"

        usable_count="$(wc -l < "$metadata_dir/usable-schemes.txt" | tr -d ' ')"
        if [ "$usable_count" -ne 1 ]; then
            echo "[swift] expected exactly one complete test-capable scheme, found $usable_count" >&2
            exit 1
        fi
        scheme="$(sed -n '1p' "$metadata_dir/usable-schemes.txt")"
        echo "[swift] iOS simulator $device, scheme $scheme"
        test_args=(
            -scheme "$scheme"
            -destination "id=$device"
            -skipPackagePluginValidation
        )
        if [ -n "${SWIFT_PACKAGE_RESULT_BUNDLE_PATH:-}" ]; then
            test_args+=(-resultBundlePath "$SWIFT_PACKAGE_RESULT_BUNDLE_PATH")
        fi
        xcodebuild "${test_args[@]}" test ;;
    *) echo "[swift] unknown mode: $mode" >&2; exit 2 ;;
esac
