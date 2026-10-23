#!/usr/bin/env python3
"""Validate the narrow, versioned NativeDesignKit AI contract (stdlib only)."""
import json
from pathlib import Path
import re
import sys


def require(condition, code, detail):
    if not condition:
        raise ValueError(f"{code}: {detail}; see ai/README.md")


def schema_check(value, schema, path="registry"):
    # Deliberately implements only the keywords used by the checked-in schema.
    # Unknown keywords fail closed rather than silently weakening validation.
    known = {"$schema", "title", "type", "additionalProperties", "required",
             "properties", "const", "enum", "pattern", "minItems", "items"}
    require(not set(schema) - known, "AI_SCHEMA", f"unsupported keyword at {path}")
    kind = schema.get("type")
    types = {"object": dict, "array": list, "string": str}
    if kind:
        require(kind in types and type(value) is types[kind], "AI_SCHEMA", path)
    if "const" in schema:
        require(type(value) is type(schema["const"]) and value == schema["const"], "AI_SCHEMA", path)
    if "enum" in schema:
        require(value in schema["enum"], "AI_SCHEMA", path)
    if "pattern" in schema:
        require(re.fullmatch(schema["pattern"], value) is not None, "AI_VERSION", path)
    if kind == "object":
        require(set(schema.get("required", [])) <= set(value), "AI_SCHEMA", f"missing field at {path}")
        properties = schema.get("properties", {})
        if schema.get("additionalProperties") is False:
            require(not set(value) - set(properties), "AI_SCHEMA", f"extra field at {path}")
        for key, item in value.items():
            if key in properties:
                schema_check(item, properties[key], f"{path}.{key}")
    if kind == "array":
        require(len(value) >= schema.get("minItems", 0), "AI_SCHEMA", path)
        for index, item in enumerate(value):
            schema_check(item, schema["items"], f"{path}[{index}]")


