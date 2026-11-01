import DesignTokens
import Strata
import SwiftUI
import XCTest

final class StrataMetricBentoTests: XCTestCase {
    @MainActor
    func testMetricAndBentoPublicConstructionAcrossThemes() throws {
        for mode in Theme.allCases {
            let theme = try StrataTheme(theme: mode, brand: "strata-blue")
            let rows = [
                StrataMetricRowItem(key: "CPU Load", value: "16.81 / 24.00 GB"),
                StrataMetricRowItem(key: "核心负载", value: "11.3 / 27.4 / 25.1")
            ]
            let configuration = StrataBentoCardConfiguration(
                title: "CPU Load",
                primaryReadout: "16.81 GB",
                statusBadgeText: "Healthy",
                instrument: .progressRing(value: 16.81, total: 24),
                rows: rows,
                hostWidth: 169
            )
            _ = StrataMetricRow(theme: theme, item: rows[0], instrument: true).body
            _ = StrataBentoCard(theme: theme, configuration: configuration).body
        }
    }

    func testConfigurationPreservesDataAndFixedHostWidth() {
        let row = StrataMetricRowItem(id: "memory", key: "Memory", value: "8.00 GB")
        let configuration = StrataBentoCardConfiguration(
            title: "Memory",
            primaryReadout: "8.00 GB",
            rows: [row],
            hostWidth: 169
        )
        XCTAssertEqual(configuration.rows, [row])
        XCTAssertEqual(configuration.hostWidth, 169)
        XCTAssertEqual(configuration.instrument, .none)
    }
}
