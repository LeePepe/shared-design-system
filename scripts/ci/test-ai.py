#!/usr/bin/env python3
"""Positive/negative fixtures for the AI contract, never touching tracked data."""
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
import os

ROOT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location("check_ai", ROOT / "scripts/ci/check-ai.py")
CHECK = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(CHECK)
EXTERNAL_SPEC = importlib.util.spec_from_file_location(
    "external_consumer", ROOT / "scripts/ci/external-consumer.py")
EXTERNAL = importlib.util.module_from_spec(EXTERNAL_SPEC)
EXTERNAL_SPEC.loader.exec_module(EXTERNAL)
LOCAL_SPEC = importlib.util.spec_from_file_location(
    "local_consumer", ROOT / "Tests/Fixtures/LocalConsumer/verify.py")
LOCAL = importlib.util.module_from_spec(LOCAL_SPEC)
LOCAL_SPEC.loader.exec_module(LOCAL)


class ContractTests(unittest.TestCase):
    def setUp(self):
        evidence = Path(os.environ.get("NATIVE_EVIDENCE_DIR", ROOT / ".build/evidence"))
        evidence.mkdir(parents=True, exist_ok=True)
        self.scratch = tempfile.TemporaryDirectory(
            prefix="native-ai-negative-", dir=evidence)
        self.root = Path(self.scratch.name)
        for directory in ("ai", "Sources", "Packages"):
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

    def test_released_requires_changelog_heading(self):
        self.mutate_registry(lambda r: r.update(releaseStatus="released"))
        for content in ("# Changelog\n", "# Changelog\n\nRelease: ## 0.1.0\n",
                        "# Changelog\n\n## 0.1.01\n"):
            with self.subTest(content=content):
                (self.root / "CHANGELOG.md").write_text(content)
                with self.assertRaisesRegex(ValueError, "AI_RELEASE"):
                    CHECK.check(self.root)

    def test_released_rejects_unreleased_changelog_marker(self):
        self.mutate_registry(lambda r: r.update(releaseStatus="released"))
        (self.root / "CHANGELOG.md").write_text(
            "# Changelog\n\n## 0.1.0 — first release\n\nUnreleased — 0.1.0\n")
        with self.assertRaisesRegex(ValueError, "AI_RELEASE"):
            CHECK.check(self.root)

    def test_unreleased_does_not_require_release_heading(self):
        self.mutate_registry(lambda r: r.update(releaseStatus="unreleased"))
        (self.root / "CHANGELOG.md").write_text("# Changelog\n\n## Unreleased — 0.1.0\n")
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

    def test_dependency_rejects_external_edges(self):
        manifest = self.root / "Package.swift"
        original = manifest.read_text()
        for edge in [
            '.package(url: "https://github.com/LeePepe/shared-design-tokens.git", exact: "0.2.0")',
            '.package(url: "https://github.com/example/decoy.git", branch: "main")'
        ]:
            with self.subTest(edge=edge):
                manifest.write_text(original.replace(
                    "    targets: [", f"    dependencies: [{edge}],\n    targets: ["))
                with self.assertRaisesRegex(ValueError, "AI_DEPENDENCY"):
                    CHECK.check(self.root)
        manifest.write_text(original)

    def test_dependency_rejects_missing_product_and_local_edge(self):
        manifest = self.root / "Package.swift"
        original = manifest.read_text()
        for content in [
            original.replace('.library(name: "DesignTokens", targets: ["DesignTokens"]),', ""),
            original.replace('dependencies: ["DesignTokens"]', "dependencies: []", 1)
        ]:
            with self.subTest(content=content):
                manifest.write_text(content)
                with self.assertRaisesRegex(ValueError, "AI_DEPENDENCY"):
                    CHECK.check(self.root)

    def test_rejects_nested_route_drift(self):
        path = self.root / "Packages/DesignTokens/ai/README.md"
        path.write_text(path.read_text().replace("shared-design-system", "other-package"))
        with self.assertRaisesRegex(ValueError, "AI_DESIGN_TOKENS"):
            CHECK.check(self.root)

    def test_rejects_cross_wired_release_unit(self):
        self.mutate_registry(
            lambda r: r["releaseUnits"].update(designTokens="README.md"))
        with self.assertRaisesRegex(ValueError, "AI_SCHEMA"):
            CHECK.check(self.root)

    def test_rejects_watch_boundary_drift(self):
        (self.root / "Sources/NativeDesignKit/PlatformBoundary.swift").write_text("")
        with self.assertRaisesRegex(ValueError, "AI_PLATFORMS"):
            CHECK.check(self.root)

    def test_consumer_test_only_import(self):
        (self.root / "ai/examples/consumer/Sources/SamplePalette/SamplePalette.swift").write_text("@testable import NativeDesignKit")
        with self.assertRaisesRegex(ValueError, "AI_EXAMPLE"):
            CHECK.check(self.root)


