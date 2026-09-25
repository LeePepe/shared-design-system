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
    require(registry["version"] == "0.1.0", "AI_VERSION", "candidate version drift")

    def resolve(base, name):
        path = (base / name.split("#", 1)[0]).resolve()
        require(path.is_relative_to(root), "AI_PATH", name)
        require(path.is_file(), "AI_DOCUMENT", name)
        return path

    for name in registry["documents"].values():
        resolve(ai, name)
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
    require('exact: "0.1.0"' in manifest, "AI_DEPENDENCY", "Tokens exact pin changed")
    for source_file in (ai / "examples").rglob("*.swift"):
        require("@testable" not in source_file.read_text(), "AI_EXAMPLE", "consumer uses test-only API")
    print("AI_OK: registry, local links, public API and candidate dependency contract")


if __name__ == "__main__":
    try:
        check(Path(__file__).resolve().parents[2])
    except (ValueError, OSError, KeyError) as error:
        print(error, file=sys.stderr)
        sys.exit(1)
