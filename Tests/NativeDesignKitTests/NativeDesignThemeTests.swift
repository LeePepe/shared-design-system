import DesignTokens
import SwiftUI
import XCTest
@testable import NativeDesignKit

final class NativeDesignThemeTests: XCTestCase {
    func testThemeResolutionInBothThemes() throws {
        for theme in Theme.allCases {
            let resolvedTheme = try NativeDesignTheme(theme: theme)
            XCTAssertEqual(resolvedTheme.theme, theme)
        }
    }

    func testExactRequestedRoleOrder() throws {
        let expectedRoleOrder = [
            "product.surface.raised",
            "product.text.primary",
            "product.text.secondary",
            "status.info",
            "status.on-info",
            "status.warning",
            "status.on-warning",
            "status.critical",
            "status.on-critical",
            "product.surface.canvas"
        ]

        for theme in Theme.allCases {
            var requestedIDs: [String] = []
            var requestedThemes: [Theme] = []

            _ = try NativeDesignTheme(theme: theme) { id, requestedTheme in
                requestedIDs.append(id)
                requestedThemes.append(requestedTheme)
                return try NativeTokenColor.resolve(id, theme: requestedTheme)
            }

            XCTAssertEqual(requestedIDs, expectedRoleOrder, "Requested roles must match exact order for \(theme)")
            XCTAssertEqual(requestedThemes, Array(repeating: theme, count: expectedRoleOrder.count))
        }
    }

    func testAlternatingThemeReconstructionDoesNotStaleCache() throws {
        var callCount = 0
        let trackingResolver: (String, Theme) throws -> Color = { id, theme in
            callCount += 1
            return try NativeTokenColor.resolve(id, theme: theme)
        }

        let sequence: [Theme] = [.light, .dark, .light]
        for theme in sequence {
            let priorCount = callCount
            let resolved = try NativeDesignTheme(theme: theme, resolve: trackingResolver)
            XCTAssertEqual(resolved.theme, theme)
            XCTAssertEqual(callCount - priorCount, 10, "Each construction must resolve exactly 10 roles anew")
        }
        XCTAssertEqual(callCount, 30)
    }

    func testInjectedTokenErrorIdentityPropagatesUnchanged() {
        struct InjectedCustomError: Error, Equatable {}

        let tokenError = TokenError.unknownToken("injected.failing.token")
        for theme in Theme.allCases {
            XCTAssertThrowsError(
                try NativeDesignTheme(theme: theme) { _, _ in
                    throw tokenError
                }
            ) { error in
                XCTAssertEqual(error as? TokenError, tokenError)
            }

            XCTAssertThrowsError(
                try NativeDesignTheme(theme: theme) { _, _ in
                    throw InjectedCustomError()
                }
            ) { error in
                XCTAssertTrue(error is InjectedCustomError)
            }
        }
    }

    func testSemanticRolesCoverExactTenUniqueTokens() {
        let allRoles = SemanticTokenRole.allCases
        XCTAssertEqual(allRoles.count, 10)
        let uniqueIDs = Set(allRoles.map(\.tokenID))
        XCTAssertEqual(uniqueIDs.count, 10)

        for role in allRoles {
            XCTAssertTrue(
                DesignTokens.ids.contains(role.tokenID),
                "Role \(role.rawValue) must be a valid token in DesignTokens 0.1.1"
            )
        }
    }
}
