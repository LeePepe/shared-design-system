import DesignTokens
import NativeDesignKit
import SamplePalette
import SwiftUI
import XCTest

final class SamplePaletteTests: XCTestCase {
    func testPublicProductResolvesEveryTokenInBothThemes() throws {
        XCTAssertFalse(DesignTokens.ids.isEmpty)
        for theme in Theme.allCases {
            for id in DesignTokens.ids {
                _ = try SamplePalette.color(id, theme: theme)
            }
        }
    }

    func testUnknownIDPreservesPublicError() {
        for theme in Theme.allCases {
            XCTAssertThrowsError(try SamplePalette.color("__unknown_consumer_token__", theme: theme)) {
                XCTAssertEqual($0 as? TokenError, .unknownToken("__unknown_consumer_token__"))
            }
        }
    }

    @MainActor
    func testThemeAndCardConstructionInBothThemes() throws {
        for theme in Theme.allCases {
            let resolvedTheme = try SamplePalette.makeTheme(theme: theme)
            let card = SamplePalette.makeCard(theme: resolvedTheme) {
                Text("Sample Card Content")
            }
            XCTAssertNotNil(card.body)
        }
    }
}
