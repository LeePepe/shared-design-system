#!/usr/bin/env python3
"""Prove the removed Native module/product name is unavailable."""
from pathlib import Path
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[3]


def main():
    with tempfile.TemporaryDirectory(prefix="strata-rename-boundary-") as raw:
        fixture = Path(raw)
        (fixture / "Sources/OldConsumer").mkdir(parents=True)
        (fixture / "Package.swift").write_text(
            '// swift-tools-version: 6.0\n'
            'import PackageDescription\n'
            'let package = Package(name: "OldConsumer", dependencies: '
            '[.package(path: "' + str(ROOT).replace("\\", "\\\\") + '")], '
            'targets: [.executableTarget(name: "OldConsumer", dependencies: '
            '[.product(name: "NativeDesignKit", package: "strata-catalog-rename")])])\n')
        (fixture / "Sources/OldConsumer/main.swift").write_text(
            "import NativeDesignKit\n")
        result = subprocess.run(
            ["swift", "build", "--package-path", str(fixture)],
            text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        if result.returncode == 0:
            raise RuntimeError("old NativeDesignKit product unexpectedly compiled")
        if "NativeDesignKit" not in result.stdout:
            raise RuntimeError("failure did not identify the removed product/module")
    print("RENAME_BOUNDARY_OK: old NativeDesignKit product/module is unavailable")


if __name__ == "__main__":
    main()
