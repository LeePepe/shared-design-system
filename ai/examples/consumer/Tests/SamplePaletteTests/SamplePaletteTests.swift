import DesignTokens
import SamplePalette
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
}
