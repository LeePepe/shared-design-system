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
}
