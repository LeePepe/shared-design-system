import DesignTokens
import SwiftUI
import XCTest
@testable import Strata

final class StrataFoundationTests: XCTestCase {
    func testComponentMetricsRetainsResolvedValues() throws {
        let metrics = try StrataComponentMetrics(
            dimension: { _ in 48 },
            spacing: { id in
                switch id {
                case "spacing.xs": return 5
                case "spacing.sm": return 7
                case "spacing.md": return 9
                case "spacing.lg": return 11
                case "spacing.xl": return 13
                default: XCTFail("Unexpected spacing token: \(id)"); return 0
                }
            },
            radius: { id in id == "radius.medium" ? 15 : 17 },
            border: { _ in 2 }
        )

        XCTAssertEqual(metrics.minimumHit, 48)
        XCTAssertEqual(metrics.spacingXS, 5)
        XCTAssertEqual(metrics.spacingSM, 7)
        XCTAssertEqual(metrics.spacingMD, 9)
        XCTAssertEqual(metrics.spacingLG, 11)
        XCTAssertEqual(metrics.spacingXL, 13)
        XCTAssertEqual(metrics.controlRadius, 20)
        XCTAssertEqual(metrics.cardRadius, 22)
        XCTAssertEqual(metrics.verticalItemWidth, 68)
        XCTAssertEqual(metrics.borderRegular, 2)
    }

    func testComponentMetricsResolvesCompactCellRadius() throws {
        let defaultMetrics = try StrataComponentMetrics()
        XCTAssertEqual(defaultMetrics.compactCellRadius, 6)

        let customMetrics = try StrataComponentMetrics(
            dimension: { _ in 44 },
            spacing: { _ in 0 },
            radius: { id in id == "radius.small" ? 6 : 12 },
            border: { _ in 1 }
        )
        XCTAssertEqual(customMetrics.compactCellRadius, 6)
    }

    func testComponentMetricsPropagatesTokenErrorsUnchanged() {
        let expected = StyleTokenError.unknownToken("dimension.failure")

        XCTAssertThrowsError(
            try StrataComponentMetrics(
                dimension: { _ in throw expected },
                spacing: { _ in 0 },
                radius: { _ in 0 },
                border: { _ in 0 }
            )
        ) { error in
            XCTAssertEqual(error as? StyleTokenError, expected)
        }
    }

    func testFiveExplicitFamiliesResolveDistinctSurfacesAndBrandStates() throws {
        for family in ["blue", "green", "pink", "yellow", "purple"] {
            for mode in [Theme.light, .dark, .light] {
                let theme = try StrataTheme(theme: mode, brand: "strata-" + family)
                for (role, id) in [(StrataSurfaceRole.region, "region"), (.card, "card"), (.inset, "inset"), (.hover, "hover"), (.selected, "selected")] {
                    XCTAssertEqual(theme.surface(role), try StrataTokenColor.resolve("product.strata.\(family).surface.\(id)", theme: mode))
                }
                let prefix = "brand.strata-\(family)."
                for (actual, id) in [(theme.brandSeed, "seed"), (theme.brandSeedInk, "seed-ink"), (theme.brandText, "text"), (theme.accentHover, "hover"), (theme.accentActive, "active"), (theme.accentSubtle, "subtle")] {
                    XCTAssertEqual(actual, try StrataTokenColor.resolve(prefix + id, theme: mode))
                }
                XCTAssertEqual(theme.success, try StrataTokenColor.resolve("status.strata.success", theme: mode))
                XCTAssertEqual(theme.successSurface, try StrataTokenColor.resolve("status.strata.success-surface", theme: mode))
                XCTAssertEqual(theme.chartPrimary, try StrataTokenColor.resolve("product.strata.chart.primary", theme: mode))
                XCTAssertEqual(theme.material.panel, try StrataTokenColor.resolve("product.strata.\(family).material.panel", theme: mode))
            }
        }
    }

    func testNestedGlassUsesOneBlurAndReadingPlaneKeepsItsFill() {
        let outer = StrataSurfaceTreatment(style: .glass, role: .region, reduceTransparency: false, materialAncestor: false)
        let inner = StrataSurfaceTreatment(style: .glass, role: .card, reduceTransparency: false, materialAncestor: true)
        XCTAssertTrue(outer.blur)
        XCTAssertTrue(inner.glass)
        XCTAssertFalse(inner.blur)
        XCTAssertTrue(inner.decoration)
        for role in [StrataSurfaceRole.inset, .hover, .selected] {
            let control = StrataSurfaceTreatment(style: .glass, role: role, reduceTransparency: false, materialAncestor: true)
            XCTAssertFalse(control.glass)
            XCTAssertFalse(control.blur)
            XCTAssertFalse(control.decoration)
        }
    }

    func testTransparencyFallbackAndExplicitSolidHaveIdenticalTreatment() {
        for role in [StrataSurfaceRole.region, .card, .inset, .hover, .selected] {
            let fallback = StrataSurfaceTreatment(style: .glass, role: role, reduceTransparency: true, materialAncestor: false)
            let solid = StrataSurfaceTreatment(style: .solid, role: role, reduceTransparency: false, materialAncestor: false)
            XCTAssertEqual(fallback, solid)
            XCTAssertFalse(fallback.blur)
            XCTAssertFalse(fallback.decoration)
        }
    }

    func testMissingStrataColorPropagatesExactErrorWithoutLegacyFallback() {
        let expected = TokenError.unknownToken("injected-strata-role")
        XCTAssertThrowsError(try StrataTheme(theme: .dark, brand: "strata-purple", color: { id, _ in
            XCTAssertEqual(id, "product.strata.purple.surface.page")
            throw expected
        }, brandColor: { brand, role, mode in
            StrataTokenColor.color(from: try DesignTokens.brandColor(brand, role: role, theme: mode))
        })) { XCTAssertEqual($0 as? TokenError, expected) }
    }
    func testLegacyDenseReadingPlaneKeepsSecondaryContrastOnExtremeBackdrops() throws {
        for mode in Theme.allCases {
            let base = try DesignTokens.color("product.surface.raised", theme: mode)
            let text = try DesignTokens.color("product.text.secondary", theme: mode)
            let alpha = StrataSurfaceTreatment.legacyReadingOpacity
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
