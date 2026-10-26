import DesignTokens
import Strata
import SwiftUI
import XCTest

final class RenameReviewMacTests: XCTestCase {
    @MainActor
    func testStrataPublicSurface() throws {
        let theme = try StrataTheme(theme: .dark, brand: "strata-purple")
        _ = StrataButton(theme: theme, variant: .secondary, isLoading: false, action: {}) {
            Text("Continue")
        } loadingLabel: {
            Text("Loading")
        }
        XCTAssertEqual(theme.mode, .dark)
    }
}
