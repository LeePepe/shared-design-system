#!/usr/bin/env python3
"""Build a public-product consumer and retain an exact-resolution receipt."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile


REPOSITORY_URL = "https://github.com/LeePepe/shared-design-system.git"
PRODUCTS = ["DesignTokens", "NativeDesignKit"]
CONTRACT_PATHS = [
    "ai/registry.json",
    "Packages/DesignTokens/ai/registry.json",
]
PACKAGE_REQUIREMENT_PATTERN = (
    r'(?m)^([ \t]*\.package\(url: "https://github\.com/LeePepe/shared-design-system\.git", )'
    r'(?:revision: "[0-9a-f]{40}"|exact: "[0-9]+\.[0-9]+\.[0-9]+")'
    r'(\))'
)


def write_receipt(path, receipt):
    pending = path.with_suffix(".json.pending")
    pending.write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n")
    pending.replace(path)


def run(command, args, cwd, evidence, receipt):
    argv = [command, *args]
    result = subprocess.run(
        argv, cwd=cwd, text=True, stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT)
    log = f"command-{len(receipt['commands']) + 1}.log"
    (evidence / log).write_text(result.stdout)
    receipt["commands"].append({
        "argv": argv,
        "cwd": str(cwd),
        "exitStatus": result.returncode,
        "log": log,
    })
    write_receipt(evidence / "receipt.json", receipt)
    if result.returncode:
        raise subprocess.CalledProcessError(
            result.returncode, argv, output=result.stdout)
    return result.stdout


def parse_test_counts(output):
    summaries = [
        (int(tests), int(failures))
        for tests, failures in re.findall(
            r"Executed (\d+) tests?, with (\d+) failures?", output)
    ]
    if not summaries:
        raise RuntimeError("swift test output did not report test counts")
    executed, failed = max(summaries, key=lambda summary: summary[0])
    if executed <= 0:
        raise RuntimeError("external consumer must execute at least one test")
    return {
        "executed": executed,
        "passed": executed - failed,
        "failed": failed,
    }


def contract_receipts(checkout):
    contracts = []
    for relative in CONTRACT_PATHS:
        path = checkout / relative
        content = path.read_bytes()
        contracts.append({
            "path": relative,
            "sha256": hashlib.sha256(content).hexdigest(),
        })
    return contracts


def validate_public_resolution(receipt, pins, kind, value):
    if pins.get("shared-design-system", {}).get(kind) != value:
        raise RuntimeError(
            "resolved package does not match requested immutable dependency")
    if set(pins) != {"shared-design-system"}:
        raise RuntimeError(
            "consumer resolution must contain only shared-design-system")
    receipt["packageIdentities"] = sorted(pins)
    receipt["source"]["publiclyResolvable"] = True


def validate_success_receipt(receipt):
    required = {
        "repositoryURL", "source", "packageIdentities", "selectedProducts",
        "contractPaths", "commands", "testCounts", "status",
    }
    missing = required - receipt.keys()
    if missing:
        raise RuntimeError(
            f"external receipt missing required fields: {sorted(missing)}")
    if receipt["repositoryURL"] != REPOSITORY_URL:
        raise RuntimeError("external receipt repository URL drift")
    if receipt["selectedProducts"] != PRODUCTS:
        raise RuntimeError("external receipt product selection drift")
    if receipt["packageIdentities"] != ["shared-design-system"]:
        raise RuntimeError("external receipt package identity drift")
    if [item["path"] for item in receipt["contractPaths"]] != CONTRACT_PATHS:
        raise RuntimeError("external receipt contract path drift")
    if not receipt["commands"] or any(
            not isinstance(item.get("exitStatus"), int)
            for item in receipt["commands"]):
        raise RuntimeError("external receipt lacks command exit statuses")
    if receipt["testCounts"]["executed"] <= 0:
        raise RuntimeError("external receipt lacks executed test counts")
    if receipt["testCounts"]["failed"] != 0:
        raise RuntimeError("external consumer tests failed")
    if not receipt["source"].get("publiclyResolvable"):
        raise RuntimeError("external receipt cannot claim a local source")
    if receipt["status"] != "passed":
        raise RuntimeError("external receipt status is not passed")


def main():
    parser = argparse.ArgumentParser()
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--revision")
    source.add_argument("--version")
    args = parser.parse_args()
    value = args.revision or args.version
    kind = "revision" if args.revision else "version"
    pattern = r"[0-9a-f]{40}" if args.revision else r"[0-9]+\.[0-9]+\.[0-9]+"
    if not re.fullmatch(pattern, value):
        parser.error("use an immutable 40-character SHA or exact semver")

    repository = Path(__file__).resolve().parents[2]
    evidence_root = Path(os.environ.get(
        "NATIVE_EVIDENCE_DIR", repository / ".build/evidence"))
    evidence_root.mkdir(parents=True, exist_ok=True)
    evidence = Path(tempfile.mkdtemp(
        prefix="native-design-consumer-", dir=evidence_root))
    receipt_path = evidence / "receipt.json"
    receipt = {
        "schemaVersion": 1,
        "repositoryURL": REPOSITORY_URL,
        "source": {
            "kind": kind,
            "value": value,
            "publiclyResolvable": False,
        },
        "packageIdentities": [],
        "selectedProducts": PRODUCTS,
        "contractPaths": [],
        "commands": [],
        "testCounts": {},
        "status": "running",
    }
    write_receipt(receipt_path, receipt)

    try:
        consumer = evidence / "consumer"
        shutil.copytree(repository / "ai/examples/consumer", consumer)
        manifest = consumer / "Package.swift"
        requirement = (
            f'revision: "{value}"' if args.revision else f'exact: "{value}"')
        content, count = re.subn(
            PACKAGE_REQUIREMENT_PATTERN,
            lambda match: match[1] + requirement + match[2],
            manifest.read_text())
        if count != 1:
            raise RuntimeError(
                "fixture must contain exactly one immutable package pin")
        manifest.write_text(content)

        run("swift", ["package", "resolve"], consumer, evidence, receipt)
        resolved = json.loads((consumer / "Package.resolved").read_text())
        pins = {pin["identity"]: pin["state"] for pin in resolved["pins"]}
        validate_public_resolution(receipt, pins, kind, value)
        write_receipt(receipt_path, receipt)

        checkout = consumer / ".build/checkouts/shared-design-system"
        registry = json.loads((checkout / "ai/registry.json").read_text())
        if registry["library"] != "NativeDesignKit" or registry["version"] != "0.1.0":
            raise RuntimeError("resolved checkout AI contract mismatch")
        if args.version and registry["releaseStatus"] != "released":
            raise RuntimeError("a release tag cannot ship an unreleased contract")
        token_registry = json.loads(
            (checkout / "Packages/DesignTokens/ai/registry.json").read_text())
        if (token_registry["package"]["name"] != "@leepepe/design-tokens" or
                token_registry["package"]["version"] != "0.2.0" or
                token_registry["package"]["swiftProduct"] != "DesignTokens"):
            raise RuntimeError("resolved DesignTokens contract mismatch")
        receipt["contractPaths"] = contract_receipts(checkout)
        write_receipt(receipt_path, receipt)

        run("python3", [str(checkout / "scripts/ci/check-ai.py")],
            checkout, evidence, receipt)
        run("swift", ["build"], consumer, evidence, receipt)
        test_output = run("swift", ["test"], consumer, evidence, receipt)
        receipt["testCounts"] = parse_test_counts(test_output)
        run(
            "xcodebuild",
            [
                "-quiet", "-scheme", "NativeDesignConsumer",
                "-destination", "generic/platform=iOS Simulator",
                "-derivedDataPath", str(evidence / "DerivedData"),
                "CODE_SIGNING_ALLOWED=NO", "build",
            ],
            consumer, evidence, receipt)
        receipt["status"] = "passed"
        validate_success_receipt(receipt)
        write_receipt(receipt_path, receipt)
    except Exception as error:
        receipt["status"] = "failed"
        receipt["error"] = f"{type(error).__name__}: {error}"
        write_receipt(receipt_path, receipt)
        raise

    print(
        f"EXTERNAL_OK: {kind}={value}; receipt={receipt_path}; "
        f"{receipt['testCounts']['executed']} tests; both products and contracts")


if __name__ == "__main__":
    main()
