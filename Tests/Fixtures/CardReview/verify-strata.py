#!/usr/bin/env python3
"""Check actual Card specimen PNG composites, text roles and solid fallback."""
import argparse
from collections import Counter
import importlib.util
import json
from pathlib import Path
import re


spec = importlib.util.spec_from_file_location("card_material", Path(__file__).with_name("verify-material.py"))
material = importlib.util.module_from_spec(spec)
spec.loader.exec_module(material)

TEXT_ROLES = {
    "specimen-title": "product.strata.text.primary",
    "specimen-metric": "product.strata.text.primary",
    "specimen-detail-action": "brand.{brand}.text",
    "specimen-status": "status.strata.success",
    **{identifier: "product.strata.text.secondary" for identifier in (
        "specimen-body", "specimen-footer", "specimen-item-count", "specimen-context",
        "specimen-stat-title", "specimen-data-context", "specimen-percent",
        "specimen-stat-kind", "specimen-stat-note", "specimen-feedback")},
}
RECT = r"\(([0-9.-]+), ([0-9.-]+), ([0-9.-]+), ([0-9.-]+)\)"


def text_check(png, viewport, rect, expected):
    width, height = viewport
    x, y, w, h = rect
    if w <= 0 or h <= 0 or min(x, y) < 0 or x + w > width + 1 or y + h > height + 1:
        raise ValueError(f"Text is not fully visible in the captured viewport: {rect}")
    scale_x, scale_y = png.width / width, png.height / height
    pixels = Counter()
    glyph = None
    glyph_count = 0
    for py in range(round(y * scale_y), round((y + h) * scale_y)):
        for px in range(round(x * scale_x), round((x + w) * scale_x)):
            color = tuple(png.pixel(px / scale_x, py / scale_y, width, height))
            pixels[color] += 1
            if max(abs(a - b) for a, b in zip(color, expected)) <= 1:
                glyph_count += 1
                if glyph is None:
                    glyph = dict(pixel=[px, py], rgb=color)
    if glyph_count < 4:
        raise ValueError(f"No full glyph matching the expected provider role {expected}: {rect}")
    # Text bounds include the real backing surface. Its dominant encoded RGB is
    # measured from the screenshot; nearby background bins retain subtle material
    # variation and exclude foreground/antialiasing colors. No token fill is
    # substituted for the actual composite.
    dominant, _ = pixels.most_common(1)[0]
    backgrounds = []
    for rgb, count in pixels.most_common(24):
        if count >= 10 and max(abs(a - b) for a, b in zip(rgb, dominant)) <= 8:
            backgrounds.append(dict(rgb=rgb, pixels=count, contrast=material.contrast(expected, rgb)))
    if not backgrounds:
        raise ValueError("No measured backing pixels inside text bounds")
    return dict(frame=rect, full_glyph=glyph, full_glyph_pixels=glyph_count,
                backgrounds=backgrounds, minimum_contrast=min(v["contrast"] for v in backgrounds), target=4.5)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("screenshots", type=Path)
    parser.add_argument("ui_log", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--provider-checkout", type=Path)
    args = parser.parse_args()
    colors, provider = material.provider_colors(args.provider_checkout)
    log = args.ui_log.read_text()
    geometry = {}
    for match in re.finditer(r"CARD_STRATA_GEOMETRY (card-[a-z-]+) width=([0-9.]+) height=([0-9.]+) card=" + RECT + r" stat=" + RECT, log):
        name, *values = match.groups()
        values = list(map(float, values))
        geometry[name] = dict(viewport=values[:2], card=values[2:6], stat=values[6:10])
    text = {}
    for match in re.finditer(r"CARD_STRATA_TEXT (card-[a-z-]+) ([a-z-]+) frame=" + RECT, log):
        name, identifier, *rect = match.groups()
        text.setdefault(name, {})[identifier] = list(map(float, rect))
    cases, failures = [], []
    for family in ("blue", "green", "pink", "yellow", "purple"):
        brand = "strata-" + family
        for mode in ("light", "dark"):
            captures = {}
            for surface in ("solid", "glass", "fallback"):
                name = f"card-{brand}-{mode}-{surface}"
                png = material.PNG(args.screenshots / (name + ".png"))
                captures[surface] = png
                role_results = []
                for identifier, token in TEXT_ROLES.items():
                    token = token.format(brand=brand)
                    rgba = colors[token][mode]
                    if rgba["a"] != 1:
                        raise ValueError("Full-glyph matching requires opaque provider text")
                    expected = [rgba[c] for c in ("r", "g", "b")]
                    result = text_check(png, geometry[name]["viewport"], text[name][identifier], expected)
                    result.update(identifier=identifier, token=token, provider_rgb=expected)
                    role_results.append(result)
                    if result["minimum_contrast"] < result["target"]:
                        failures.append(f"{name}/{identifier}: {result['minimum_contrast']:.6f}:1 < 4.5:1")
                cases.append(dict(name=name, png_sha256=png.sha256, text=role_results))
            reference = geometry[f"card-{brand}-{mode}-solid"]
            points = []
            for key in ("card", "stat"):
                x, y, w, h = reference[key]
                points.extend([(x + w - 8, y + h / 2), (x + 8, y + h - 8)])
            x, y, w, h = reference["card"]
            points.append((x - 8, y + h / 2))
            samples = {surface: [png.pixel(*point, *reference["viewport"]) for point in points]
                       for surface, png in captures.items()}
            delta = max(abs(a - b) for actual, expected in zip(samples["solid"], samples["fallback"])
                        for a, b in zip(actual, expected))
            if delta > 2:
                failures.append(f"{brand}/{mode}: fallback differs from opaque solid roles: {samples}")
            glass_delta = max(abs(a - b) for actual, expected in zip(samples["solid"], samples["glass"])
                              for a, b in zip(actual, expected))
            if glass_delta == 0:
                failures.append(f"{brand}/{mode}: Glass is identical to solid at all surface landmarks")
            cases.append(dict(name=f"{brand}-{mode}-material", native_points=points,
                              surface_samples=samples, fallback_delta=delta, glass_delta=glass_delta))
    system_name = "card-strata-blue-light-system-fallback"
    system = material.PNG(args.screenshots / (system_name + ".png"))
    solid = material.PNG(args.screenshots / "card-strata-blue-light-solid.png")
    reference = geometry[system_name]
    system_samples = []
    for key in ("card", "stat"):
        x, y, w, h = reference[key]
        point = (x + w - 8, y + h / 2)
        observed, expected = [png.pixel(*point, *reference["viewport"]) for png in (system, solid)]
        delta = max(abs(a - b) for a, b in zip(observed, expected))
        system_samples.append(dict(native_point=point, observed=observed, solid=expected, delta=delta))
        if delta > 2:
            failures.append(f"System Reduce Transparency differs from explicit solid: {system_samples[-1]}")
    report = dict(provider=provider, composites=30, text_cases=30 * len(TEXT_ROLES), cases=cases,
                  system_fallback=dict(png_sha256=system.sha256, samples=system_samples), failures=failures)
    args.output.write_text(json.dumps(report, indent=2) + "\n")
    if failures:
        print("CARD_STRATA_FAILED: " + "; ".join(failures))
        return 1
    print(f"CARD_STRATA_OK: 30 actual composites, {report['text_cases']} text-role checks >= 4.5:1, 10 forced and one system fallback")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
