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
    require(registry["version"] == "0.1.0", "AI_VERSION", "contract version drift")

    def resolve(base, name):
        path = (base / name.split("#", 1)[0]).resolve()
        require(path.is_relative_to(root), "AI_PATH", name)
        require(path.is_file(), "AI_DOCUMENT", name)
        return path

    for name in registry["documents"].values():
        resolve(ai, name)
    for name in registry["releaseUnits"].values():
        resolve(ai, name)
    if registry["releaseStatus"] == "released":
        changelog = (root / "CHANGELOG.md").read_text()
        require(re.search(r"^## 0\.1\.0(?:[ \t]|$)", changelog, re.MULTILINE) is not None,
                "AI_RELEASE", "released contract requires a 0.1.0 changelog heading")
        require("Unreleased — 0.1.0" not in changelog,
                "AI_RELEASE", "released contract contains an unreleased 0.1.0 changelog marker")
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
