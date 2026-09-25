#!/usr/bin/env python3
"""Positive/negative fixtures for the AI contract, never touching tracked data."""
import importlib.util
import json
from pathlib import Path
import shutil
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location("check_ai", ROOT / "scripts/ci/check-ai.py")
CHECK = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(CHECK)


class ContractTests(unittest.TestCase):
    def setUp(self):
        self.scratch = tempfile.TemporaryDirectory(prefix="native-ai-negative-")
        self.root = Path(self.scratch.name)
        for directory in ("ai", "Sources"):
            shutil.copytree(ROOT / directory, self.root / directory)
        for filename in ("Package.swift", "CHANGELOG.md"):
            shutil.copy2(ROOT / filename, self.root / filename)

    def tearDown(self):
        self.scratch.cleanup()

    def mutate_registry(self, update):
        path = self.root / "ai/registry.json"
        registry = json.loads(path.read_text())
        update(registry)
        path.write_text(json.dumps(registry))

    def test_positive(self):
        CHECK.check(self.root)

    def test_missing_document(self):
        (self.root / "ai/INTEGRATION.md").unlink()
        with self.assertRaisesRegex(ValueError, "AI_DOCUMENT"):
            CHECK.check(self.root)

    def test_wrong_version(self):
        self.mutate_registry(lambda r: r.update(version="0.2.0"))
        with self.assertRaisesRegex(ValueError, "AI_VERSION"):
            CHECK.check(self.root)

    def test_invalid_schema(self):
        self.mutate_registry(lambda r: r.update(schemaVersion=2))
        with self.assertRaisesRegex(ValueError, "AI_SCHEMA"):
            CHECK.check(self.root)

    def test_api_drift(self):
        (self.root / "Sources/NativeDesignKit/NativeTokenColor.swift").write_text("enum Removed {}")
        with self.assertRaisesRegex(ValueError, "AI_API"):
            CHECK.check(self.root)

    def test_escaping_link(self):
        (self.root / "ai/README.md").write_text("[bad](../../outside.md)")
        with self.assertRaisesRegex(ValueError, "AI_PATH"):
            CHECK.check(self.root)

    def test_consumer_test_only_import(self):
        (self.root / "ai/examples/consumer/Sources/SamplePalette/SamplePalette.swift").write_text("@testable import NativeDesignKit")
        with self.assertRaisesRegex(ValueError, "AI_EXAMPLE"):
            CHECK.check(self.root)


if __name__ == "__main__":
    unittest.main()
