#!/usr/bin/env python3
"""Check real XCTest PNG material, solid fallback and composited text contrast."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import subprocess
import zlib


class PNG:
    """Minimal stdlib RGB/RGBA PNG reader; decode each required row only once."""

    def __init__(self, path):
        data = path.read_bytes()
        if data[:8] != b"\x89PNG\r\n\x1a\n":
            raise ValueError(f"Not PNG: {path}")
        self.sha256 = hashlib.sha256(data).hexdigest()
        chunks = []
        offset = 8
        while offset < len(data):
            length = struct.unpack_from(">I", data, offset)[0]
            kind = data[offset + 4:offset + 8]
            payload = data[offset + 8:offset + 8 + length]
            if kind == b"IHDR":
                self.width, self.height, depth, color, compression, filtering, interlace = struct.unpack(">IIBBBBB", payload)
                if depth != 8 or color not in (2, 6) or compression or filtering or interlace:
                    raise ValueError("Expected noninterlaced 8-bit RGB/RGBA XCTest PNG")
                self.channels = 3 if color == 2 else 4
            if kind == b"IDAT":
                chunks.append(payload)
            offset += length + 12
        self.raw = zlib.decompress(b"".join(chunks))
        self.rows = []

    def pixel(self, point_x, point_y, point_width, point_height):
        x = round(point_x * self.width / point_width)
        y = round(point_y * self.height / point_height)
        if not (0 <= x < self.width and 0 <= y < self.height):
            raise ValueError("Sample point lies outside the runtime screenshot")
        stride = self.width * self.channels
        while len(self.rows) <= y:
            start = len(self.rows) * (stride + 1)
            method = self.raw[start]
            values = bytearray(self.raw[start + 1:start + stride + 1])
            previous = self.rows[-1] if self.rows else bytearray(stride)
            for i in range(stride):
                left = values[i - self.channels] if i >= self.channels else 0
                up = previous[i]
                diagonal = previous[i - self.channels] if i >= self.channels else 0
                if method == 0:
                    predictor = 0
                elif method == 1:
                    predictor = left
                elif method == 2:
                    predictor = up
                elif method == 3:
                    predictor = (left + up) // 2
                elif method == 4:
                    estimate = left + up - diagonal
                    distances = [abs(estimate - v) for v in (left, up, diagonal)]
                    predictor = (left, up, diagonal)[distances.index(min(distances))]
                else:
                    raise ValueError(f"Unsupported PNG filter: {method}")
                values[i] = (values[i] + predictor) % 256
            self.rows.append(values)
        return list(self.rows[y][x * self.channels:x * self.channels + 3])


def contrast(foreground, background):
    def luminance(rgb):
        channels = [v / 255 for v in rgb]
        linear = [v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4 for v in channels]
        return sum(a * b for a, b in zip(linear, (0.2126, 0.7152, 0.0722)))
    a, b = sorted((luminance(foreground), luminance(background)))
    return (b + 0.05) / (a + 0.05)


# NativeCardBehaviorFixture's unchanged four-slot, large-text specimen, measured
# in native points on the 402x874 iPhone fixture. Offsets use CARD_UI_PIXEL's
# runtime anchor (Card.maxX - 8, Card.midY), rather than PNG pixel dimensions.
# Primary: fully covered last "d" in "caller-owned"; auxiliary: full glyph in
# "meaning". Background points are adjacent untextured material, including the
# right edge over the accent backdrop. These points also apply to the original
# dev2 capture, so the regression checker can reject its actual low contrast.
TEXT_SAMPLES = {
    "primary": {"glyph": (-30, -60), "backgrounds": [(-28, -62), (-18, -62), (0, -60)]},
    "auxiliary": {"glyph": (-18, -7), "backgrounds": [(-48, -7), (-28, -7), (0, 0)]},
}


def provider_colors(checkout=None):
    repo = Path(__file__).resolve().parents[3]
    pin = next(pin for pin in json.loads((repo / "Package.resolved").read_text())["pins"]
               if pin["identity"] == "shared-design-tokens")
    checkout = checkout or repo / ".build/checkouts/shared-design-tokens"
    revision = subprocess.check_output(["git", "-C", str(checkout), "rev-parse", "HEAD"], text=True).strip()
    exact = re.search(r'exact:\s*"([^"]+)"', (repo / "Package.swift").read_text())
    if not exact or pin["state"]["version"] != exact[1] or revision != pin["state"]["revision"]:
        raise ValueError("Contrast colors must come from the exact manifest and lockfile's Tokens checkout")
    path = checkout / "dist/resolved.json"
    data = path.read_bytes()
    provider = json.loads(data)
    if provider["colorSpace"] != "srgb":
        raise ValueError("Expected pinned provider's encoded sRGB bytes")
    return provider["colors"], dict(path=str(path), version=pin["state"]["version"],
                                   revision=revision, sha256=hashlib.sha256(data).hexdigest())


def text_contrast(png, anchor, mode, colors):
    x, y, width, height = anchor
    candidates = {}
    for token in ("product.text.primary", "product.text.secondary"):
        rgba = colors[token][mode]
        if rgba["a"] != 1:
            raise ValueError("Full-glyph token matching requires opaque provider text colors")
        candidates[token] = [rgba[c] for c in ("r", "g", "b")]
    results = []
    for role, points in TEXT_SAMPLES.items():
        def sample(offset):
            point = [x + offset[0], y + offset[1]]
            return dict(native_point=point, rgb=png.pixel(*point, width, height))
        glyph = sample(points["glyph"])
        matches = [token for token, rgb in candidates.items()
                   if max(abs(a - b) for a, b in zip(rgb, glyph["rgb"])) <= 1]
        if len(matches) != 1:
            raise ValueError(f"{role}: sample is not a full glyph from a pinned provider text token: {glyph}")
        expected = "product.text.primary" if role == "primary" else "product.text.secondary"
        if matches != [expected]:
            raise ValueError(f"{role}: expected distinct {expected}, observed {matches}")
        backgrounds = [sample(offset) for offset in points["backgrounds"]]
        for background in backgrounds:
            background["contrast"] = contrast(glyph["rgb"], background["rgb"])
        results.append(dict(role=role, observed_token=matches[0], provider_rgb=candidates[matches[0]],
                            glyph=glyph, backgrounds=backgrounds,
                            minimum_contrast=min(v["contrast"] for v in backgrounds), target=4.5))
    return results


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("screenshots", type=Path)
    parser.add_argument("ui_log", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--provider-checkout", type=Path)
    args = parser.parse_args()
    colors, provider = provider_colors(args.provider_checkout)
    samples = {
        name: tuple(map(float, coordinates))
        for name, *coordinates in re.findall(
            r"CARD_UI_PIXEL (card-[a-z-]+) x=([0-9.]+) y=([0-9.]+) width=([0-9.]+) height=([0-9.]+)",
            args.ui_log.read_text()
        )
    }
    outer_samples = {
        name: tuple(map(float, coordinates))
        for name, *coordinates in re.findall(
            r"CARD_UI_OUTER_PIXEL (card-[a-z-]+) x=([0-9.]+) y=([0-9.]+) width=([0-9.]+) height=([0-9.]+)",
            args.ui_log.read_text()
        )
    }
    results = []
    failures = []
    for brand in ("ocean", "graphite"):
        for mode in ("light", "dark"):
            material_colors = {}
            outer_colors = {}
            captures = {}
            for specimen in ("solid", "glass", "fallback"):
                name = f"card-{brand}-{mode}-{specimen}"
                captures[specimen] = PNG(args.screenshots / (name + ".png"))
                material_colors[specimen] = captures[specimen].pixel(*samples[name])
                outer_colors[specimen] = captures[specimen].pixel(*outer_samples[name])
            fallback_delta = max(abs(a - b) for a, b in zip(material_colors["solid"], material_colors["fallback"]))
            outer_fallback_delta = max(abs(a - b) for a, b in zip(outer_colors["solid"], outer_colors["fallback"]))
            # Strata assigns the one material to the outer region. The inner
            # Card stays dense; it must retain its same-role opaque fallback
            # and actual primary/secondary contrast rather than another blur.
            glass_delta = max(abs(a - b) for a, b in zip(outer_colors["solid"], outer_colors["glass"]))
            inner_glass_delta = max(abs(a - b) for a, b in zip(material_colors["solid"], material_colors["glass"]))
            if fallback_delta > 2:
                failures.append(f"{brand}/{mode}: fallback differs from the solid token surface: {material_colors}")
            if outer_fallback_delta > 2:
                failures.append(f"{brand}/{mode}: outer fallback differs from the solid token surface: {outer_colors}")
            if glass_delta <= 5:
                failures.append(f"{brand}/{mode}: outer material does not differ over the token backdrop: {outer_colors}")
            text = text_contrast(captures["glass"], samples[f"card-{brand}-{mode}-glass"], mode, colors)
            for role in text:
                if role["minimum_contrast"] < role["target"]:
                    failures.append(f"{brand}/{mode}/{role['role']}: {role['minimum_contrast']:.6f}:1 < 4.5:1")
            results.append(dict(brand=brand, mode=mode, rgb_bytes=material_colors,
                                outer_rgb_bytes=outer_colors, fallback_delta=fallback_delta,
                                outer_fallback_delta=outer_fallback_delta, glass_delta=glass_delta,
                                inner_glass_delta=inner_glass_delta, text_contrast=text,
                                png_sha256={key: value.sha256 for key, value in captures.items()}))
    report = dict(material_cases=4, contrast_cases=8, failures=failures, provider=provider,
                  sampling_source="NativeCardBehaviorFixture four-slot/large; offsets from CARD_UI_PIXEL runtime Card anchor",
                  material_sampling_source="CARD_UI_OUTER_PIXEL runtime region anchor; one outer blur, dense inner Card",
                  sample_offsets_native_points=TEXT_SAMPLES, results=results)
    args.output.write_text(json.dumps(report, indent=2) + "\n")
    if failures:
        print("CARD_PIXEL_FAILED: " + "; ".join(failures))
        return 1
    print("CARD_PIXEL_OK: 4 outer Glass differences >5; 8 inner/outer fallback comparisons; 8 inner primary/auxiliary contrast checks >= 4.5:1")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
