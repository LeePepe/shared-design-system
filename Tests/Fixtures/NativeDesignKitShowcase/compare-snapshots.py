#!/usr/bin/env python3
"""Compare reviewed PNGs without recording/replacing baselines. Requires Pillow."""
import argparse
import json
from pathlib import Path
from PIL import Image, ImageChops


def compare(baseline, actual, channel_delta, changed_fraction, masks):
    expected = Image.open(baseline).convert('RGBA')
    observed = Image.open(actual).convert('RGBA')
    if expected.size != observed.size:
        return False, {'error': 'dimension mismatch', 'baseline': expected.size, 'actual': observed.size}
    coverage = Image.new('L', expected.size, 255)
    for rectangle in masks:
        if len(rectangle) != 4 or not all(isinstance(v, int) for v in rectangle):
            raise ValueError('Masks must be explicit integer [left,top,right,bottom] rectangles')
        left, top, right, bottom = rectangle
        if not (0 <= left < right <= expected.width and 0 <= top < bottom <= expected.height):
            raise ValueError('Mask lies outside image')
        expected.paste((0, 0, 0, 0), rectangle)
        observed.paste((0, 0, 0, 0), rectangle)
        coverage.paste(0, rectangle)
    difference = ImageChops.difference(expected, observed)
    changed = sum(max(pixel) > channel_delta for pixel in difference.getdata())
    considered = sum(value != 0 for value in coverage.getdata())
    if considered == 0:
        raise ValueError('Masks must leave pixels available for comparison')
    fraction = changed / max(considered, 1)
    return fraction <= changed_fraction, {'changedPixels': changed, 'comparedPixels': considered,
        'changedFraction': fraction, 'allowedFraction': changed_fraction, 'channelDelta': channel_delta}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('baseline', type=Path)
    parser.add_argument('actual', type=Path)
    parser.add_argument('--channel-delta', type=int, required=True)
    parser.add_argument('--max-changed-fraction', type=float, required=True)
    parser.add_argument('--masks', type=Path, help='Reviewed JSON array of pixel rectangles; e.g. spinner region')
    args = parser.parse_args()
    if not (0 <= args.channel_delta <= 255 and 0 <= args.max_changed_fraction <= 1):
        parser.error('Thresholds must be channel delta 0...255 and fraction 0...1')
    masks = json.loads(args.masks.read_text()) if args.masks else []
    passed, result = compare(args.baseline, args.actual, args.channel_delta, args.max_changed_fraction, masks)
    print(json.dumps({'passed': passed, **result}, indent=2))
    raise SystemExit(0 if passed else 1)


if __name__ == '__main__':
    main()
