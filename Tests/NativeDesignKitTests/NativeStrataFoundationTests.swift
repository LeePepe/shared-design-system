import DesignTokens
import SwiftUI
import XCTest
@testable import NativeDesignKit

final class NativeStrataFoundationTests: XCTestCase {
    func testFiveExplicitFamiliesResolveDistinctSurfacesAndBrandStates() throws {
        for family in ["blue", "green", "pink", "yellow", "purple"] {
            for mode in [Theme.light, .dark, .light] {
                let theme = try NativeDesignTheme(theme: mode, brand: "strata-" + family)
                for (role, id) in [(NativeSurfaceRole.region, "region"), (.card, "card"), (.inset, "inset"), (.hover, "hover"), (.selected, "selected")] {
                    XCTAssertEqual(theme.surface(role), try NativeTokenColor.resolve("product.strata.\(family).surface.\(id)", theme: mode))
                }
                let prefix = "brand.strata-\(family)."
                for (actual, id) in [(theme.brandSeed, "seed"), (theme.brandSeedInk, "seed-ink"), (theme.brandText, "text"), (theme.accentHover, "hover"), (theme.accentActive, "active"), (theme.accentSubtle, "subtle")] {
                    XCTAssertEqual(actual, try NativeTokenColor.resolve(prefix + id, theme: mode))
                }
                XCTAssertEqual(theme.success, try NativeTokenColor.resolve("status.strata.success", theme: mode))
                XCTAssertEqual(theme.successSurface, try NativeTokenColor.resolve("status.strata.success-surface", theme: mode))
                XCTAssertEqual(theme.chartPrimary, try NativeTokenColor.resolve("product.strata.chart.primary", theme: mode))
                XCTAssertEqual(theme.material.panel, try NativeTokenColor.resolve("product.strata.\(family).material.panel", theme: mode))
            }
        }
    }

    func testNestedGlassUsesOneBlurAndReadingPlaneKeepsItsFill() {
        let outer = NativeSurfaceTreatment(style: .glass, role: .region, reduceTransparency: false, materialAncestor: false)
        let inner = NativeSurfaceTreatment(style: .glass, role: .card, reduceTransparency: false, materialAncestor: true)
        XCTAssertTrue(outer.blur)
        XCTAssertTrue(inner.glass)
        XCTAssertFalse(inner.blur)
        XCTAssertTrue(inner.decoration)
        for role in [NativeSurfaceRole.inset, .hover, .selected] {
            let control = NativeSurfaceTreatment(style: .glass, role: role, reduceTransparency: false, materialAncestor: true)
            XCTAssertFalse(control.glass)
            XCTAssertFalse(control.blur)
            XCTAssertFalse(control.decoration)
        }
    }

    func testTransparencyFallbackAndExplicitSolidHaveIdenticalTreatment() {
        for role in [NativeSurfaceRole.region, .card, .inset, .hover, .selected] {
            let fallback = NativeSurfaceTreatment(style: .glass, role: role, reduceTransparency: true, materialAncestor: false)
            let solid = NativeSurfaceTreatment(style: .solid, role: role, reduceTransparency: false, materialAncestor: false)
            XCTAssertEqual(fallback, solid)
            XCTAssertFalse(fallback.blur)
            XCTAssertFalse(fallback.decoration)
        }
    }

    func testMissingStrataColorPropagatesExactErrorWithoutLegacyFallback() {
        let expected = TokenError.unknownToken("injected-strata-role")
        XCTAssertThrowsError(try NativeDesignTheme(theme: .dark, brand: "strata-purple", color: { id, _ in
            XCTAssertEqual(id, "product.strata.purple.surface.page")
            throw expected
        }, brandColor: { brand, role, mode in
            NativeTokenColor.color(from: try DesignTokens.brandColor(brand, role: role, theme: mode))
        })) { XCTAssertEqual($0 as? TokenError, expected) }
    }
    func testLegacyDenseReadingPlaneKeepsSecondaryContrastOnExtremeBackdrops() throws {
        for mode in Theme.allCases {
            let base = try DesignTokens.color("product.surface.raised", theme: mode)
            let text = try DesignTokens.color("product.text.secondary", theme: mode)
            let alpha = NativeSurfaceTreatment.legacyReadingOpacity
            for backdrop in [0.0, 255.0] {
                let composite = try RGBA(
                    red: Int((Double(base.r) * alpha + backdrop * (1 - alpha)).rounded()),
                    green: Int((Double(base.g) * alpha + backdrop * (1 - alpha)).rounded()),
                    blue: Int((Double(base.b) * alpha + backdrop * (1 - alpha)).rounded()))
                XCTAssertGreaterThanOrEqual(try text.contrast(with: composite), 4.5)
            }
        }
    }

}
