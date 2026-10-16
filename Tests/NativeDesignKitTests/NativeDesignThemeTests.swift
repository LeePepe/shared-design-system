import DesignTokens
import SwiftUI
import XCTest
@testable import NativeDesignKit

final class NativeDesignThemeTests: XCTestCase {
    func testOpaqueTextPairsMeetNormalTextContrastForEveryBrandAndTheme() throws {
        for brand in DesignTokens.brandIDs {
            for mode in Theme.allCases {
                let accent = try DesignTokens.brandColor(brand, role: .accent, theme: mode)
                let onAccent = try DesignTokens.brandColor(brand, role: .onAccent, theme: mode)
                let foreground = try DesignTokens.color("product.text.primary", theme: mode)
                let surface = try DesignTokens.color("product.surface.raised", theme: mode)
                // The provider rejects translucent pairs; no assumed compositing background.
                let actionContrast = try onAccent.contrast(with: accent)
                let surfaceContrast = try foreground.contrast(with: surface)
                let context = "\(brand)/\(mode.rawValue)"
                XCTAssertGreaterThanOrEqual(actionContrast, 4.5, "\(context) onAccent/accent")
                XCTAssertGreaterThanOrEqual(surfaceContrast, 4.5, "\(context) foreground/surface")
                print("Contrast \(context): onAccent/accent=\(actionContrast), foreground/surface=\(surfaceContrast)")
            }
        }
    }

    func testAllProviderBrandsAndThemesResolveFreshSnapshots() throws {
        for brand in DesignTokens.brandIDs {
            for mode in [Theme.light, .dark, .light] {
                let theme = try NativeDesignTheme(theme: mode, brand: brand)
                XCTAssertEqual(theme.mode, mode)
                let family = brand.hasPrefix("strata-") ? String(brand.dropFirst(7)) : nil
                let prefix = family.map { "product.strata.\($0)." }
                XCTAssertEqual(theme.canvas, try NativeTokenColor.resolve(prefix.map { $0 + "surface.page" } ?? "product.surface.canvas", theme: mode))
                XCTAssertEqual(theme.surface, try NativeTokenColor.resolve(prefix.map { $0 + "surface.card" } ?? "product.surface.raised", theme: mode))
                XCTAssertEqual(theme.foreground, try NativeTokenColor.resolve(family == nil ? "product.text.primary" : "product.strata.text.primary", theme: mode))
                XCTAssertEqual(theme.secondaryForeground, try NativeTokenColor.resolve(family == nil ? "product.text.secondary" : "product.strata.text.secondary", theme: mode))
                XCTAssertEqual(theme.accent, NativeTokenColor.color(from: try DesignTokens.brandColor(brand, role: .accent, theme: mode)))
                XCTAssertEqual(theme.onAccent, NativeTokenColor.color(from: try DesignTokens.brandColor(brand, role: .onAccent, theme: mode)))
                XCTAssertEqual(theme.critical, try NativeTokenColor.resolve(family == nil ? "status.critical" : "status.strata.error", theme: mode))
                XCTAssertEqual(theme.onCritical, try NativeTokenColor.resolve(family == nil ? "status.on-critical" : "status.strata.error-surface", theme: mode))
            }
        }
    }

    func testUnknownBrandPropagatesExactProviderError() {
        for mode in Theme.allCases {
            XCTAssertThrowsError(try NativeDesignTheme(theme: mode, brand: "__unknown_brand__")) {
                XCTAssertEqual($0 as? TokenError, .unknownBrand("__unknown_brand__"))
            }
        }
    }

    func testEveryConstructionPerformsFreshRoleResolution() throws {
        var requests: [String] = []
        for mode in [Theme.light, .dark, .light] {
            _ = try NativeDesignTheme(theme: mode, brand: "ocean", color: { id, theme in
                XCTAssertEqual(theme, mode)
                requests.append(id)
                return try NativeTokenColor.resolve(id, theme: theme)
            }, brandColor: { brand, role, theme in
                XCTAssertEqual(theme, mode)
                requests.append("\(brand).\(role.rawValue)")
                return NativeTokenColor.color(from: try DesignTokens.brandColor(brand, role: role, theme: theme))
            })
        }
        let roles = ["product.surface.canvas", "product.surface.raised", "product.text.primary", "product.text.secondary", "ocean.accent", "ocean.onAccent", "status.critical", "status.on-critical", "status.strata.success", "status.strata.success-surface", "product.strata.chart.primary"]
        XCTAssertEqual(requests, roles + roles + roles)
    }

    func testSemanticAndBrandResolverErrorsPropagateUnchanged() {
        let expected = TokenError.unknownToken("injected-exact-error")
        XCTAssertThrowsError(try NativeDesignTheme(theme: .dark, brand: "ocean", color: { _, _ in
            throw expected
        }, brandColor: { _, _, _ in XCTFail("Resolution must stop at first failure"); throw expected })) {
            XCTAssertEqual($0 as? TokenError, expected)
        }
        XCTAssertThrowsError(try NativeDesignTheme(theme: .light, brand: "ocean", color: NativeTokenColor.resolve, brandColor: { _, _, _ in
            throw expected
        })) {
            XCTAssertEqual($0 as? TokenError, expected)
        }
    }
}
