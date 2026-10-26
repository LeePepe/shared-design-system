import DesignTokens
import Strata
import SwiftUI
import XCTest

final class StrataCardPublicAPITests: XCTestCase {
    @MainActor
    func testPublicImportExampleSupportsLegacyAndStrataBrandsAndExplicitSurfaces() throws {
        for mode in Theme.allCases {
            for brand in ["ocean", "graphite", "strata-blue", "strata-green", "strata-pink", "strata-yellow", "strata-purple"] {
                let theme = try StrataTheme(theme: mode, brand: brand)
                for surface in [StrataSurfaceStyle.solid, .glass] {
                    let card = StrataCard(theme: theme, surface: surface) {
                        Text("A place for a clear title")
                    } content: {
                        Text("Caller-owned information wraps naturally.")
                    } supporting: {
                        Text("Supporting context")
                    } actions: {
                        Button("Continue") {}
                    }
                    _ = card.body
                }
            }
        }
    }

    @MainActor
    func testPublicImportAllowsOmittedSlotsWithoutChangingTheirTypes() throws {
        let theme = try StrataTheme(theme: .light, brand: "ocean")
        let card = StrataCard(theme: theme, surface: .solid) {
            EmptyView()
        } content: {
            Text("A plain content card")
        } supporting: {
            EmptyView()
        } actions: {
            EmptyView()
        }
        _ = card.body
        let contentOnly = StrataCard(theme: theme, surface: .solid) {
            Text("A plain content card")
        }
        _ = contentOnly.body
    }
}
