#!/usr/bin/env python3
"""Focused command-contract and real-fixture tests for swift-package.sh."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import textwrap
import unittest

ROOT = Path(__file__).resolve().parents[2]
HELPER = ROOT / "scripts/ci/swift-package.sh"
FIXTURE = ROOT / "scripts/ci/fixtures/swift-package"


def enumeration(*targets):
    return {
        "errors": [],
        "values": [{
            "kind": "plan",
            "name": "Fixture-Package",
            "children": [{
                "kind": "target",
                "name": target,
                "children": [{
                    "kind": "class",
                    "name": target,
                    "children": [{"kind": "test", "name": "testExecutes()"}],
                }],
            } for target in targets],
        }],
    }


class SchemeSelectionTests(unittest.TestCase):
    def setUp(self):
        self.scratch = tempfile.TemporaryDirectory(prefix="swift-package-test-")
        self.root = Path(self.scratch.name)
        (self.root / "Package.swift").write_text("// fixture\n", encoding="utf-8")
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.log = self.root / "xcodebuild.log"
        self._write_stub("swift", """
            #!/usr/bin/env python3
            import os
            print(os.environ["P190_PACKAGE_JSON"])
        """)
        self._write_stub("xcrun", """
            #!/usr/bin/env python3
            import json
            from pathlib import Path
            import sys
            if "xcresulttool" in sys.argv:
                result = Path(sys.argv[sys.argv.index("--path") + 1])
                if (result / "fail-extraction").exists():
                    raise SystemExit(1)
                print((result / "tests.json").read_text())
                raise SystemExit(0)
            print(json.dumps({"devices": {
                "com.apple.CoreSimulator.SimRuntime.iOS-18-0": [{
                    "name": "iPhone 16", "udid": "FIXTURE-DEVICE"
                }]
            }}))
        """)
        self._write_stub("xcodebuild", """
            #!/usr/bin/env python3
            import json
            import os
            from pathlib import Path
            import sys

            arguments = sys.argv[1:]
            with Path(os.environ["P190_LOG"]).open("a", encoding="utf-8") as stream:
                stream.write(json.dumps(arguments) + "\\n")
            if "-list" in arguments:
                print(os.environ["P190_SCHEMES_JSON"])
                raise SystemExit(0)
            scheme = arguments[arguments.index("-scheme") + 1]
            if "-enumerate-tests" in arguments:
                spec = json.loads(os.environ["P190_ENUMERATIONS"])[scheme]
                if "result" in spec or "result_raw" in spec:
                    result = Path(arguments[arguments.index(
                        "-resultBundlePath") + 1])
                    result.mkdir()
                    content = spec.get("result_raw",
                                       json.dumps(spec.get("result")))
                    (result / "tests.json").write_text(
                        content, encoding="utf-8")
                    if spec.get("extraction_exit"):
                        (result / "fail-extraction").touch()
                if spec.get("exit"):
                    raise SystemExit(spec["exit"])
                if "raw" in spec:
                    content = spec["raw"]
                elif "output" in spec:
                    content = json.dumps(spec["output"])
                else:
                    raise SystemExit(0)
                output = Path(arguments[arguments.index(
                    "-test-enumeration-output-path") + 1])
                output.write_text(content, encoding="utf-8")
                raise SystemExit(0)
            print(f"executed {scheme}")
        """)

    def tearDown(self):
        self.scratch.cleanup()

    def _write_stub(self, name, content):
        path = self.bin / name
        path.write_text(textwrap.dedent(content).lstrip(), encoding="utf-8")
        path.chmod(0o755)

    def run_helper(self, schemes_json, enumerations, targets=None):
        package = {
            "targets": targets or [
                {"name": "StrataTests", "type": "test"},
                {"name": "DesignTokensTests", "type": "test"},
            ],
        }
        environment = os.environ.copy()
        environment.update({
            "PATH": f"{self.bin}{os.pathsep}{environment['PATH']}",
            "P190_ENUMERATIONS": json.dumps(enumerations),
            "P190_LOG": str(self.log),
            "P190_PACKAGE_JSON": json.dumps(package),
            "P190_SCHEMES_JSON": schemes_json,
            "SWIFT_PACKAGE_ROOT": str(self.root),
        })
        return subprocess.run(
            [HELPER, "ios"],
            text=True,
            capture_output=True,
            env=environment,
        )

    def invocations(self):
        if not self.log.exists():
            return []
        return [
            json.loads(line)
            for line in self.log.read_text(encoding="utf-8").splitlines()
        ]

    def assert_no_final_test(self):
        final_tests = [
            command for command in self.invocations()
            if "test" in command and "-enumerate-tests" not in command
        ]
        self.assertEqual(final_tests, [])

    def test_scheme_order_does_not_change_complete_selection(self):
        cases = [
            ["Product", "Complete", "Incomplete"],
            ["Incomplete", "Complete", "Product"],
        ]
        for schemes in cases:
            with self.subTest(schemes=schemes):
                self.log.unlink(missing_ok=True)
                result = self.run_helper(
                    json.dumps({"workspace": {"name": "Fixture",
                                              "schemes": schemes}}),
                    {
                        "Product": {},
                        "Complete": {"output": enumeration(
                            "DesignTokensTests", "StrataTests")},
                        "Incomplete": {"output": enumeration(
                            "StrataTests")},
                    },
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                final = [
                    command for command in self.invocations()
                    if "test" in command and "-enumerate-tests" not in command
                ]
                self.assertEqual(len(final), 1)
                self.assertEqual(final[0][final[0].index("-scheme") + 1],
                                 "Complete")
                self.assertNotIn("-only-testing", final[0])
                self.assertNotIn("-skip-testing", final[0])

    def test_missing_malformed_and_empty_scheme_metadata_fail_closed(self):
        cases = [
            "{}",
            "{not json",
            json.dumps({"workspace": {"name": "Fixture", "schemes": []}}),
        ]
        for schemes_json in cases:
            with self.subTest(schemes_json=schemes_json):
                self.log.unlink(missing_ok=True)
                result = self.run_helper(schemes_json, {})
                self.assertNotEqual(result.returncode, 0)
                self.assert_no_final_test()

    def test_zero_usable_candidates_fails_closed(self):
        result = self.run_helper(
            json.dumps({"workspace": {"name": "Fixture",
                                      "schemes": ["Missing", "Malformed"]}}),
            {
                "Missing": {},
                "Malformed": {"raw": "{not json"},
            },
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("found 0", result.stderr)
        self.assert_no_final_test()

    def test_two_complete_candidates_are_ambiguous(self):
        complete = enumeration("StrataTests", "DesignTokensTests")
        result = self.run_helper(
            json.dumps({"workspace": {"name": "Fixture",
                                      "schemes": ["CompleteA", "CompleteB"]}}),
            {
                "CompleteA": {"output": complete},
                "CompleteB": {"output": complete},
            },
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("found 2", result.stderr)
        self.assert_no_final_test()

    def test_candidate_omitting_declared_target_is_incomplete(self):
        result = self.run_helper(
            json.dumps({"workspace": {"name": "Fixture",
                                      "schemes": ["Incomplete"]}}),
            {
                "Incomplete": {"output": enumeration(
                    "StrataTests")},
            },
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("found 0", result.stderr)
        self.assert_no_final_test()

    def test_enumeration_errors_fail_closed(self):
        metadata = enumeration("StrataTests", "DesignTokensTests")
        metadata["errors"] = [{"message": "enumeration was incomplete"}]
        result = self.run_helper(
            json.dumps({"workspace": {"name": "Fixture",
                                      "schemes": ["Errored"]}}),
            {"Errored": {"output": metadata}},
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("found 0", result.stderr)
        self.assert_no_final_test()

    def test_target_shaped_data_outside_values_fails_closed(self):
        metadata = enumeration("StrataTests")
        metadata["unexpected"] = enumeration("DesignTokensTests")["values"]
        result = self.run_helper(
            json.dumps({"workspace": {"name": "Fixture",
                                      "schemes": ["Malformed"]}}),
            {"Malformed": {"output": metadata}},
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("found 0", result.stderr)
        self.assert_no_final_test()

    def test_malformed_children_hierarchy_fails_closed(self):
        metadata = enumeration("StrataTests", "DesignTokensTests")
        metadata["values"][0]["children"][0]["children"] = {
            "kind": "test",
            "name": "forgedTest()",
        }
        result = self.run_helper(
            json.dumps({"workspace": {"name": "Fixture",
                                      "schemes": ["Malformed"]}}),
            {"Malformed": {"output": metadata}},
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("found 0", result.stderr)
        self.assert_no_final_test()

    def test_missing_enumeration_uses_complete_result_bundle(self):
        result = self.run_helper(
            json.dumps({"workspace": {"name": "Fixture",
                                      "schemes": ["Complete"]}}),
            {
                "Complete": {"result": {
                    "testNodes": [{
                        "nodeType": "Unit test bundle",
                        "name": "StrataTests",
                        "children": [{
                            "nodeType": "Test Case",
                            "name": "testExecutes()",
                        }],
                    }, {
                        "nodeType": "Unit test bundle",
                        "name": "DesignTokensTests",
                        "children": [{
                            "nodeType": "Test Case",
                            "name": "testExecutes()",
                        }],
                    }],
                }},
            },
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        final = [
            command for command in self.invocations()
            if "test" in command and "-enumerate-tests" not in command
        ]
        self.assertEqual(len(final), 1)
        self.assertEqual(final[0][final[0].index("-scheme") + 1],
                         "Complete")

    def test_partial_result_bundle_fails_closed(self):
        result = self.run_helper(
            json.dumps({"workspace": {"name": "Fixture",
                                      "schemes": ["Incomplete"]}}),
            {
                "Incomplete": {"result": {
                    "testNodes": [{
                        "nodeType": "Unit test bundle",
                        "name": "StrataTests",
                        "children": [{
                            "nodeType": "Test Case",
                            "name": "testExecutes()",
                        }],
                    }, {
                        "nodeType": "Test suite",
                        "name": "DesignTokensTests",
                    }, {
                        "nodeType": "Unit test bundle",
                        "name": "",
                    }, {
                        "nodeType": "Unit test bundle",
                        "name": "DesignTokensTestsExtra",
                    }],
                }},
            },
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("found 0", result.stderr)
        self.assert_no_final_test()

    def test_matching_empty_result_bundle_fails_closed(self):
        result = self.run_helper(
            json.dumps({"workspace": {"name": "Fixture",
                                      "schemes": ["Empty"]}}),
            {
                "Empty": {"result": {
                    "testNodes": [{
                        "nodeType": "Unit test bundle",
                        "name": "StrataTests",
                        "children": [{
                            "nodeType": "Test Case",
                            "name": "testExecutes()",
                        }],
                    }, {
                        "nodeType": "Unit test bundle",
                        "name": "DesignTokensTests",
                        "children": [],
                    }],
                }},
            },
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("found 0", result.stderr)
        self.assert_no_final_test()

    def test_missing_result_bundle_fails_closed(self):
        result = self.run_helper(
            json.dumps({"workspace": {"name": "Fixture",
                                      "schemes": ["Missing"]}}),
            {"Missing": {}},
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("found 0", result.stderr)
        self.assert_no_final_test()

    def test_malformed_or_unextractable_result_bundle_fails_closed(self):
        cases = [
            {"result_raw": "{not json"},
            {
                "result": {
                    "testNodes": [{
                        "nodeType": "Unit test bundle",
                        "name": "StrataTests",
                        "children": [{
                            "nodeType": "Test Case",
                            "name": "testExecutes()",
                        }],
                    }, {
                        "nodeType": "Unit test bundle",
                        "name": "DesignTokensTests",
                        "children": [{
                            "nodeType": "Test Case",
                            "name": "testExecutes()",
                        }],
                    }],
                },
                "extraction_exit": 1,
            },
        ]
        for spec in cases:
            with self.subTest(spec=spec):
                self.log.unlink(missing_ok=True)
                result = self.run_helper(
                    json.dumps({"workspace": {"name": "Fixture",
                                              "schemes": ["Invalid"]}}),
                    {"Invalid": spec},
                )
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("found 0", result.stderr)
                self.assert_no_final_test()

    def test_failed_candidate_cannot_use_complete_result_bundle(self):
        result = self.run_helper(
            json.dumps({"workspace": {"name": "Fixture",
                                      "schemes": ["Failed"]}}),
            {
                "Failed": {
                    "exit": 1,
                    "result": {
                        "testNodes": [{
                            "nodeType": "Unit test bundle",
                            "name": "StrataTests",
                            "children": [{
                                "nodeType": "Test Case",
                                "name": "testExecutes()",
                            }],
                        }, {
                            "nodeType": "Unit test bundle",
                            "name": "DesignTokensTests",
                            "children": [{
                                "nodeType": "Test Case",
                                "name": "testExecutes()",
                            }],
                        }],
                    },
                },
            },
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("found 0", result.stderr)
        self.assert_no_final_test()

    def test_present_enumeration_remains_authoritative(self):
        result = self.run_helper(
            json.dumps({"workspace": {"name": "Fixture",
                                      "schemes": ["Incomplete"]}}),
            {
                "Incomplete": {
                    "output": enumeration("StrataTests"),
                    "result": {
                        "testNodes": [{
                            "nodeType": "Unit test bundle",
                            "name": "StrataTests",
                            "children": [{
                                "nodeType": "Test Case",
                                "name": "testExecutes()",
                            }],
                        }, {
                            "nodeType": "Unit test bundle",
                            "name": "DesignTokensTests",
                            "children": [{
                                "nodeType": "Test Case",
                                "name": "testExecutes()",
                            }],
                        }],
                    },
                },
            },
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("found 0", result.stderr)
        self.assert_no_final_test()


def run_real_fixture():
    with tempfile.TemporaryDirectory(prefix="swift-package-integration-") as scratch:
        package = Path(scratch)
        shutil.copytree(FIXTURE / "Sources", package / "Sources")
        shutil.copytree(FIXTURE / "Tests", package / "Tests")
        shutil.copy2(FIXTURE / "Package.swift.fixture", package / "Package.swift")
        result_bundle = package / "TestResults.xcresult"
        environment = os.environ.copy()
        environment.update({
            "SWIFT_PACKAGE_ROOT": str(package),
            "SWIFT_PACKAGE_RESULT_BUNDLE_PATH": str(result_bundle),
        })
        result = subprocess.run(
            [HELPER, "ios"],
            text=True,
            capture_output=True,
            env=environment,
        )
        if result.returncode:
            sys.stderr.write(result.stdout)
            sys.stderr.write(result.stderr)
            raise RuntimeError("real two-product Swift fixture failed")
        evidence = subprocess.run(
            [
                "xcrun", "xcresulttool", "get", "test-results", "tests",
                "--path", str(result_bundle),
            ],
            text=True,
            capture_output=True,
            check=True,
        )
        observed = {
            node.get("name")
            for node in walk_json(json.loads(evidence.stdout))
            if (
                isinstance(node, dict)
                and node.get("nodeType") == "Unit test bundle"
                and isinstance(node.get("name"), str)
            )
        }
        expected = {"StrataTests", "DesignTokensTests"}
        if not expected.issubset(observed):
            raise RuntimeError(
                f"missing executed test targets: expected {sorted(expected)}, "
                f"observed {sorted(observed)}"
            )
        print(f"[swift-package-test] executed targets: {', '.join(sorted(expected))}")


def walk_json(value):
    yield value
    if isinstance(value, dict):
        for child in value.values():
            yield from walk_json(child)
    elif isinstance(value, list):
        for child in value:
            yield from walk_json(child)


if __name__ == "__main__":
    integration = "--integration" in sys.argv
    if integration:
        sys.argv.remove("--integration")
    outcome = unittest.main(exit=False)
    if not outcome.result.wasSuccessful():
        raise SystemExit(1)
    if integration:
        run_real_fixture()
