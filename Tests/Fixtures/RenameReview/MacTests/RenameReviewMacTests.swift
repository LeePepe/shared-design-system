import DesignTokens
import Strata
import SwiftUI
import XCTest

final class RenameReviewMacTests: XCTestCase {
    @MainActor
    func testStrataPublicSurface() throws {
        let theme = try StrataTheme(theme: .dark, brand: "strata-purple")
        _ = StrataSectionHeader(theme: theme, title: "Continue") {
            Button("Action") {}
        }
        XCTAssertEqual(theme.mode, .dark)
    }
}
