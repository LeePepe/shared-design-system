import DesignTokens
@testable import Strata
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
            _ = StrataMetricRow(theme: theme, item: rows[0], instrument: true, progress: 16.81, total: 24).body
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

    func testValidationPredicatesCoverTextAndInstrumentBoundaries() {
        XCTAssertTrue(StrataMetricRowItem.accepts(key: "核心负载", value: "16.81 / 24.00 GB"))
        XCTAssertTrue(StrataMetricRowItem.accepts(key: "CPU Load", value: "11.3 / 27.4 / 25.1"))
        XCTAssertFalse(StrataMetricRowItem.accepts(key: "核心负载过", value: "1"))
        XCTAssertFalse(StrataMetricRowItem.accepts(key: "CPU Loads", value: "1"))
        XCTAssertFalse(StrataMetricRowItem.accepts(key: "CPU\nLoad", value: "1"))
        XCTAssertFalse(StrataMetricRowItem.accepts(key: "   ", value: "1"))
        XCTAssertFalse(StrataMetricRowItem.accepts(key: "CPU Load", value: ""))
        XCTAssertFalse(StrataMetricRowItem.accepts(key: "CPU Load", value: "…"))
        XCTAssertFalse(StrataMetricRowItem.accepts(key: "CPU Load", value: "..."))

        XCTAssertTrue(StrataBentoCardConfiguration.accepts(
            title: "CPU Load",
            primaryReadout: "16.81 / 24.00 GB",
            instrument: .progressRing(value: 16.81, total: 24)
        ))
        XCTAssertFalse(StrataBentoCardConfiguration.accepts(title: "核心负载过", primaryReadout: "1"))
        XCTAssertFalse(StrataBentoCardConfiguration.accepts(title: "CPU Load", primaryReadout: " \n "))
        XCTAssertFalse(StrataBentoCardConfiguration.accepts(title: "CPU Load", primaryReadout: "..."))
        XCTAssertFalse(StrataBentoCardConfiguration.accepts(
            title: "CPU Load",
            primaryReadout: "1",
            statusBadgeText: "…"
        ))
        XCTAssertFalse(StrataBentoCardConfiguration.accepts(
            title: "CPU Load",
            primaryReadout: "1",
            instrument: .progressBar(value: 1, total: 0)
        ))
    }

    @MainActor
    func testMetricRowsRenderAtRingDependentHeights() throws {
        guard #available(macOS 13, iOS 16, *) else { return }
        let theme = try StrataTheme(theme: .light, brand: "strata-blue")
        let item = StrataMetricRowItem(key: "CPU Load", value: "16.81 / 24.00 GB")
        XCTAssertEqual(try renderedImage(StrataMetricRow(theme: theme, item: item)).height, 36)
        XCTAssertEqual(
            try renderedImage(StrataMetricRow(theme: theme, item: item, instrument: true, progress: 16.81, total: 24)).height,
            48
        )
    }

    @MainActor
    func testBentoHostWidthAndInstrumentSiblingHeightParityAcrossThemes() throws {
        guard #available(macOS 13, iOS 16, *) else { return }
        let rows = [StrataMetricRowItem(key: "CPU Load", value: "16.81 / 24.00 GB")]
        for mode in Theme.allCases {
            let theme = try StrataTheme(theme: mode, brand: "strata-blue")
            let ring = StrataBentoCardConfiguration(
                title: "CPU Load",
                primaryReadout: "16.81 / 24.00 GB",
                instrument: .progressRing(value: 16.81, total: 24),
                rows: rows,
                hostWidth: 169
            )
            let bar = StrataBentoCardConfiguration(
                title: "核心负载",
                primaryReadout: "11.3 / 27.4 / 25.1",
                instrument: .progressBar(value: 11.3, total: 27.4),
                rows: rows,
                hostWidth: 169
            )
            let ringImage = try renderedImage(StrataBentoCard(theme: theme, configuration: ring))
            let barImage = try renderedImage(StrataBentoCard(theme: theme, configuration: bar))
            XCTAssertEqual(ringImage.width, 338)
            XCTAssertEqual(barImage.width, 338)
            XCTAssertLessThanOrEqual(abs(ringImage.height - barImage.height), 1)

            let pair = HStack(spacing: 10) {
                StrataBentoCard(theme: theme, configuration: ring)
                StrataBentoCard(theme: theme, configuration: bar)
            }
            let hostImage = try renderedImage(pair.padding(16).frame(width: 380))
            XCTAssertEqual(hostImage.width, 760)
        }
    }

    @MainActor
    @available(macOS 13, iOS 16, *)
    private func renderedImage<V: View>(_ view: V) throws -> CGImage {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        return try XCTUnwrap(renderer.cgImage)
    }
}
