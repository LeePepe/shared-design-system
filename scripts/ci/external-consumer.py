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
from urllib.parse import urlsplit


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


def parse_resolved_pins(resolved):
    schema_version = resolved.get("version")
    if schema_version == 1:
        pins = resolved.get("object", {}).get("pins")
    else:
        pins = resolved.get("pins")
    if not isinstance(pins, list):
        raise RuntimeError("Package.resolved does not contain a pin list")

    parsed = []
    for pin in pins:
        if not isinstance(pin, dict) or not isinstance(pin.get("state"), dict):
            raise RuntimeError("Package.resolved contains a malformed pin")
        if schema_version == 1:
            identity = pin.get("package")
            location = pin.get("repositoryURL")
            kind = "remoteSourceControl" if location else None
            kind_field = None
            location_field = "repositoryURL"
        else:
            identity = pin.get("identity")
            location = pin.get("location")
            kind = pin.get("kind")
            kind_field = "kind"
            location_field = "location"
        if not all(isinstance(item, str) and item
                   for item in (identity, kind, location)):
            raise RuntimeError("Package.resolved pin lacks source provenance")
        parsed.append({
            "schemaVersion": schema_version,
            "identity": identity,
            "kind": kind,
            "kindField": kind_field,
            "location": location,
            "locationField": location_field,
            "state": dict(pin["state"]),
        })
    return parsed


def canonical_repository_url(location):
    scp_match = re.fullmatch(
        r"git@github\.com:LeePepe/shared-design-system(?:\.git)?/?",
        location, re.IGNORECASE)
    if scp_match:
        return REPOSITORY_URL

    parsed = urlsplit(location)
    if parsed.scheme not in {"https", "ssh", "git"}:
        return None
    if parsed.hostname is None or parsed.hostname.lower() != "github.com":
        return None
    if parsed.port is not None or parsed.query or parsed.fragment:
        return None
    if parsed.username not in (None, "git") or parsed.password is not None:
        return None
    path = parsed.path.rstrip("/")
    if path.lower() not in {
            "/leepepe/shared-design-system",
            "/leepepe/shared-design-system.git"}:
        return None
    return REPOSITORY_URL


def canonical_checkout_repository(
        checkout_origin, repositories_root=None, repository_cache_origin=None):
    direct = canonical_repository_url(checkout_origin.strip())
    if direct:
        return direct
    if repositories_root is None or repository_cache_origin is None:
        return None

    origin_path = Path(checkout_origin.strip())
    if not origin_path.is_absolute():
        return None
    try:
        resolved_origin = origin_path.resolve(strict=True)
        resolved_root = Path(repositories_root).resolve(strict=True)
    except OSError:
        return None
    if resolved_origin.parent != resolved_root or not resolved_origin.is_dir():
        return None
    return canonical_repository_url(repository_cache_origin.strip())


def validate_public_resolution(receipt, pins, kind, value):
    observed = [dict(pin) for pin in pins]
    for pin in observed:
        pin["canonicalRepositoryURL"] = canonical_repository_url(
            pin["location"])
    receipt["source"]["observed"] = observed
    try:
        if len(pins) != 1 or pins[0]["identity"] != "shared-design-system":
            raise RuntimeError(
                "consumer resolution must contain only shared-design-system")
        pin = pins[0]
        if pin["state"].get(kind) != value:
            raise RuntimeError(
                "resolved package does not match requested immutable dependency")
        if pin["kind"] != "remoteSourceControl":
            raise RuntimeError(
                "resolved package is not a remote source-control dependency")
        if canonical_repository_url(pin["location"]) != REPOSITORY_URL:
            raise RuntimeError(
                "resolved package does not use the canonical public repository")
    except Exception:
        receipt["status"] = "failed"
        raise
    receipt["packageIdentities"] = ["shared-design-system"]


def validate_effective_public_source(
        receipt, mirror_exit_status, mirror_output, checkout_origin,
        repositories_root=None, repository_cache_origin=None):
    receipt["source"]["effectiveMirrorQuery"] = {
        "exitStatus": mirror_exit_status,
        "output": mirror_output.strip(),
    }
    receipt["source"]["checkoutOrigin"] = checkout_origin.strip()
    if repository_cache_origin is not None:
        receipt["source"]["repositoryCacheOrigin"] = (
            repository_cache_origin.strip())
    resolved_repository = canonical_checkout_repository(
        checkout_origin, repositories_root, repository_cache_origin)
    receipt["source"]["resolvedRepositoryURL"] = resolved_repository
    try:
        if mirror_exit_status == 0:
            raise RuntimeError(
                "SwiftPM mirror substitution is configured for the package")
        if mirror_exit_status != 1 or mirror_output.strip() != "not found":
            raise RuntimeError(
                "SwiftPM mirror configuration could not be verified")
        if resolved_repository != REPOSITORY_URL:
            raise RuntimeError(
                "resolved checkout origin is not the canonical public repository")
    except Exception:
        receipt["status"] = "failed"
        raise
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
    observed = receipt["source"].get("observed")
    if (not isinstance(observed, list) or len(observed) != 1 or
            observed[0].get("identity") != "shared-design-system" or
            observed[0].get("kind") != "remoteSourceControl" or
            observed[0].get("canonicalRepositoryURL") != REPOSITORY_URL):
        raise RuntimeError("external receipt lacks canonical observed provenance")
    mirror_query = receipt["source"].get("effectiveMirrorQuery")
    if (not isinstance(mirror_query, dict) or
            mirror_query.get("exitStatus") != 1 or
            mirror_query.get("output") != "not found"):
        raise RuntimeError("external receipt does not exclude SwiftPM mirrors")
    checkout_origin = receipt["source"].get("checkoutOrigin", "")
    if receipt["source"].get("resolvedRepositoryURL") != REPOSITORY_URL:
        raise RuntimeError("external receipt lacks canonical checkout origin")
    if (canonical_repository_url(checkout_origin) is None and
            canonical_repository_url(receipt["source"].get(
                "repositoryCacheOrigin", "")) != REPOSITORY_URL):
        raise RuntimeError(
            "external receipt lacks canonical repository cache origin")
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
        pins = parse_resolved_pins(resolved)
        validate_public_resolution(receipt, pins, kind, value)

        checkout = consumer / ".build/checkouts/shared-design-system"
        mirror = subprocess.run(
            [
                "swift", "package", "config", "get-mirror",
                "--original", REPOSITORY_URL,
            ],
            cwd=consumer, text=True, stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT)
        origin = subprocess.run(
            ["git", "-C", str(checkout), "remote", "get-url", "origin"],
            cwd=consumer, text=True, stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT)
        if origin.returncode:
            raise RuntimeError(
                "resolved checkout origin could not be inspected: " +
                origin.stdout.strip())
        repositories = consumer / ".build/repositories"
        repository_cache_origin = None
        if canonical_repository_url(origin.stdout.strip()) is None:
            repository_cache = subprocess.run(
                [
                    "git", "--git-dir", origin.stdout.strip(),
                    "remote", "get-url", "origin",
                ],
                cwd=consumer, text=True, stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT)
            if repository_cache.returncode:
                raise RuntimeError(
                    "resolved repository cache origin could not be inspected: " +
                    repository_cache.stdout.strip())
            repository_cache_origin = repository_cache.stdout
        validate_effective_public_source(
            receipt, mirror.returncode, mirror.stdout, origin.stdout,
            repositories, repository_cache_origin)
        write_receipt(receipt_path, receipt)

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
