#!/usr/bin/env python3
"""Check real XCTest native Picker glyphs against the resolved token checkout.

Python standard library only. PNG input must be an unmodified, noninterlaced
8-bit RGB/RGBA screenshot. Unsupported encodings fail rather than being guessed.
"""
import argparse
from collections import Counter
import hashlib
import json
import math
from pathlib import Path
import re
import struct
import subprocess
import sys
import zlib


REPO = Path(__file__).resolve().parents[3]
MARKER = "RADIO_GROUP_CHECKMARK "


def require(condition, message):
    if not condition:
        raise ValueError(message)


def png_rgb(path):
    data = path.read_bytes()
    require(data[:8] == b"\x89PNG\r\n\x1a\n", "Not a PNG screenshot")
    offset, compressed, header, ended = 8, bytearray(), None, False
    while offset < len(data):
        require(offset + 12 <= len(data), "Truncated PNG chunk")
        length = struct.unpack_from(">I", data, offset)[0]
        kind = data[offset + 4:offset + 8]
        payload = data[offset + 8:offset + 8 + length]
        require(offset + length + 12 <= len(data), "Truncated PNG payload")
        crc = struct.unpack_from(">I", data, offset + 8 + length)[0]
        require(zlib.crc32(kind + payload) == crc, "PNG CRC mismatch")
        if kind == b"IHDR":
            require(header is None and offset == 8 and length == 13, "Invalid PNG header")
            header = struct.unpack(">IIBBBBB", payload)
        elif kind == b"IDAT":
            compressed.extend(payload)
        elif kind == b"IEND":
            require(length == 0, "Invalid PNG end")
            ended = True
            break
        elif kind not in (b"PLTE",) and kind[0] & 32 == 0:
            raise ValueError("Unsupported critical PNG chunk")
        offset += length + 12
    require(header is not None and ended, "Incomplete PNG")
    width, height, depth, color, compression, filtering, interlace = header
    require(width > 0 and height > 0, "Empty PNG")
    require(depth == 8 and color in (2, 6) and (compression, filtering, interlace) == (0, 0, 0),
            "Expected noninterlaced 8-bit RGB/RGBA XCTest PNG")
    channels = 3 if color == 2 else 4
    stride = width * channels
    raw = zlib.decompress(compressed)
    require(len(raw) == height * (stride + 1), "Unexpected PNG decoded size")
    rows, previous = [], bytearray(stride)
    for y in range(height):
        start = y * (stride + 1)
        filter_type = raw[start]
        require(filter_type in range(5), "Unsupported PNG row filter")
        row = bytearray(raw[start + 1:start + 1 + stride])
        for x in range(stride):
            left = row[x - channels] if x >= channels else 0
            above = previous[x]
            upper_left = previous[x - channels] if x >= channels else 0
            if filter_type == 1:
                predictor = left
            elif filter_type == 2:
                predictor = above
            elif filter_type == 3:
                predictor = (left + above) // 2
            elif filter_type == 4:
                p = left + above - upper_left
                distances = (abs(p - left), abs(p - above), abs(p - upper_left))
                predictor = (left, above, upper_left)[distances.index(min(distances))]
            else:
                predictor = 0
            row[x] = (row[x] + predictor) & 255
        if channels == 4:
            require(all(alpha == 255 for alpha in row[3::4]), "Screenshot contains translucent pixels")
            rgb = bytes(value for x in range(0, stride, 4) for value in row[x:x + 3])
        else:
            rgb = bytes(row)
        rows.append(rgb)
        previous = row
    return width, height, rows


def token_provider():
    pins = json.loads((REPO / "Package.resolved").read_text())["pins"]
    pin = next(item for item in pins if item["identity"] == "shared-design-tokens")
    require(pin["state"]["version"] == "0.1.1", "Expected the exact DesignTokens 0.1.1 pin")
    checkout = REPO / ".build/checkouts/shared-design-tokens"
    revision = subprocess.check_output(["git", "-C", str(checkout), "rev-parse", "HEAD"], text=True).strip()
    require(revision == pin["state"]["revision"], "Token checkout differs from Package.resolved")
    path = checkout / "tokens/colors.json"
    data = path.read_bytes()
    committed = subprocess.check_output(["git", "-C", str(checkout), "show", "HEAD:tokens/colors.json"])
    require(data == committed, "Token data contains uncommitted changes")
    return json.loads(data), {"path": str(path), "revision": revision, "sha256": hashlib.sha256(data).hexdigest()}


def accent(provider, brand, mode):
    values = {item["id"]: item["values"] for item in provider["tokens"]}
    token = provider["brands"][brand]["accent"]
    visited = set()
    while True:
        require(token not in visited, "Cyclic token reference")
        visited.add(token)
        value = values[token][mode]
        if "ref" not in value:
            require(value["a"] == 1, "Native checkmark test requires an opaque provider accent")
            rgb = tuple(value[channel] for channel in ("r", "g", "b"))
            require(all(type(channel) is int and 0 <= channel <= 255 for channel in rgb), "Invalid provider RGB")
            return rgb
        token = value["ref"]


