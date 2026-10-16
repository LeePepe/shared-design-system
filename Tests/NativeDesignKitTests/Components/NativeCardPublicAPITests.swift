import DesignTokens
import NativeDesignKit
import SwiftUI
import XCTest

final class NativeCardPublicAPITests: XCTestCase {
    @MainActor
    func testPublicImportExampleSupportsBothBrandsAndExplicitSurfaces() throws {
        for mode in Theme.allCases {
            for brand in ["ocean", "graphite"] {
                let theme = try NativeDesignTheme(theme: mode, brand: brand)
                for surface in [NativeSurfaceStyle.solid, .glass] {
                    let card = NativeCard(theme: theme, surface: surface) {
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
        let theme = try NativeDesignTheme(theme: .light, brand: "ocean")
        let card = NativeCard(theme: theme, surface: .solid) {
            EmptyView()
        } content: {
            Text("A plain content card")
        } supporting: {
            EmptyView()
        } actions: {
            EmptyView()
        }
        _ = card.body
        let contentOnly = NativeCard(theme: theme, surface: .solid) {
            Text("A plain content card")
        }
        _ = contentOnly.body
    }
}
