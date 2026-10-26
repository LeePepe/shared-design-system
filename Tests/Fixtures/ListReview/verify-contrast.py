#!/usr/bin/env python3
"""Inspect captured List glyphs on actual adjacent composites, using provider colors."""
import argparse
from collections import Counter
import json
from pathlib import Path
import re
import subprocess

import numpy as np
from PIL import Image


def luminance(rgb):
    channels = np.asarray(rgb, dtype=float) / 255
    linear = np.where(channels <= 0.04045, channels / 12.92, ((channels + 0.055) / 1.055) ** 2.4)
    return linear @ np.array([0.2126, 0.7152, 0.0722])


def contrast(first, second):
    a, b = luminance(first), luminance(second)
    return float((max(a, b) + 0.05) / (min(a, b) + 0.05))


def measured_contrast(pixels, frame, target):
    x, y, w, h = frame
    x0, y0 = max(0, int(np.floor(x))), max(0, int(np.floor(y)))
    x1, y1 = min(pixels.shape[1], int(np.ceil(x + w))), min(pixels.shape[0], int(np.ceil(y + h)))
    crop = pixels[y0:y1, x0:x1]
    if not crop.size:
        raise ValueError("Text frame lies outside the captured viewport")
    full = np.max(np.abs(crop.astype(int) - target), axis=2) <= 7
    if np.count_nonzero(full) < 8:
        raise ValueError("No adequate full-coverage glyph pixels match the provider text role")
    samples = []
    # Small overlapping neighborhoods keep the background local to glyphs.
    for top in range(0, crop.shape[0], 24):
        for left in range(0, crop.shape[1], 24):
            mask = full[top:top + 24, left:left + 24]
            if np.count_nonzero(mask) < 3:
                continue
            nearby = pixels[max(0, y0 + top - 5):min(pixels.shape[0], y0 + top + 29),
                            max(0, x0 + left - 5):min(pixels.shape[1], x0 + left + 29)]
            candidates = nearby[np.max(np.abs(nearby.astype(int) - target), axis=2) > 32]
            if not candidates.size:
                raise ValueError("No adjacent background samples")
            background, frequency = Counter(map(tuple, candidates.tolist())).most_common(1)[0]
            if frequency < 4:
                raise ValueError("No stable adjacent background composite")
            tile = crop[top:top + 24, left:left + 24]
            foreground = np.median(tile[mask], axis=0)
            samples.append({"ratio": contrast(foreground, background),
                            "foreground": foreground.tolist(), "background": list(background),
                            "pixels": int(np.count_nonzero(mask))})
    if not samples:
        raise ValueError("No local glyph/background pairs")
    worst = min(samples, key=lambda sample: sample["ratio"])
    return dict(worst, neighborhoods=len(samples), glyphPixels=int(np.count_nonzero(full)))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("run", type=Path, help="External capture directory containing Results.run.json and Results.attachments")
    parser.add_argument("--provider-bare", required=True, type=Path)
    parser.add_argument("--provider-sha", required=True)
    args = parser.parse_args()
    run = json.loads((args.run / "Results.run.json").read_text())
    if run["dirty"]:
        raise ValueError("Final contrast evidence requires a clean captured SHA")
    if run["sha"] != args.provider_sha:
        raise ValueError("Source SHA does not match the capture receipt")
    provider_path = f"{args.provider_sha}:Packages/DesignTokens/dist/resolved.json"
    provider = json.loads(subprocess.check_output(
        ["git", "--git-dir=" + str(args.provider_bare), "show", provider_path], text=True))["colors"]
    raw = args.run / "Results.attachments"
    manifest = json.loads((raw / "manifest.json").read_text())
    attachments = [attachment for test in manifest for attachment in test["attachments"]]
    rows, failures = [], []
    for image in run["attachments"]:
        name = image["name"]
        match = re.fullmatch(r"list-(blue|green|pink|yellow|purple)-(light|dark)-(glass|solid|forced-reduced)", name)
        if not match:
            continue
        mode = match.group(2)
        geometry = [a for a in attachments if re.search(re.escape(name + "-geometry") + r"(?=$|[^a-z0-9-])", a["suggestedHumanReadableName"])]
        if len(geometry) != 1:
            raise ValueError("Missing or ambiguous runtime geometry: " + name)
        frames = json.loads((raw / geometry[0]["exportedFileName"]).read_text())
        pixels = np.asarray(Image.open(args.run / "screenshots" / image["file"]).convert("RGB"))
        sx, sy = pixels.shape[1] / frames["_screen"][2], pixels.shape[0] / frames["_screen"][3]
        dx = frames["_headingAX"][0] - frames["heading"][0]
        dy = frames["_headingAX"][1] - frames["heading"][1]
        required = {"heading", "badge", "context", "instruction", "count", "note"}
        required |= {kind + "-" + identity for kind in ["primary", "secondary"] for identity in ["surface", "color", "type"]}
        required |= {"metadata-color", "metadata-type"}
        if not required <= frames.keys():
            raise ValueError("Missing measured content: " + str(required - frames.keys()))
        required |= {"_section", "_masthead", "selected-marker"}
        selected_row = frames["_row-0"]
        frames["selected-marker"] = [selected_row[0] + selected_row[2] - 76,
                                     selected_row[1] + 12, 64, selected_row[3] - 24]
        for role in sorted(required):
            target_role = "primary" if role in ["heading", "_section", "_masthead"] or role.startswith("primary-") else "secondary"
            rgba = provider["product.strata.text." + target_role][mode]
            if rgba["a"] != 1:
                raise ValueError("Expected opaque text role")
            target = np.array([rgba[channel] for channel in "rgb"])
            x, y, w, h = frames[role]
            ax_coordinates = role.startswith("_") or role == "selected-marker"
            result = measured_contrast(pixels, [(x + (0 if ax_coordinates else dx)) * sx,
                                               (y + (0 if ax_coordinates else dy)) * sy, w * sx, h * sy], target)
            row = dict(image=name, role=role, **result)
            rows.append(row)
            if result["ratio"] < 4.5:
                failures.append(row)
    if len({r["image"] for r in rows}) != 30:
        raise ValueError("Expected all20 material specimens and10 forced fallbacks")
    fallback = []
    for palette in ["blue", "green", "pink", "yellow", "purple"]:
        for mode in ["light", "dark"]:
            solid = np.asarray(Image.open(args.run / "screenshots" / f"list-{palette}-{mode}-solid.png").convert("RGB"))
            reduced = np.asarray(Image.open(args.run / "screenshots" / f"list-{palette}-{mode}-forced-reduced.png").convert("RGB"))
            # Exclude system status/home chrome; compare the unchanged specimen itself.
            height, width = solid.shape[:2]
            region = (slice(int(height * .08), int(height * .75)), slice(0, width))
            changed = int(np.count_nonzero(np.any(solid[region] != reduced[region], axis=2)))
            fallback.append(dict(palette=palette, mode=mode, changedPixels=changed))
            if changed:
                failures.append(dict(image=f"{palette}-{mode}", error="Solid and forced fallback composites differ", changedPixels=changed))
    report = dict(sha=run["sha"], providerSHA=args.provider_sha, candidateOnly=run["candidateOnly"],
                  method="Provider-matched full-coverage glyph pixels vs modal adjacent actual RGB composites in local neighborhoods; antialias edges excluded",
                  minimumRatio=min(row["ratio"] for row in rows), textRegionChecks=len(rows),
                  checks=rows, fallback=fallback, failures=failures)
    (args.run / "contrast.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({key: report[key] for key in ["sha", "providerSHA", "minimumRatio", "textRegionChecks", "failures"]}, indent=2))
    return bool(failures)


if __name__ == "__main__":
    raise SystemExit(main())
