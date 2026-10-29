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

        for brand in ["strata-blue", "strata-green", "strata-pink", "strata-yellow", "strata-purple"] {
            for mode in Theme.allCases {
                let theme = try StrataTheme(theme: mode, brand: brand)
                var selection = "all"
                let binding = Binding(get: { selection }, set: { selection = $0 })
                _ = try StrataMenu(theme: theme, label: "More actions", actions: [menuAction]).body
                _ = try StrataSegmentedBar(theme: theme, items: items, selection: binding).body
                _ = try StrataSegmentedBar(
                    theme: theme,
                    items: items,
                    selection: binding,
                    axis: .vertical,
                    isDisabled: true
                ).body
                _ = try StrataStateView(
                    theme: theme,
                    kind: .empty,
                    title: "No matches",
                    message: "Try a different search.",
                    actionTitle: "Reset",
                    action: {}
                ).body
                _ = try StrataStateView(
                    theme: theme,
                    kind: .loading,
                    title: "Loading",
                    isActionLoading: true
                ).body
                _ = try StrataStateView(
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

    func testComponentMetricsRetainsResolvedValues() throws {
        let metrics = try StrataComponentMetrics(
            dimension: { _ in 48 },
            spacing: { id in
                switch id {
                case "spacing.xs": return 5
                case "spacing.sm": return 7
                case "spacing.md": return 9
                case "spacing.lg": return 11
                case "spacing.xl": return 13
                default: XCTFail("Unexpected spacing token: \(id)"); return 0
                }
            },
            radius: { id in id == "radius.medium" ? 15 : 17 },
            border: { _ in 2 }
        )

        XCTAssertEqual(metrics.minimumHit, 48)
        XCTAssertEqual(metrics.spacingXS, 5)
        XCTAssertEqual(metrics.spacingSM, 7)
        XCTAssertEqual(metrics.spacingMD, 9)
        XCTAssertEqual(metrics.spacingLG, 11)
        XCTAssertEqual(metrics.spacingXL, 13)
        XCTAssertEqual(metrics.controlRadius, 20)
        XCTAssertEqual(metrics.cardRadius, 22)
        XCTAssertEqual(metrics.verticalItemWidth, 68)
        XCTAssertEqual(metrics.borderRegular, 2)

        let theme = try StrataTheme(theme: .light, brand: "strata-blue")
        var selection = "all"
        let binding = Binding(get: { selection }, set: { selection = $0 })
        let action = StrataMenuAction(id: "copy", title: "Copy") {}
        _ = StrataMenu(theme: theme, label: "More actions", actions: [action], metrics: metrics).body
        _ = StrataSegmentedBar(
            theme: theme,
            items: [StrataSegmentedItem(id: "all", title: "All")],
            selection: binding,
            metrics: metrics
        ).body
        _ = StrataStateView(
            theme: theme,
            kind: .empty,
            title: "No matches",
            metrics: metrics
        ).body
    }

    func testComponentMetricsResolvesCompactCellRadius() throws {
        let defaultMetrics = try StrataComponentMetrics()
        XCTAssertEqual(defaultMetrics.compactCellRadius, 6)

        let customMetrics = try StrataComponentMetrics(
            dimension: { _ in 44 },
            spacing: { _ in 0 },
            radius: { id in id == "radius.small" ? 6 : 12 },
            border: { _ in 1 }
        )
        XCTAssertEqual(customMetrics.compactCellRadius, 6)
    }

    func testComponentMetricsPropagatesTokenErrorsUnchanged() {
        let expected = StyleTokenError.unknownToken("dimension.failure")

        XCTAssertThrowsError(
            try StrataComponentMetrics(
                dimension: { _ in throw expected },
                spacing: { _ in 0 },
                radius: { _ in 0 },
                border: { _ in 0 }
            )
        ) { error in
            XCTAssertEqual(error as? StyleTokenError, expected)
        }
    }

    func testSegmentedAccessibilityValueContainsOnlyBadgeCount() {
        XCTAssertEqual(StrataSegmentedBar.accessibilityValue(for: 7), "7")
        XCTAssertEqual(StrataSegmentedBar.accessibilityValue(for: 0), "")
        XCTAssertEqual(StrataSegmentedBar.accessibilityValue(for: nil), "")
    }

    func testStateViewSurfaceConfigurationKeepsErrorDistinct() {
        XCTAssertTrue(StrataStateView.usesErrorSurface(for: .error))
        XCTAssertFalse(StrataStateView.usesErrorSurface(for: .empty))
        XCTAssertFalse(StrataStateView.usesErrorSurface(for: .loading))
    }
}
