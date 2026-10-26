# Avatar review fixture

Pure SwiftUI synthetic review app, driven by XCTest-only UI automation. Use
the [shared portable runner](../Support/README.md) with `AvatarReview` and new
external result/screenshot directories. The canonical `project.yml` keeps
the local package path, Swift 6 and iOS 15 floor unchanged. No product data,
networking or additional library product is introduced.

Every launch supplies explicit `NDK_BRAND`, `NDK_THEME`, `NDK_SCENARIO` and
`NDK_TEXT_SIZE`. Errors are visible without fallback colors. The local vector
image is a template mask tinted through the caller's inherited token foreground;
it is an image fixture, not screenshot evidence or a local palette.

## Test migration / integrity record

The Strata leaf permits UIKit/AppKit only for numeric color
extraction. All prior Avatar hosting/traversal tests, including the failing
label test, moved to actual SwiftUI app UI tests. `StrataTokenColorTests` is
unchanged. The old native-host AX debug printing and public notification probe
were diagnostics, not assertions or accepted evidence.

| Previous Avatar check | Actual UI replacement | Preserved or stronger assertion |
| --- | --- | --- |
| `testHostedVisualBoundsAreStableAcrossThemesContentAndDisabledEnvironment` | Four `testVisualMatrix…` tests | Every 32/44/64 pt visual has its actual XCUI frame checked in both brands/themes, for initials, symbol, local fill/fit images, empty visual and disabled environment; full viewport containment. |
| `testCallerFillIsClippedToCircleAndDoesNotPaintOutsideVisualBounds` | `testClippingMatchesCircularReferenceIncludingOutsideBounds` | Decoded runtime pixels of oversized 200×120 pt content in a 64 pt avatar centered on 88 pt canvas match a token-filled 64 pt circular reference. Solid interior, corners and exterior match exactly; only the two-physical-pixel antialias rim permits a ≤3/255 channel difference. |
| `testAccessibilityExposesOnlyTheCallerLabelAndImageTrait` (failed native-host AX traversal) | `testCallerLabelIsOneImageAndDecorativeDescendantsAreHidden` | Each of 18 visuals exposes exactly one image with the exact caller label, no descendants and no button role; redundant initials/symbol/image labels remain absent, including the empty visual. |
| `testAccessibilityDynamicTypeRetainsFixedAvatarVisual` | `testNarrowTextGrowsWhileAllAvatarVisualBoundsStayFixed` | Actual iOS large/accessibility2/accessibility5 environments retain all three fixed visual sizes; adjacent full ordinary text grows at accessibility2 within a 280 pt board, stays separate from the avatar and remains onscreen. |
| `testRealSwiftUIAvatarScreenshots` / `StrataSnapshot.capture` | Four `testVisualMatrix…` tests plus narrow/clipping tests | Six real app screenshots are kept in xcresult and exported unchanged by explicit manifest names; UIKit/AppKit hosting/windows are absent. |

`testCallerContentUpdatesAndButtonOwnsActionAndDisabledState` additionally
checks caller-owned content/label updates without size changes, no action from
the unwrapped avatar, native Button composition with a 44 pt target, real action
dispatch, disabled coordinate taps blocked, and re-enabled dispatch.

No assertions are waived or skipped and no gate/policy changes accompany this
migration. Pixel comparison checks the full clipping image, stronger than
the prior three color probes. PNG decoding uses Foundation DEFLATE and the
standard PNG scanline filters; XCTest is the UI test's only import. Actual and
reference crops are retained in xcresult alongside the full screenshot. A
half-point XCUI frame tolerance accounts for
floating point edge subtraction, preserving exact nominal sizes.

These tests establish iOS simulator runtime evidence, not VoiceOver speech,
macOS rendering, physical devices, minimum OS or live keyboard/focus behavior.
