import DesignTokens
import SwiftUI
import XCTest
@testable import NativeDesignKit

final class NativeCardTests: XCTestCase {
    func testCardRoleModelUsesExpectedSemanticRoles() {
        XCTAssertEqual(NativeCardRoleModel.backgroundRole, .surfaceRaised)
        XCTAssertEqual(NativeCardRoleModel.foregroundRole, .textPrimary)
        XCTAssertEqual(NativeCardRoleModel.backgroundRole.tokenID, "product.surface.raised")
        XCTAssertEqual(NativeCardRoleModel.foregroundRole.tokenID, "product.text.primary")
    }

    @MainActor
    func testPublicCardConstructionWithGenericContent() throws {
        for theme in Theme.allCases {
            let resolvedTheme = try NativeDesignTheme(theme: theme)

            let textCard = NativeCard(theme: resolvedTheme) {
                Text("Sample Card Title")
            }
            XCTAssertNotNil(textCard.body)

            let compositeCard = NativeCard(theme: resolvedTheme) {
                VStack {
                    Text("Heading")
                    Button("Action") {}
                }
            }
            XCTAssertNotNil(compositeCard.body)
        }
    }
}
