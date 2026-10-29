import XCTest
import DesignTokens
import SwiftUI
@testable import Strata

final class StrataButtonTests: XCTestCase {
    func testLoadingAndDisabledBlockEveryActionDispatch() {
        for enabled in [false, true] {
            for loading in [false, true] {
                var count = 0
                for _ in 0..<3 {
                    StrataButtonActivation.perform(isEnabled: enabled, isLoading: loading) { count += 1 }
                }
                XCTAssertEqual(count, enabled && !loading ? 3 : 0)
            }
        }
    }

    func testPrimaryUsesProviderContrastPairsForIdleHoverPressAndLoading() throws {
        for brand in DesignTokens.brandIDs.filter({ $0.hasPrefix("strata-") }) {
            for mode in Theme.allCases {
                let theme = try StrataTheme(theme: mode, brand: brand)
                for (pressed, hovered, role) in [(false, false, "primary"), (false, true, "hover"), (true, true, "active")] {
                    let background = try DesignTokens.color("brand.\(brand).\(role)", theme: mode)
                    let pair = try DesignTokens.interactiveAccentPair(brand, theme: mode)
                    let paint = StrataButtonPaint(theme: theme, variant: .primary, isEnabled: true,
                                                  isLoading: false, isPressed: pressed, isHovered: hovered)
                    XCTAssertEqual(paint.foreground, theme.onInteractiveAccent)
                    XCTAssertEqual(paint.fill, StrataTokenColor.color(from: background))
                    XCTAssertGreaterThanOrEqual(try pair.onFill.contrast(with: background), 4.5,
                                               "\(brand)/\(mode)/\(role)")
                }
                let loading = StrataButtonPaint(theme: theme, variant: .primary, isEnabled: false,
                                                isLoading: true, isPressed: true, isHovered: true)
                XCTAssertEqual(loading.foreground, theme.onInteractiveAccent)
                XCTAssertEqual(loading.fill, theme.interactiveAccent, "Loading cannot inherit stale hover or press feedback.")
            }
        }
    }

    func testToolbarVariantUsesSemanticForegroundWithoutCustomChrome() throws {
        for brand in DesignTokens.brandIDs {
            for mode in Theme.allCases {
                let theme = try StrataTheme(theme: mode, brand: brand)
                let toolbar = StrataButtonPaint(theme: theme, variant: .toolbar, isEnabled: true,
                                                isLoading: false, isPressed: true, isHovered: true)
                XCTAssertEqual(toolbar.foreground, theme.accent)
                XCTAssertNil(toolbar.fill)
            }
        }
    }

    func testGhostUsesBrandTextAndDisabledControlsStayReadableWithoutFading() throws {
        let brands = DesignTokens.brandIDs.filter { $0.hasPrefix("strata-") }
        XCTAssertEqual(brands.count, 5, "Five real palettes must exist; no two-brand aliases.")
        for brand in brands {
            for mode in Theme.allCases {
                let theme = try StrataTheme(theme: mode, brand: brand)
                let ghost = StrataButtonPaint(theme: theme, variant: .ghost, isEnabled: true,
                                              isLoading: false, isPressed: false, isHovered: false)
                XCTAssertEqual(ghost.foreground, theme.brandText)
                XCTAssertNil(ghost.fill)
                for variant in [StrataButtonVariant.primary, .secondary, .ghost, .toolbar] {
                    let disabled = StrataButtonPaint(theme: theme, variant: variant, isEnabled: false,
                                                     isLoading: false, isPressed: true, isHovered: true)
                    XCTAssertEqual(disabled.foreground, theme.secondaryForeground)
                    XCTAssertEqual(
                        disabled.fill,
                        variant == .ghost || variant == .toolbar ? nil : theme.surface(.inset)
                    )
                }
            }
        }
    }

    func testBoundedCornersContainMultilineTextThatACapsuleWouldExclude() {
        let rect = CGRect(x: 0, y: 0, width: 272, height: 220)
        let corners = [CGPoint(x: 16, y: 20), CGPoint(x: 256, y: 20),
                       CGPoint(x: 16, y: 200), CGPoint(x: 256, y: 200)]
        XCTAssertTrue(corners.allSatisfy { StrataButtonShape().path(in: rect).contains($0) })
        XCTAssertFalse(corners.allSatisfy { Capsule().path(in: rect).contains($0) })
    }

    @MainActor
    func testBothInitializerFormsRemainAvailableWithCallerOwnedState() throws {
        let theme = try StrataTheme(theme: .light, brand: "ocean")
        _ = StrataButton(theme: theme, variant: .primary, isLoading: false, action: {}) {
            Text("Save")
        } loadingLabel: { Text("Saving…") }
        for surface in [StrataSurfaceStyle.glass, .solid] {
            _ = StrataButton(theme: theme, variant: .secondary, surface: surface, isLoading: true, action: {}) {
                Text("Save")
            } loadingLabel: { Text("Saving…") }
        }
    }
}