def geometry(log, legacy):
    if not legacy:
        records = {}
        for line in log.splitlines():
            if line.startswith(MARKER):
                record = json.loads(line[len(MARKER):])
                require(record["name"] not in records, "Duplicate capture geometry")
                records[record["name"]] = record
        return records
    # The original dev2 log predates per-capture telemetry. Its initial actual
    # native tree contains the same full-width option rows used in its matrix.
    # This path is explicit and is used only to prove the historical regression.
    trees = re.findall(r"INITIAL NATIVE PICKER TREE\n(.*?)(?=Path to element:)", log, re.S)
    require(len(trees) == 1, "Expected one original native tree")
    frame = r"\{\{([-\d.]+), ([-\d.]+)\}, \{([-\d.]+), ([-\d.]+)\}\}"
    def extract(pattern):
        match = re.search(pattern, trees[0])
        require(match is not None, "Missing original native window/option coordinates")
        return list(map(float, match.groups()))
    app = extract(r"Window \(Main\), [^\n]*?" + frame)
    selected = extract(r"Button, [^\n]*?" + frame + r", identifier: 'option-balanced-id', [^\n]*Selected")
    unselected = extract(r"Button, [^\n]*?" + frame + r", identifier: 'option-compact-id',")
    return {f"radio-group-{brand}-{mode}": {"app": app, "selected": selected, "unselected": unselected}
            for brand in ("ocean", "graphite") for mode in ("light", "dark")}


def check_image(path, record, expected):
    width, height, rows = png_rgb(path)
    app = record["app"]
    require(len(app) == 4 and all(math.isfinite(v) for v in app), "Invalid app coordinates")
    require(app[:2] == [0, 0] and app[2] > 0 and app[3] > 0, "Expected full app screenshot at zero origin")
    scale = width / app[2]
    require(abs(height - app[3] * scale) <= 1, "Screenshot/app aspect ratio differs")

    def sample(row):
        require(len(row) == 4 and all(math.isfinite(v) for v in row), "Invalid native row coordinates")
        x, y, w, h = row
        # Assert this fixture's full-width-row invariant; never use row width
        # as a substitute for the actual app width when computing PNG scale.
        require(abs(x - app[0]) <= 0.001 and abs(w - app[2]) <= 0.001, "Matrix native row must span the app")
        require(h >= 44 - 0.001 and y >= 0 and y + h <= app[3], "Native row is outside the app")
        rect = [round(v * scale) for v in (x + w * 0.8, y + 2, x + w - 2, y + h - 2)]
        left, top, right, bottom = rect
        require(0 <= left < right <= width and 0 <= top < bottom <= height, "Glyph sample is outside PNG")
        colors, exact = Counter(), set()
        for py in range(top, bottom):
            for px in range(left, right):
                rgb = tuple(rows[py][px * 3:px * 3 + 3])
                colors[rgb] += 1
                if rgb == expected:
                    exact.add((px, py))
        count, largest = len(exact), 0
        while exact:
            pending = [exact.pop()]
            size = 0
            while pending:
                px, py = pending.pop()
                size += 1
                for neighbor in ((px - 1, py), (px + 1, py), (px, py - 1), (px, py + 1)):
                    if neighbor in exact:
                        exact.remove(neighbor)
                        pending.append(neighbor)
            largest = max(largest, size)
        return {"native_row_pt": row, "trailing_region_pixel_rect": rect, "exact_accent_pixels": count,
                "largest_exact_accent_component_pixels": largest,
                "most_common_rgb": [{"rgb": rgb, "pixels": n} for rgb, n in colors.most_common(3)]}

    selected, unselected = sample(record["selected"]), sample(record["unselected"])
    # Require a connected opaque glyph core of >=8 square points, rather than
    # a few incidental matching pixels. The unselected row is a negative control
    # excluding label text/background as the source of those matching pixels.
    minimum = math.ceil(8 * scale * scale)
    passed = selected["largest_exact_accent_component_pixels"] >= minimum and unselected["exact_accent_pixels"] == 0
    return {"passed": passed, "png_size": [width, height], "app_frame_pt": app, "pixels_per_point": scale,
            "expected_provider_rgb": expected, "minimum_connected_accent_pixels": minimum,
            "selected": selected, "unselected": unselected}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--screenshots", required=True, type=Path, help="Unmodified runner-exported PNG directory")
    parser.add_argument("--ui-log", required=True, type=Path, help="Matching complete XCTest run log")
    parser.add_argument("--legacy-tree", action="store_true", help="Explicit historical dev2 native-tree geometry only")
    args = parser.parse_args()
    provider, provider_record = token_provider()
    records = geometry(args.ui_log.read_text(), args.legacy_tree)
    report = {"provider": provider_record, "ui_log_sha256": hashlib.sha256(args.ui_log.read_bytes()).hexdigest(),
              "geometry_source": "original-dev2-native-tree" if args.legacy_tree else "per-capture-native-frames", "checked": []}
    for brand in ("ocean", "graphite"):
        for mode in ("light", "dark"):
            name = f"radio-group-{brand}-{mode}"
            path = args.screenshots / (name + ".png")
            result = {"file": path.name}
            try:
                require(name in records, "Missing this capture's actual native geometry")
                result["sha256"] = hashlib.sha256(path.read_bytes()).hexdigest()
                result.update(check_image(path, records[name], accent(provider, brand, mode)))
            except (ValueError, KeyError, OSError, zlib.error, struct.error) as error:
                result.update(passed=False, error=str(error))
            report["checked"].append(result)
    report["passed"] = sum(item["passed"] for item in report["checked"])
    report["failed"] = len(report["checked"]) - report["passed"]
    print(json.dumps(report, indent=2))
    return 1 if report["failed"] else 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (ValueError, KeyError, OSError, subprocess.CalledProcessError) as error:
        print(f"Checkmark verification failed: {error}", file=sys.stderr)
        raise SystemExit(1)
