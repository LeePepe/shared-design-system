# Native foundations (unreleased)

These APIs are additive to the staged 0.2.0 candidate. They preserve the exact
DesignTokens 0.1.1 dependency and existing Theme/Card behavior. A provider style
release and a separate reviewed exact-version upgrade are still required before
claiming automatic consumption of the new StyleTokens API. No unreleased version
is hidden behind the current dependency pin.

## Explicit style inputs

`NativeControlMetrics(padding:spacing:cornerRadius:minimumHitSize:iconSize:borderWidth:disabledOpacity:)`
and `NativeSurfaceMetrics(cornerRadius:borderWidth:borderOpacity:shadowRadius:shadowX:shadowY:shadowOpacity:)`
are immutable adaptation inputs with no defaults. Supply reviewed style-provider
values in logical points; opacities are in 0...1. Sizes must be finite and
nonnegative; shadow offsets may be negative. Invalid programmer inputs fail a
precondition. These structs are not a second token table or a theme resolver.

`NativeTypography(size:relativeTo:weight:lineSpacing:tracking:monospacedDigits:)`
adapts a validated provider font record to native `Font.TextStyle` and
`Font.Weight`. `lineSpacing` is additional leading (provider line height minus
size), never a fixed-height text box. `Text.nativeTypography(_:)` scales size,
leading and tracking with Dynamic Type and retains tracking on the full declared
OS range. `View.nativeTypography(_:)` applies inherited font and leading; inherited
tracking requires iOS 16/macOS 13. Use the Text overload on older systems when
tracking matters. The caller performs the explicit provider weight/style-name
mapping; native code contains no font-size scale.

```swift
// Values originate from the caller's reviewed style data, not local defaults.
Text(title).nativeTypography(typography).nativeGrowingText()
Button(action: action) { Image(systemName: symbol) }
    .nativeMinimumHitTarget(metrics.minimumHitSize)
```

## Surfaces, focus and platform policy

`View.nativeSurface(theme:metrics:style:)` requires the throwing, explicitly
constructed `NativeDesignTheme` snapshot. `NativeSurfaceStyle` is `.opaque`,
`.glass`, or `.interactiveGlass`. Apply the modifier after padding/layout; reserve
interactive Glass for actual controls. iOS 26/macOS 26 support native Liquid Glass.
Older systems and Reduce Transparency use an opaque raised token surface with
explicit border/shadow metrics. Explicit tint, fill, border, and shadow colors
all use the supplied theme. Errors are resolved before rendering and never caught
or replaced by a fallback color. The system material still follows the OS native
material and accessibility policy; callers should align their appearance with
the explicitly selected theme. Use native `GlassEffectContainer` in an
availability branch when composing nearby related Glass controls.

`View.nativeFocusOutline(theme:focused:cornerRadius:width:)` draws an optional
semantic-info outline from a caller's `FocusState`; it does not capture focus or
replace keyboard behavior. Native controls keep their pressed/disabled/hover and
accessibility semantics. `nativeMinimumHitTarget(_:)` expands layout/hit bounds
without adding a second gesture or accessibility element.

## Layout

- `NativeEqualGrid(columns:spacing:content:)` uses equal flexible lazy columns.
- `NativeAdaptiveGrid(minimumWidth:spacing:content:)` uses native adaptive columns.
- `NativeFlow(items:horizontalSpacing:verticalSpacing:content:)` wraps identifiable
  data in source order. On iOS 16/macOS 13 it uses the Layout protocol, measures
  long items again at the available width, and explicitly places RTL rows.
  On iOS 15/macOS 12 it uses measured native rows. Row changes can recreate child
  view-local state on that legacy route; keep persistent state in caller bindings.
- `NativeFlowLayout(horizontalSpacing:verticalSpacing:layoutDirection:)` is also
  public on iOS 16/macOS 13 for direct ViewBuilder composition. Pass the environment
  direction; the data-based NativeFlow reads it automatically.
- `View.nativeReadableWidth(_:alignment:)` constrains a centered/aligned reading
  column. `nativeGrowingText()` allows unlimited vertical growth.
- `View.nativeKeyboardDismissal(_:)` accepts `.immediately`, `.interactively`, or
  `.never`. Native scrolling supports these on iOS 16/macOS 13; older behavior
  remains unchanged.

Safe areas, aspect ratio, logical leading/trailing alignment, accessibility labels,
values and focus are native SwiftUI APIs. Prefer `safeAreaInset`, `aspectRatio`,
`accessibilityLabel`/`accessibilityValue`, and `FocusState` directly instead of
library aliases. Do not ignore keyboard safe areas or cap Dynamic Type globally.

## Motion and complete accessibility states

`NativeMotionSpec.cubicBezier(duration:x1:y1:x2:y2:)` and
`.spring(response:dampingFraction:blendDuration:)` adapt validated explicit
provider inputs. `.animation(reduceMotion:)` returns nil for Reduce Motion.
`View.nativeMotion(_:value:)` reads that accessibility preference automatically.
There are no implicit duration/curve defaults.

`NativeTransition` supports `.opacity`, `.move(Edge)`, `.scale(CGFloat)`,
`.combined(_:_:)`, and `.asymmetric(insertion:removal:)`.
`.transition(reduceMotion:)` returns identity for Reduce Motion. Pair the
transition with nativeMotion or a transaction using the same reduced-motion
setting; content must be inserted in its complete final state.

`NativeInterpolation` clamps scalar/progress input and defines invalid/empty
totals as zero. `NativeAnimationProgress(value:content:)` is an Animatable view
that passes the currently interpolated Double to caller rendering, including
formatted numbers or Shape.trim paths; it creates no timer. Its raw value is not
clamped so numeric ranges remain general; use clampedProgress for path/progress.

`NativeStaggerSchedule(count:interval:)` uses seconds, not display frames.
An interval of zero reveals synchronously. `NativeMotionSequence` is a MainActor
ObservableObject with read-only published `visibleCount`, `cancel()`, and
`replay(schedule:reduceMotion:) async`. Caller owns its `.task` lifetime. Replay
invalidates previous runs, cancellation prevents stale publication, and reduced
motion immediately reveals every item. Supply the motion preference as the task
identity when it can change during playback:

```swift
.task(id: reduceMotion) {
    await sequence.replay(schedule: schedule, reduceMotion: reduceMotion)
}
```

Animated content keeps stable accessibility labels/values from caller state;
never expose each intermediate digit as separate accessibility elements. This
implementation's unit tests exercise layout packing, endpoint behavior, replay,
cancellation and complete reduced-motion states. They do not establish minimum-OS
runtime, VoiceOver, pixel-regression, or external-consumer release acceptance.
