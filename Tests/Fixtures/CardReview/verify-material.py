#!/usr/bin/env python3
"""Check real XCTest screenshot pixels for Card's material and solid fallback."""
import argparse
import json
from pathlib import Path
import re
import struct
import zlib


def pixel(path, point_x, point_y, point_width, point_height):
    data = path.read_bytes()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"Not PNG: {path}")
    chunks = []
    offset = 8
    while offset < len(data):
        length = struct.unpack_from(">I", data, offset)[0]
        kind = data[offset + 4:offset + 8]
        payload = data[offset + 8:offset + 8 + length]
        if kind == b"IHDR":
            width, height, depth, color, compression, filtering, interlace = struct.unpack(">IIBBBBB", payload)
            if depth != 8 or color not in (2, 6) or compression or filtering or interlace:
                raise ValueError("Expected noninterlaced 8-bit RGB/RGBA XCTest PNG")
            channels = 3 if color == 2 else 4
        if kind == b"IDAT":
            chunks.append(payload)
        offset += length + 12
    raw = zlib.decompress(b"".join(chunks))
    stride = width * channels
    x = round(point_x * width / point_width)
    y = round(point_y * height / point_height)
    if not (0 <= x < width and 0 <= y < height):
        raise ValueError("Sample point lies outside the runtime screenshot")
    previous = bytearray(stride)
    for row in range(y + 1):
        start = row * (stride + 1)
        method = raw[start]
        values = bytearray(raw[start + 1:start + stride + 1])
        for i in range(stride):
            left = values[i - channels] if i >= channels else 0
            up = previous[i]
            diagonal = previous[i - channels] if i >= channels else 0
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
        previous = values
    return list(previous[x * channels:x * channels + 3])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("screenshots", type=Path)
    parser.add_argument("ui_log", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    samples = {
        name: tuple(map(float, coordinates))
        for name, *coordinates in re.findall(
            r"CARD_UI_PIXEL (card-[a-z-]+) x=([0-9.]+) y=([0-9.]+) width=([0-9.]+) height=([0-9.]+)",
            args.ui_log.read_text()
        )
    }
    results = []
    for brand in ("ocean", "graphite"):
        for mode in ("light", "dark"):
            colors = {}
            for specimen in ("solid", "glass", "fallback"):
                name = f"card-{brand}-{mode}-{specimen}"
                colors[specimen] = pixel(args.screenshots / (name + ".png"), *samples[name])
            fallback_delta = max(abs(a - b) for a, b in zip(colors["solid"], colors["fallback"]))
            glass_delta = max(abs(a - b) for a, b in zip(colors["solid"], colors["glass"]))
            if fallback_delta > 2:
                raise ValueError(f"{brand}/{mode}: fallback differs from the solid token surface: {colors}")
            if glass_delta <= 5:
                raise ValueError(f"{brand}/{mode}: material does not differ over the token backdrop: {colors}")
            results.append(dict(brand=brand, mode=mode, rgb_bytes=colors,
                                fallback_delta=fallback_delta, glass_delta=glass_delta))
    args.output.write_text(json.dumps({"cases": 4, "failures": 0, "results": results}, indent=2) + "\n")
    print("CARD_MATERIAL_OK: 4 runtime solid / Glass / fallback comparisons")


if __name__ == "__main__":
    main()
