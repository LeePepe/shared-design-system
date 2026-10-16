#!/usr/bin/env python3
"""Build a standalone SwiftUI fixture, run XCTest UI tests, export named PNGs."""
import argparse
import json
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys


REPO = Path(__file__).resolve().parents[3]


def run(command, **kwargs):
    print(shlex.join(map(str, command)), flush=True)
    return subprocess.run(list(map(str, command)), check=True, **kwargs)


def simulator(requested):
    # Same policy as scripts/ci/swift-package.sh: first available iPhone in the
    # newest iOS runtime, passed to xcodebuild as an explicit device UUID.
    inventory = json.loads(subprocess.check_output(
        ["xcrun", "simctl", "list", "devices", "available", "--json"], text=True
    ))["devices"]
    for runtime in sorted(inventory, reverse=True):
        if ".iOS-" not in runtime:
            continue
        for device in inventory[runtime]:
            if device["name"].startswith("iPhone") and (not requested or device["udid"] == requested):
                return dict(device, runtime=runtime)
    raise ValueError("No matching available iPhone simulator")


def export_screenshots(result, output, names, require_complete):
    raw = result.parent / (result.stem + ".attachments")
    run(["xcrun", "xcresulttool", "export", "attachments", "--path", result, "--output-path", raw])
    manifest = json.loads((raw / "manifest.json").read_text())
    index = []
    for name in names:
        candidates = []
        for test in manifest:
            for attachment in test["attachments"]:
                readable = attachment["suggestedHumanReadableName"]
                if re.search(r"(?<![a-z0-9-])" + re.escape(name) + r"(?=$|[^a-z0-9-])", readable):
                    candidates.append((test["testIdentifier"], attachment))
        if not candidates and not require_complete:
            continue
        if len(candidates) != 1:
            raise ValueError(f"Expected one attachment named {name}; found {len(candidates)}")
        test_id, attachment = candidates[0]
        source = (raw / attachment["exportedFileName"]).resolve()
        if not source.is_relative_to(raw.resolve()):
            raise ValueError("Attachment path escapes export directory")
        if source.read_bytes()[:8] != b"\x89PNG\r\n\x1a\n":
            raise ValueError(f"Named attachment is not PNG: {source}")
        destination = output / (name + ".png")
        shutil.copyfile(source, destination)
        index.append({"name": name, "file": destination.name, "test": test_id,
                      "exported_attachment": attachment["exportedFileName"]})
    (output / "attachments.json").write_text(json.dumps(index, indent=2) + "\n")
    return index


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("fixture", help="Name under Tests/Fixtures, or path to a fixture directory")
    parser.add_argument("--scheme", help="Shared scheme; defaults to fixture directory name")
    parser.add_argument("--results", required=True, type=Path, help="New external .xcresult path")
    parser.add_argument("--screenshots", required=True, type=Path, help="New/empty external PNG directory")
    parser.add_argument("--derived-data", type=Path, help="Isolated build directory; defaults beside results")
    parser.add_argument("--device", help="Explicit available iPhone UUID; default follows repository policy")
    args = parser.parse_args()
    fixture = Path(args.fixture)
    if not fixture.is_dir():
        fixture = REPO / "Tests/Fixtures" / args.fixture
    fixture = fixture.resolve()
    spec = fixture / "project.yml"
    if not spec.is_file():
        raise ValueError(f"Missing XcodeGen specification: {spec}")
    scheme = args.scheme or fixture.name
    result = args.results.resolve()
    output = args.screenshots.resolve()
    derived = (args.derived_data or result.with_suffix(".DerivedData")).resolve()
    for path in (result, output, derived):
        if path.is_relative_to(REPO):
            raise ValueError(f"Generated evidence/build output must be outside the repository: {path}")
    if result.suffix != ".xcresult" or result.exists() or derived.exists():
        raise ValueError("Use a new .xcresult path and isolated DerivedData directory for each run")
    if output.exists() and any(output.iterdir()):
        raise ValueError("Screenshot directory must be new or empty; stale evidence is not reused")
    names = json.loads((fixture / "screenshots.json").read_text())
    if not names or len(names) != len(set(names)) or not all(re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", n) for n in names):
        raise ValueError("screenshots.json must list unique lowercase attachment names")
    device = simulator(args.device)
    result.parent.mkdir(parents=True, exist_ok=True)
    output.mkdir(parents=True, exist_ok=True)
    record = {
        "sha": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=REPO, text=True).strip(),
        "dirty": bool(subprocess.check_output(["git", "status", "--porcelain"], cwd=REPO, text=True).strip()),
        "fixture": str(fixture), "scheme": scheme, "device": device,
        "result": str(result), "screenshots": str(output), "derived_data": str(derived)
    }
    print(json.dumps(record, indent=2), flush=True)
    run(["xcodegen", "generate", "--no-env", "--spec", spec, "--project", fixture], cwd=REPO)
    command = ["xcodebuild", "test", "-project", fixture / (fixture.name + ".xcodeproj"),
               "-scheme", scheme, "-destination", "platform=iOS Simulator,id=" + device["udid"],
               "-derivedDataPath", derived, "-resultBundlePath", result,
               "-parallel-testing-enabled", "NO", "-maximum-concurrent-test-simulator-destinations", "1",
               "-collect-test-diagnostics", "never",
               "-skipPackagePluginValidation", "CODE_SIGNING_ALLOWED=NO"]
    print(shlex.join(map(str, command)), flush=True)
    test_exit = subprocess.run(list(map(str, command)), cwd=REPO).returncode
    record["test_exit_code"] = test_exit
    export_exit = 0
    try:
        if not result.exists():
            raise ValueError("xcodebuild produced no result bundle")
        summary = subprocess.check_output(
            ["xcrun", "xcresulttool", "get", "test-results", "summary", "--path", str(result)], text=True
        )
        (result.parent / (result.stem + ".summary.json")).write_text(summary)
        record["summary"] = json.loads(summary)
        record["attachments"] = export_screenshots(result, output, names, require_complete=test_exit == 0)
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        export_exit = 1
        record["export_error"] = str(error)
        print(f"Attachment/result export failed: {error}", file=sys.stderr)
    record["exit_code"] = test_exit or export_exit
    (result.parent / (result.stem + ".run.json")).write_text(json.dumps(record, indent=2) + "\n")
    return record["exit_code"]


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        print(f"Fixture runner failed: {error}", file=sys.stderr)
        raise SystemExit(1)
