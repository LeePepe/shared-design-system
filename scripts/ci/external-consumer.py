#!/usr/bin/env python3
"""Build a public-product consumer of a remote immutable revision or exact tag."""
import argparse
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile


def run(*args, cwd):
    subprocess.run(args, cwd=cwd, check=True)


def main():
    parser = argparse.ArgumentParser()
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--revision")
    source.add_argument("--version")
    args = parser.parse_args()
    value = args.revision or args.version
    pattern = r"[0-9a-f]{40}" if args.revision else r"[0-9]+\.[0-9]+\.[0-9]+"
    if not re.fullmatch(pattern, value):
        parser.error("use an immutable 40-character SHA or exact semver")
    fixture = Path(__file__).resolve().parents[2] / "ai/examples/consumer"
    with tempfile.TemporaryDirectory(prefix="native-design-consumer-") as directory:
        root = Path(directory)
        consumer = root / "consumer"
        shutil.copytree(fixture, consumer)
        manifest = consumer / "Package.swift"
        requirement = f'revision: "{value}"' if args.revision else f'exact: "{value}"'
        content, count = re.subn(r'revision: "[0-9a-f]{40}"', requirement, manifest.read_text())
        if count != 1:
            raise RuntimeError("fixture must contain one candidate revision pin")
        manifest.write_text(content)
        run("swift", "package", "resolve", cwd=consumer)
        resolved = json.loads((consumer / "Package.resolved").read_text())
        pins = {pin["identity"]: pin["state"] for pin in resolved["pins"]}
        field = "revision" if args.revision else "version"
        if pins["shared-design-system"][field] != value:
            raise RuntimeError("resolved package does not match requested immutable dependency")
        if pins["shared-design-tokens"]["revision"] != "3a6d70f3ff2e01148ea303ea9219e08e877ca76c":
            raise RuntimeError("Tokens 0.1.0 revision mismatch")
        checkout = consumer / ".build/checkouts/shared-design-system"
        registry = json.loads((checkout / "ai/registry.json").read_text())
        if registry["library"] != "NativeDesignKit" or registry["version"] != "0.1.0":
            raise RuntimeError("resolved checkout AI contract mismatch")
        if args.version and registry["releaseStatus"] != "released":
            raise RuntimeError("a release tag cannot ship an unreleased contract")
        run("python3", str(checkout / "scripts/ci/check-ai.py"), cwd=checkout)
        run("swift", "build", cwd=consumer)
        run("swift", "test", cwd=consumer)
        run("xcodebuild", "-quiet", "-scheme", "NativeDesignConsumer",
            "-destination", "generic/platform=iOS Simulator",
            "-derivedDataPath", str(root / "DerivedData"),
            "CODE_SIGNING_ALLOWED=NO", "build", cwd=consumer)
        print(f"EXTERNAL_OK: {field}={value}; docs, macOS build/tests, iOS simulator build")


if __name__ == "__main__":
    main()
