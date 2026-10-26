import DesignTokens
import SwiftUI
import XCTest
@testable import Strata

@MainActor
final class StrataMenuStateTests: XCTestCase {
    func testMenuActionPreservesPublicValuesAndRunsHandler() {
        var handled = false
        let action = StrataMenuAction(
            id: "delete",
            title: "Delete set",
            systemImage: "trash",
            role: .destructive,
            isDisabled: false
        ) {
            handled = true
        }

        XCTAssertEqual(action.id, "delete")
        XCTAssertEqual(action.title, "Delete set")
        XCTAssertEqual(action.systemImage, "trash")
        XCTAssertFalse(action.isDisabled)
        action.handler()
        XCTAssertTrue(handled)
    }

    func testComponentsBuildForEveryStrataTheme() throws {
        let items = [
            StrataSegmentedItem(id: "all", title: "All", badgeCount: 3),
            StrataSegmentedItem(id: "legs", title: "Legs")
        ]
        let menuAction = StrataMenuAction(id: "copy", title: "Copy", systemImage: "doc.on.doc") {}

        for brand in ["strata-blue", "strata-purple"] {
            for mode in Theme.allCases {
                let theme = try StrataTheme(theme: mode, brand: brand)
                var selection = "all"
                let binding = Binding(get: { selection }, set: { selection = $0 })
                _ = StrataMenu(theme: theme, label: "More actions", actions: [menuAction]).body
                _ = StrataSegmentedBar(theme: theme, items: items, selection: binding).body
                _ = StrataSegmentedBar(
                    theme: theme,
                    items: items,
                    selection: binding,
                    axis: .vertical,
                    isDisabled: true
                ).body
                _ = StrataStateView(
                    theme: theme,
                    kind: .empty,
                    title: "No matches",
                    message: "Try a different search.",
                    actionTitle: "Reset",
                    action: {}
                ).body
                _ = StrataStateView(
                    theme: theme,
                    kind: .loading,
                    title: "Loading",
                    isActionLoading: true
                ).body
                _ = StrataStateView(
                    theme: theme,
                    kind: .error,
                    title: "Could not load",
                    message: "Try again.",
                    actionTitle: "Retry",
                    action: {}
                ).body
            }
        }
    }

    func testSegmentedItemEqualityIncludesBadgeCount() {
        XCTAssertEqual(
            StrataSegmentedItem(id: "all", title: "All", badgeCount: 2),
            StrataSegmentedItem(id: "all", title: "All", badgeCount: 2)
        )
        XCTAssertNotEqual(
            StrataSegmentedItem(id: "all", title: "All", badgeCount: 2),
            StrataSegmentedItem(id: "all", title: "All", badgeCount: 0)
        )
    }
}
