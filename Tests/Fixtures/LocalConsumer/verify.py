#!/usr/bin/env python3
import json
import os
from pathlib import Path
import subprocess

FIXTURE = Path(__file__).resolve().parent
ROOT = FIXTURE.parents[2]
EXPECTED_MARKER = "PASS local DesignTokens and Strata consumer"


def main(run=subprocess.run):
    evidence_root = Path(os.environ.get(
        "NATIVE_EVIDENCE_DIR", ROOT / ".build/evidence")).resolve()
    evidence = evidence_root / "local-consumer"
    evidence.mkdir(parents=True, exist_ok=True)
    receipt = {
        "source": {
            "kind": "local-path",
            "publiclyResolvable": False,
            "revision": None,
        },
        "selectedProducts": ["DesignTokens", "Strata"],
        "commands": [],
        "status": "failed",
    }
    command = ["swift", "run", "--package-path", str(FIXTURE), "LocalConsumer"]
    command_receipt = {
        "argv": command,
        "exitStatus": None,
        "log": "swift-run.log",
    }
    receipt["commands"].append(command_receipt)
    receipt_path = evidence / "receipt.json"

    def persist():
        receipt_path.write_text(
            json.dumps(receipt, indent=2, sort_keys=True) + "\n",
            encoding="utf-8")

    persist()
    try:
        result = run(
            command, cwd=ROOT, text=True, stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT)
        command_receipt["exitStatus"] = result.returncode
        (evidence / "swift-run.log").write_text(
            result.stdout, encoding="utf-8")
        if result.returncode:
            raise RuntimeError("local dual-product consumer failed")
        if EXPECTED_MARKER not in result.stdout.splitlines():
            raise RuntimeError("local dual-product consumer output drift")
        receipt["status"] = "passed"
        persist()
    except BaseException as error:
        receipt["status"] = "failed"
        command_receipt["error"] = str(error)
        persist()
        raise
    print(f"LOCAL_CONSUMER_OK: receipt={evidence / 'receipt.json'}; "
          "local path only, no public revision claimed")


if __name__ == "__main__":
    main()