def check(root):
    root = root.resolve()
    ai = root / "ai"
    registry = json.loads((ai / "registry.json").read_text())
    schema_check(registry, json.loads((ai / "registry.schema.json").read_text()))

    def resolve(base, name):
        path = (base / name.split("#", 1)[0]).resolve()
        require(path.is_relative_to(root), "AI_PATH", name)
        require(path.is_file(), "AI_DOCUMENT", name)
        return path

    for name in registry["documents"].values():
        resolve(ai, name)
    for name in registry["releaseUnits"].values():
        resolve(ai, name)
    design_contract = ai / "DESIGN-CONTRACT.md"
    require(design_contract.is_file(), "AI_DESIGN_CONTRACT",
            "ai/DESIGN-CONTRACT.md is missing")
    design_contract_text = design_contract.read_text()
    for heading in (
            "## Design system & version",
            "## Semantic token profile",
            "## Required view states",
            "## Redlines & CI gate"):
        require(heading in design_contract_text, "AI_DESIGN_CONTRACT",
                f"ai/DESIGN-CONTRACT.md is missing {heading}")
    if registry["releaseStatus"] == "released":
        changelog = (root / "CHANGELOG.md").read_text()
        version = registry["version"]
        heading = rf"^## {re.escape(version)}(?:[ \t]|$)"
        require(re.search(heading, changelog, re.MULTILINE) is not None,
                "AI_RELEASE",
                f"released contract requires a {version} changelog heading")
        require(f"Unreleased — {version}" not in changelog,
                "AI_RELEASE",
                f"released contract contains an unreleased {version} changelog marker")
    for capability in registry["capabilities"]:
        for field in ("source", "documentation", "example"):
            resolve(ai, capability[field])
    for document in ai.glob("*.md"):
        for target in re.findall(r"\[[^\]]*\]\(([^\s)]+)\)", document.read_text()):
            if "://" not in target and not target.startswith("#"):
                resolve(document.parent, target)
    source = (root / "Sources/NativeDesignKit/NativeTokenColor.swift").read_text()
    require("public enum NativeTokenColor" in source and
            "public static func resolve(_ id: String, theme: Theme) throws -> SwiftUI.Color" in source,
            "AI_API", "public resolver no longer matches registry")
    manifest = (root / "Package.swift").read_text()
    require("shared-design-tokens" not in manifest and ".package(" not in manifest,
            "AI_DEPENDENCY", "root package must not retain an external package edge")
    require(manifest.count('.library(name: "DesignTokens"') == 1 and
            manifest.count('.library(name: "NativeDesignKit"') == 1,
            "AI_DEPENDENCY", "root package must publish both stable products exactly once")
    require('name: "DesignTokens",\n            path: "Packages/DesignTokens/Sources/DesignTokens"' in manifest and
            'name: "NativeDesignKit",\n            dependencies: ["DesignTokens"]' in manifest,
            "AI_DEPENDENCY", "NativeDesignKit must depend on the local DesignTokens target")
    require(".iOS(.v15)" in manifest and ".macOS(.v12)" in manifest and
            ".watchOS(.v8)" in manifest,
            "AI_PLATFORMS", "package floors must remain iOS 15, macOS 12 and watchOS 8")
    require(not (root / "Package.resolved").exists(),
            "AI_DEPENDENCY", "a dependency-free root package must not retain the provider lock")
    nested_registry = json.loads(
        (root / "Packages/DesignTokens/ai/registry.json").read_text())
    require(nested_registry["package"]["name"] == "@leepepe/design-tokens" and
            nested_registry["package"]["version"] == "0.2.0" and
            nested_registry["package"]["swiftProduct"] == "DesignTokens",
            "AI_DESIGN_TOKENS", "nested release-unit identity mismatch")
    nested_readme = (root / "Packages/DesignTokens/ai/README.md").read_text()
    require("shared-design-system.git" in nested_readme and
            "shared-design-system" in nested_readme,
            "AI_DESIGN_TOKENS", "nested contract does not name the consolidated route")
    usage = (ai / "USAGE.md").read_text()
    nested_usage = (root / "Packages/DesignTokens/ai/USAGE.md").read_text()
    for document, content in (
            ("ai/USAGE.md", usage),
            ("Packages/DesignTokens/ai/USAGE.md", nested_usage)):
        stable_products = (
            "stable `NativeDesignKit` and `DesignTokens` products" in content or
            "stable `DesignTokens` and `NativeDesignKit` products" in content)
        require(stable_products and
                "exact `shared-design-system` revision or version" in content and
                "repository-local `DesignTokens` target" in content,
                "AI_DESIGN_TOKENS",
                f"{document} does not describe the consolidated live route")
    require("NativeDesignKit `0.1.0` historically pinned Tokens at exactly `0.1.1`"
            in usage and
            "historical provider DesignTokens 0.2.0 release" in usage and
            "provider DesignTokens `0.2.0` release remains immutable compatibility history"
            in nested_usage,
            "AI_DESIGN_TOKENS", "historical release facts were removed from usage")
    obsolete_routes = {
        "ai/USAGE.md": (
            "The current unreleased checkout pins Tokens at exactly `0.2.0`",
        ),
        "Packages/DesignTokens/ai/USAGE.md": (
            "Planned elsewhere: independent Apple NativeDesignKit/SPM repository",
        ),
    }
    for document, content in (
            ("ai/USAGE.md", usage),
            ("Packages/DesignTokens/ai/USAGE.md", nested_usage)):
        require(not any(route in content for route in obsolete_routes[document]),
                "AI_DESIGN_TOKENS",
                f"{document} retains an obsolete dependency route")
    guard = (root / "Sources/NativeDesignKit/PlatformBoundary.swift").read_text()
    require('#if os(watchOS)' in guard and
            '#error("NativeDesignKit is unavailable on watchOS; depend on the DesignTokens product only.")' in guard,
            "AI_PLATFORMS", "stable NativeDesignKit watchOS boundary is missing")
    for source_file in (ai / "examples").rglob("*.swift"):
        require("@testable" not in source_file.read_text(), "AI_EXAMPLE", "consumer uses test-only API")
    print("AI_OK: registries, links, public API, local dependency and platform boundary")


if __name__ == "__main__":
    try:
        check(Path(__file__).resolve().parents[2])
    except (ValueError, OSError, KeyError) as error:
        print(error, file=sys.stderr)
        sys.exit(1)
