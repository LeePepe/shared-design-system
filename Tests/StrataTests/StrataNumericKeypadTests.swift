import DesignTokens
import SwiftUI
import XCTest
@testable import Strata

final class StrataNumericKeypadTests: XCTestCase {
    func testMetricsKeepTheClassAGridAt232Points() throws {
        let metrics = try StrataNumericKeypadMetrics()
        XCTAssertEqual(metrics.totalGridHeight, 232)
        XCTAssertEqual(metrics.digitRowHeight, metrics.actionHeight(forCount: 4))
        XCTAssertEqual(metrics.actionHeight(forCount: 2) * 2 + metrics.interRowSpacing,
                       metrics.totalGridHeight - metrics.verticalPadding * 2)
        XCTAssertGreaterThanOrEqual(metrics.compactCellRadius, 6)
        XCTAssertLessThanOrEqual(metrics.compactCellRadius, 8)
        XCTAssertEqual(metrics.minimumScaleFactor, 0.85)
    }

    func testMetricsPropagateStyleTokenErrors() {
        let expected = StyleTokenError.unknownToken("spacing.failure")
        XCTAssertThrowsError(try StrataNumericKeypadMetrics(spacing: { _ in throw expected })) {
            XCTAssertEqual($0 as? StyleTokenError, expected)
        }
    }

    func testConfigurationIsValueTypedAndSideActionsAreIdentifiable() {
        let action = StrataNumericKeypadSideAction(id: "clear", title: "Clear", systemImage: "xmark")
        let configuration = StrataNumericKeypadConfiguration(mode: .integer, leftActions: [action])
        XCTAssertEqual(configuration.leftActions.first?.id, "clear")
        XCTAssertEqual(configuration.mode, .integer)
    }

    @MainActor
    func testKeypadCanBeConstructedForBothThemesAndModes() throws {
        for themeMode in [Theme.light, Theme.dark] {
            let theme = try StrataTheme(theme: themeMode, brand: "strata-blue")
            for mode in [StrataNumericKeypadMode.decimal, .integer] {
                _ = try StrataNumericKeypad(theme: theme, configuration: .init(mode: mode),
                                             colorScheme: themeMode == .light ? .light : .dark) { _ in }
            }
        }
    }
}
