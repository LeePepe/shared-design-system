# NativeProgressBar (unreleased)

Native SwiftUI linear progress in the unreleased [Strata rebuild](../COMPONENTS.md).
HeroUI informs inventory only; no implementation is copied. This API is absent
from the color-only NativeDesignKit 0.3.0 release.

```swift
public struct NativeProgressBar<Label: View, CurrentValueLabel: View>: View {
    public init(theme: NativeDesignTheme,
                value: Double?, total: Double,
                @ViewBuilder label: () -> Label,
                @ViewBuilder currentValueLabel: () -> CurrentValueLabel)
}
```

Every argument is required. Pass an explicitly resolved `NativeDesignTheme`
with provider brand `ocean` or `graphite`; theme construction propagates token
errors unchanged. The released color bridge, exact DesignTokens 0.1.1 pin,
Swift 6 language mode and iOS 15/macOS 12 declarations remain unchanged.

`nil` means indeterminate; otherwise progress is determinate. `total` must be
finite and strictly positive in both modes, and a non-nil value must be finite.
Violations fail a precondition; NaN/infinity are never silently rewritten.
Finite values below zero clamp to zero and values above total clamp to total.
Validate untrusted input before constructing the view. The caller must format
matching current-value text for the normalized range; the component does not
parse or rewrite the builder's content.

```swift
NativeProgressBar(theme: theme, value: completedUnits, total: totalUnits) {
    Text("Preparing files")
} currentValueLabel: {
    Text(formattedProgress) // Caller-owned, localized and formatted.
}

NativeProgressBar(theme: theme, value: nil, total: 1) {
    Text("Preparing files")
} currentValueLabel: {
    Text("Waiting for the next update…")
}
```

The visible label and current-value content stack vertically with semantic
fonts and unconstrained text height. Supply readable current-value text in all
states so color and animation are not the only progress cues. The actual
SwiftUI `ProgressView` uses `.linear`, the token accent tint and a token neutral
surface behind the native track. Native track rendering remains platform
owned. No per-control glass, custom animation, timer, task, networking or
loading engine is added. A Reduce Motion request introduces no custom motion;
the component does not claim to stop SwiftUI's native indeterminate animation.

An explicit SwiftUI accessibility representation uses an automatic native
`ProgressView` with the caller label and exposes the current-value builder as
readable content. This preserves the native progress role/name when a platform's
visual `.linear` style omits indeterminate semantics, without announcing a
fabricated percentage. The visual linear track can be absent for nil progress
on a platform; a neutral token rail and caller waiting text remain visible.
Native accessibility distinguishes determinate progress indicators from active
indeterminate activity indicators. This is a
read-only indicator: it adds no action, selection, binding or keyboard target.
Caller changes to value/total rebuild native progress; no state is stored. The
same label/current-value content reserves the same footprint across zero,
middle, complete and indeterminate states. Different text may grow naturally;
there is no fixed text height or truncation policy. Caller builders should
contain descriptive content rather than interactive controls.

Package tests cover normalization, undefined-input policy and generic public
construction. The standalone `ProgressBarReview` synthetic fixture covers native
accessibility values, caller state changes, state footprint, long narrow text
and accessibility typography. Screenshots come from real XCTest iOS SwiftUI
runtime runs; their exact SHA/platform/test counts belong in the delivery
evidence. The fixture labels its Reduce Motion request and reports the observed
read-only system environment separately; it does not change the preference.
System Reduce Motion enabled remains separate evidence. No VoiceOver session, hardware, minimum-OS or macOS
visual acceptance is inferred.

Rollback removes these call sites before restoring a previously reviewed
package revision. No library-owned data or persistence needs migration.
