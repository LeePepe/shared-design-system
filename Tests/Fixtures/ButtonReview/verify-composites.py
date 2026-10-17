#!/usr/bin/env python3
"""Check provider glyphs, actual PNG backgrounds and layout for frozen Button evidence."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import subprocess
import zlib


class PNG:
    def __init__(self, path):
        data = path.read_bytes()
        self.sha256 = hashlib.sha256(data).hexdigest()
        if data[:8] != b"\x89PNG\r\n\x1a\n":
            raise ValueError(f"Expected runtime PNG: {path}")
        offset, compressed = 8, bytearray()
        while offset < len(data):
            length = int.from_bytes(data[offset:offset + 4], "big")
            kind, payload = data[offset + 4:offset + 8], data[offset + 8:offset + 8 + length]
            if kind == b"IHDR":
                self.width, self.height, depth, color, _, _, interlace = struct.unpack(">IIBBBBB", payload)
                if depth != 8 or color not in (2, 6) or interlace:
                    raise ValueError("Expected noninterlaced 8-bit RGB/RGBA screenshot")
                self.channels = 3 if color == 2 else 4
            if kind == b"IDAT":
                compressed.extend(payload)
            offset += length + 12
        self.raw = zlib.decompress(compressed)
        self.rows = []

    def pixel(self, x, y):
        if not (0 <= x < self.width and 0 <= y < self.height):
            raise ValueError(f"Pixel outside runtime PNG: {x}, {y}")
        stride, channels = self.width * self.channels, self.channels
        while len(self.rows) <= y:
            start = len(self.rows) * (stride + 1)
            method = self.raw[start]
            row = bytearray(self.raw[start + 1:start + 1 + stride])
            previous = self.rows[-1] if self.rows else bytearray(stride)
            for i in range(stride):
                left = row[i - channels] if i >= channels else 0
                up = previous[i]
                corner = previous[i - channels] if i >= channels else 0
                if method == 0:
                    prediction = 0
                elif method == 1:
                    prediction = left
                elif method == 2:
                    prediction = up
                elif method == 3:
                    prediction = (left + up) // 2
                elif method == 4:
                    p = left + up - corner
                    options = [(abs(p - left), 0, left), (abs(p - up), 1, up), (abs(p - corner), 2, corner)]
                    prediction = min(options)[2]
                else:
                    raise ValueError(f"Unsupported PNG filter {method}")
                row[i] = (row[i] + prediction) % 256
            self.rows.append(row)
        return list(self.rows[y][x * channels:x * channels + 3])


def contrast(a, b):
    def light(rgb):
        values = [v / 255 for v in rgb]
        values = [v / 12.92 if v <= .04045 else ((v + .055) / 1.055) ** 2.4 for v in values]
        return sum(v * weight for v, weight in zip(values, (.2126, .7152, .0722)))
    low, high = sorted((light(a), light(b)))
    return (high + .05) / (low + .05)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("run", type=Path, help="Shared runner .run.json receipt")
    parser.add_argument("log", type=Path, help="Exact runner stdout with BUTTON_COMPOSITE records")
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[3]
    run = json.loads(args.run.read_text())
    head = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=root, text=True).strip()
    if run["dirty"] or run["sha"] != head or run["exit_code"] != 0:
        raise ValueError("Require a passing clean run at the current exact source SHA")
    pin = next(p for p in json.loads((root / "Package.resolved").read_text())["pins"]
               if p["identity"] == "shared-design-tokens")
    checkout = root / ".build/checkouts/shared-design-tokens"
    provider_sha = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=checkout, text=True).strip()
    if provider_sha != pin["state"]["revision"]:
        raise ValueError("Contrast data must match the exact resolved provider revision")
    provider_path = checkout / "dist/resolved.json"
    provider_bytes = provider_path.read_bytes()
    provider = json.loads(provider_bytes)
    if provider["colorSpace"] != "srgb":
        raise ValueError("Expected provider's encoded sRGB data")
    receipts = [json.loads(v) for v in re.findall(r"BUTTON_COMPOSITE (\{[^\n]+\})", args.log.read_text())]
    expected = {f"button-strata-{b}-{m}-{s}" for b in ("blue", "green", "pink", "yellow", "purple")
                for m in ("light", "dark") for s in ("glass", "solid")}
    fallbacks = {"button-strata-purple-dark-reduced-transparency", "button-strata-purple-dark-forced-fallback"}
    if len(receipts) != 22 or {r["name"] for r in receipts} != expected | fallbacks:
        raise ValueError("Require unique runtime geometry for all20 specimens, forced fallback and real transparency fallback")
    results, geometries = {}, []
    for receipt in receipts:
        name = receipt["name"]
        png = PNG(Path(run["screenshots"]) / (name + ".png"))
        scale = png.width / receipt["viewport"][2]
        def pixel(x, y):
            return png.pixel(round(x * scale), round(y * scale))
        samples = []
        for sample in receipt["samples"]:
            rgba = provider["colors"][sample["token"]][receipt["mode"]]
            if rgba["a"] != 1:
                raise ValueError("Text tokens must be opaque")
            rgb = [rgba[c] for c in ("r", "g", "b")]
            x, y, width, height = sample["text"]
            if width <= 0 or height <= 0:
                raise ValueError(f"Missing observed text bounds: {name}/{sample['role']}")
            glyphs = []
            for py in range(round(y * scale), round((y + height) * scale)):
                for px in range(round(x * scale), round((x + width) * scale)):
                    actual = png.pixel(px, py)
                    if max(abs(a - b) for a, b in zip(actual, rgb)) <= 1:
                        glyphs.append([px, py])
            if len(glyphs) < 3:
                raise ValueError(f"No full provider-colored glyphs: {name}/{sample['role']}")
            points = [(x - 2, y + height / 2), (x + width + 2, y + height / 2), (x + width / 2, y - 2)]
            backgrounds = [{"point": [px, py], "rgb": pixel(px, py)} for px, py in points]
            ratios = [contrast(rgb, b["rgb"]) for b in backgrounds]
            if min(ratios) < 4.5:
                raise ValueError(f"Actual composite below4.5: {name}/{sample['role']}: {min(ratios)} {backgrounds}")
            samples.append(dict(role=sample["role"], token=sample["token"], provider_rgb=rgb,
                                full_glyph_count=len(glyphs), example_glyph=glyphs[0],
                                backgrounds=backgrounds, minimum_contrast=min(ratios)))
        results[name] = dict(png_sha256=png.sha256, samples=samples)
        geometry = [s["control"] for s in receipt["samples"] if "control" in s]
        if any(abs(a - b) > .5 for previous in geometries for ra, rb in zip(previous, geometry) for a, b in zip(ra, rb)):
            raise ValueError("Theme/material/fallback changed Button layout")
        geometries.append(geometry)
    for brand in ("blue", "green", "pink", "yellow", "purple"):
        for mode in ("light", "dark"):
            glass = results[f"button-strata-{brand}-{mode}-glass"]["samples"]
            solid = results[f"button-strata-{brand}-{mode}-solid"]["samples"]
            if not any(a["backgrounds"] != b["backgrounds"] for a, b in zip(glass, solid)):
                raise ValueError(f"No observed Glass/solid material difference: {brand}/{mode}")
    solid = results["button-strata-purple-dark-solid"]["samples"]
    for name in fallbacks:
        for a, b in zip(results[name]["samples"], solid):
            for bg_a, bg_b in zip(a["backgrounds"], b["backgrounds"]):
                if max(abs(x - y) for x, y in zip(bg_a["rgb"], bg_b["rgb"])) > 1:
                    raise ValueError(f"{name} background differs from explicit solid")
    report = dict(source_sha=head, provider_sha=provider_sha, provider_version=pin["state"]["version"],
                  provider_data_sha256=hashlib.sha256(provider_bytes).hexdigest(),
                  minimum_contrast=min(s["minimum_contrast"] for r in results.values() for s in r["samples"]),
                  specimens=results, geometry_stable=True, real_fallback_matches_solid=True, forced_fallback_matches_solid=True)
    args.output.write_text(json.dumps(report, indent=2) + "\n")
    print(f"PASS:22 actual composites, stable geometry, forced/system solid fallback; minimum contrast={report['minimum_contrast']:.3f}")


if __name__ == "__main__":
    main()