class ConsumerHarnessTests(unittest.TestCase):
    def test_public_resolution_failure_remains_false(self):
        receipt = {
            "source": {"publiclyResolvable": False},
            "packageIdentities": [],
        }
        with self.assertRaisesRegex(RuntimeError, "immutable dependency"):
            EXTERNAL.validate_public_resolution(
                receipt,
                {"shared-design-system": {"revision": "b" * 40}},
                "revision",
                "a" * 40)
        self.assertFalse(receipt["source"]["publiclyResolvable"])
        self.assertEqual(receipt["packageIdentities"], [])

    def test_public_resolution_success_becomes_true(self):
        receipt = {
            "source": {"publiclyResolvable": False},
            "packageIdentities": [],
        }
        EXTERNAL.validate_public_resolution(
            receipt,
            {"shared-design-system": {"version": "1.2.3"}},
            "version",
            "1.2.3")
        self.assertTrue(receipt["source"]["publiclyResolvable"])
        self.assertEqual(
            receipt["packageIdentities"], ["shared-design-system"])

    def test_tokens_local_consumer_has_no_native_dependency(self):
        harness = (
            ROOT / "Packages/DesignTokens/scripts/test-swift-local-consumer.mjs"
        ).read_text()
        self.assertNotIn("NativeDesignKit", harness)
        self.assertIn('.product(name: "DesignTokens"', harness)

    def test_local_dual_product_consumer_is_native_owned_and_non_public(self):
        fixture = ROOT / "Tests/Fixtures/LocalConsumer"
        manifest = (fixture / "Package.swift").read_text()
        self.assertIn('.product(name: "DesignTokens"', manifest)
        self.assertIn('.product(name: "NativeDesignKit"', manifest)
        evidence_root = Path(os.environ.get(
            "NATIVE_EVIDENCE_DIR", ROOT / ".build/evidence"))
        evidence_root.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(
                prefix="local-consumer-test-", dir=evidence_root) as scratch:
            evidence = Path(scratch)
            environment = os.environ.copy()
            environment["NATIVE_EVIDENCE_DIR"] = str(evidence)
            result = subprocess.run(
                ["python3", str(fixture / "verify.py")],
                cwd=ROOT, text=True, stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT, env=environment)
            self.assertEqual(result.returncode, 0, result.stdout)
            receipt = json.loads(
                (evidence / "local-consumer/receipt.json").read_text())
        self.assertEqual(receipt["selectedProducts"],
                         ["DesignTokens", "NativeDesignKit"])
        self.assertFalse(receipt["source"]["publiclyResolvable"])
        self.assertIsNone(receipt["source"]["revision"])
        self.assertEqual(receipt["status"], "passed")

    def assert_local_consumer_failure(self, output, returncode, message):
        evidence_root = Path(os.environ.get(
            "NATIVE_EVIDENCE_DIR", ROOT / ".build/evidence"))
        evidence_root.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(
                prefix="local-consumer-negative-", dir=evidence_root) as scratch:
            previous = os.environ.get("NATIVE_EVIDENCE_DIR")
            os.environ["NATIVE_EVIDENCE_DIR"] = scratch
            try:
                def run(*_args, **_kwargs):
                    return subprocess.CompletedProcess(
                        args=[], returncode=returncode, stdout=output)

                with self.assertRaisesRegex(RuntimeError, message):
                    LOCAL.main(run=run)
                receipt = json.loads(
                    (Path(scratch) / "local-consumer/receipt.json").read_text())
            finally:
                if previous is None:
                    os.environ.pop("NATIVE_EVIDENCE_DIR", None)
                else:
                    os.environ["NATIVE_EVIDENCE_DIR"] = previous
        self.assertEqual(receipt["status"], "failed")
        self.assertEqual(receipt["commands"][0]["exitStatus"], returncode)

    def test_local_consumer_zero_exit_without_marker_fails_closed(self):
        self.assert_local_consumer_failure(
            "Build complete!\n", 0, "output drift")

    def test_local_consumer_zero_exit_with_drifted_marker_fails_closed(self):
        self.assert_local_consumer_failure(
            "PASS local DesignTokens and NativeDesignKit consumer (drifted)\n",
            0, "output drift")

    def test_local_consumer_nonzero_exit_persists_failed_receipt(self):
        self.assert_local_consumer_failure(
            "compile failed\n", 1, "consumer failed")

    def test_external_receipt_requires_every_contract_field(self):
        receipt = {
            "repositoryURL": EXTERNAL.REPOSITORY_URL,
            "source": {
                "kind": "revision",
                "value": "a" * 40,
                "publiclyResolvable": True,
            },
            "packageIdentities": ["shared-design-system"],
            "selectedProducts": EXTERNAL.PRODUCTS,
            "contractPaths": [
                {"path": path, "sha256": "0" * 64}
                for path in EXTERNAL.CONTRACT_PATHS
            ],
            "commands": [{"exitStatus": 0}],
            "testCounts": {"executed": 2, "passed": 2, "failed": 0},
            "status": "passed",
        }
        EXTERNAL.validate_success_receipt(receipt)
        for field in (
                "repositoryURL", "packageIdentities", "selectedProducts",
                "contractPaths", "commands", "testCounts"):
            with self.subTest(field=field):
                invalid = dict(receipt)
                invalid.pop(field)
                with self.assertRaisesRegex(
                        RuntimeError, "missing required fields"):
                    EXTERNAL.validate_success_receipt(invalid)

    def test_external_test_count_parser_fails_closed(self):
        self.assertEqual(
            EXTERNAL.parse_test_counts(
                "Executed 2 tests, with 0 failures (0 unexpected)"),
            {"executed": 2, "passed": 2, "failed": 0})
        with self.assertRaisesRegex(RuntimeError, "test counts"):
            EXTERNAL.parse_test_counts("Build complete!")


if __name__ == "__main__":
    unittest.main()
