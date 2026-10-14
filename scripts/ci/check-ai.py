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
             "properties", "const", "enum", "pattern", "minItems", "maxItems",
             "items", "prefixItems"}
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
        if "minItems" in schema:
            require(len(value) >= schema["minItems"], "AI_SCHEMA", f"too few items at {path}")
        if "maxItems" in schema:
            require(len(value) <= schema["maxItems"], "AI_SCHEMA", f"too many items at {path}")
        if "prefixItems" in schema:
            prefix = schema["prefixItems"]
            require(len(value) >= len(prefix), "AI_SCHEMA", f"missing prefix items at {path}")
            for index, item_schema in enumerate(prefix):
                if index < len(value):
                    schema_check(value[index], item_schema, f"{path}[{index}]")
            if schema.get("items") is False:
                require(len(value) == len(prefix), "AI_SCHEMA", f"extra items past prefix at {path}")
            elif "items" in schema and isinstance(schema["items"], dict):
                for index in range(len(prefix), len(value)):
                    schema_check(value[index], schema["items"], f"{path}[{index}]")
        elif "items" in schema:
            if isinstance(schema["items"], dict):
                for index, item in enumerate(value):
                    schema_check(item, schema["items"], f"{path}[{index}]")
            elif schema["items"] is False:
                require(len(value) == 0, "AI_SCHEMA", f"no items allowed at {path}")


def check(root):
    root = root.resolve()
    ai = root / "ai"
    registry = json.loads((ai / "registry.json").read_text())
    schema_check(registry, json.loads((ai / "registry.schema.json").read_text()))
    require(registry["version"] == "0.2.0", "AI_VERSION", "contract version drift")

    def resolve(base, name):
        path = (base / name.split("#", 1)[0]).resolve()
        require(path.is_relative_to(root), "AI_PATH", name)
        require(path.is_file(), "AI_DOCUMENT", name)
        return path

    for name in registry["documents"].values():
        resolve(ai, name)
    changelog = (root / "CHANGELOG.md").read_text()
    if registry["releaseStatus"] == "released":
        require(re.search(r"^## 0\.2\.0(?:[ \t]|$)", changelog, re.MULTILINE) is not None,
                "AI_RELEASE", "released contract requires a 0.2.0 changelog heading")
        require("Unreleased — 0.2.0" not in changelog,
                "AI_RELEASE", "released contract contains an unreleased 0.2.0 changelog marker")
    elif registry["releaseStatus"] == "unreleased":
        require(re.search(r"^## Unreleased — 0\.2\.0(?:[ \t]|$)", changelog, re.MULTILINE) is not None,
                "AI_RELEASE", "unreleased contract requires an 'Unreleased — 0.2.0' changelog heading")
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
    theme_source = (root / "Sources/NativeDesignKit/NativeDesignTheme.swift").read_text()
    require("public struct NativeDesignTheme" in theme_source and
            "public init(theme: Theme) throws" in theme_source,
            "AI_API", "public theme initializer no longer matches registry")
    public_inits = [re.sub(r"\s+", " ", p).strip() for p in re.findall(r"public\s+init\s*\((.*?)\)", theme_source, re.DOTALL)]
    require(len(public_inits) == 1 and public_inits[0] == "theme: Theme",
            "AI_API", "NativeDesignTheme must expose only public init(theme: Theme) throws")
    require(len(re.findall(r"public\s+init\s*\(\s*\)", theme_source, re.DOTALL)) == 0,
            "AI_API", "NativeDesignTheme must not expose a public default initializer")
    require(not any("id" in p or "token" in p for p in public_inits),
            "AI_API", "NativeDesignTheme must not expose a public custom-ID initializer")
    card_source = (root / "Sources/NativeDesignKit/NativeCard.swift").read_text()
    require("public struct NativeCard" in card_source and
            "public init(" in card_source,
            "AI_API", "public card no longer matches registry")
    manifest = (root / "Package.swift").read_text()
    require('exact: "0.1.1"' in manifest, "AI_DEPENDENCY", "Tokens exact pin changed")
    for source_file in (ai / "examples").rglob("*.swift"):
        require("@testable" not in source_file.read_text(), "AI_EXAMPLE", "consumer uses test-only API")
    print("AI_OK: registry, release changelog, local links, public API and dependency contract")


if __name__ == "__main__":
    try:
        check(Path(__file__).resolve().parents[2])
    except (ValueError, OSError, KeyError) as error:
        print(error, file=sys.stderr)
        sys.exit(1)
