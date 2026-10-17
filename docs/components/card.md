# Card — Strata reading surface

NativeCard remains a noninteractive four-slot container for caller-owned views.
Its API, 24pt continuous radius, 16pt inset and 12pt slot rhythm are unchanged.
The public contract is [ai/components/card.md](../../ai/components/card.md).

The component now requests the shared `.card` surface role. This supplies a
denser reading plane under a 32pt containing region and avoids another blur
when an outer material is already present. Solid and Reduce Transparency use
the same explicit palette and layout with opaque provider fills. NativeCard
contains no local color table, page backdrop or material recipe.

Supporting content uses the distinct secondary text role in Glass, solid and
fallback. The former rule that promoted every requested Glass supporting slot
to primary text is removed together with its uncalibrated background. Semantic
fonts continue to scale; no line limit, fixed text height, gesture wrapper or
new card focus target is introduced.

## Composition and behavior

[CardReview](../../Tests/Fixtures/CardReview/README.md) keeps the original
behavior fixture and adds a faithful visual composition through the actual
component and shared `StrataSpecimen` helper. The caller supplies an icon plate,
context pill, concise title/body, footer/action and a separate synthetic progress
card. The statistic and success roles are independent of the selected brand.
The specimen uses native semantic typography and a 44pt action target.

The package public-import test covers the original two brands and the five
explicit Strata families in both modes and surfaces, plus empty and content-only
slots. UI tests retain actual action/disabled taps, nonactivation of the card,
long-content and Dynamic Type growth, horizontal bounds, slot order, compact
empty-slot equivalence and the original 16 layout combinations. They add the
five-family composition matrix, matching Glass/solid/fallback geometry,
caller-owned detail feedback, a narrower long specimen and accessibility-sized
scroll segments. A separate UI test changes and restores the simulator's real
Reduce Transparency setting and launches without the internal override.

The runtime PNG checker validates actual composite backgrounds and full-glyph
provider colors; generated reports and PNGs remain outside git. Final
verification records both native and public exact DesignTokens `0.2.0` provider
SHAs, without a package or generated-workspace mirror. Historical candidate
evidence retains its original source/provider binding. Every
new source SHA requires fresh captures and review. No screenshot is represented
as VoiceOver, minimum-OS, physical-device or release acceptance.

No behavior assertion, required gate or policy is removed. The legacy visual
checks remain alongside the expanded Strata composition coverage; their
sampling logic is updated only where source/layout or the exact provider pin
requires it.

The legacy behavior fixture keeps its 320pt Card and token-accent backdrop and
places them in a caller-owned 32pt region. Its strict Glass difference greater
than five RGB levels now probes the outer material; the dense inner Card retains
the same-role solid/fallback equality, layout and primary/secondary contrast
checks. The outer fallback must also match solid. This correction tests the
accepted one-outer-blur composition without asking the inner reading plane to
act as a second transparent shell.
