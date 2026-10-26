#!/usr/bin/env python3
import os
from pathlib import Path
import shutil
import subprocess
import sys

FIXTURE = Path(__file__).resolve().parent
ROOT = FIXTURE.parents[2]
EVIDENCE = Path(os.environ.get(
    "NATIVE_EVIDENCE_DIR", ROOT / ".build/evidence")).resolve()
DIAGNOSTIC = (
    "Strata is unavailable on watchOS; depend on the DesignTokens "
    "product only."
)


def build(scheme, derived_data):
    return subprocess.run(
        [
            "xcodebuild", "-quiet", "-scheme", scheme,
            "-destination", "generic/platform=watchOS",
            "-derivedDataPath", str(derived_data),
            "CODE_SIGNING_ALLOWED=NO", "build"
        ],
        cwd=FIXTURE,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT
    )


def main():
    EVIDENCE.mkdir(parents=True, exist_ok=True)
    run_root = EVIDENCE / "platform-boundary"
    shutil.rmtree(run_root, ignore_errors=True)
    run_root.mkdir()

    positive = build("DesignTokensWatchConsumer", run_root / "DesignTokens")
    if positive.returncode:
        print(positive.stdout, file=sys.stderr)
        raise RuntimeError("DesignTokens-only watchOS consumer must compile")

    negative = build(
        "StrataWatchConsumer", run_root / "Strata")
    (run_root / "native-negative.log").write_text(negative.stdout)
    if negative.returncode == 0:
        raise RuntimeError("Strata watchOS consumer unexpectedly compiled")
    if DIAGNOSTIC not in negative.stdout:
        print(negative.stdout, file=sys.stderr)
        raise RuntimeError("Strata watchOS diagnostic drift")
    print("WATCH_BOUNDARY_OK: DesignTokens builds; Strata fails with stable diagnostic")


if __name__ == "__main__":
    main()
