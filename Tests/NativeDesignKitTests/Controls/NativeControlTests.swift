import DesignTokens
import SwiftUI
import XCTest
@testable import NativeDesignKit

final class NativeControlTests: XCTestCase {
    func testEveryControlToneUsesMatchingSemanticForegroundAndSurfaceInBothThemes() throws {
        let roles: [(NativeControlTone, String, String)] = [
            (.neutral, "product.surface.raised", "product.text.primary"),
            (.info, "status.info", "status.on-info"),
            (.warning, "status.warning", "status.on-warning"),
            (.critical, "status.critical", "status.on-critical")
        ]
        for theme in Theme.allCases {
            let snapshot = try NativeDesignTheme(theme: theme)
            for (tone, background, foreground) in roles {
                let pair = tone.colors(snapshot)
                XCTAssertEqual(pair.background, try NativeTokenColor.resolve(background, theme: theme))
                XCTAssertEqual(pair.foreground, try NativeTokenColor.resolve(foreground, theme: theme))
            }
        }
    }
}
