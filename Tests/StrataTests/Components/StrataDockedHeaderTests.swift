import DesignTokens
@testable import Strata
import SwiftUI
import XCTest

final class StrataDockedHeaderTests: XCTestCase {
    @MainActor
    func testPublicAPIsResolveAcrossAllStrataBrandsAndThemes() throws {
        for brand in ["strata-blue", "strata-green", "strata-pink", "strata-yellow", "strata-purple"] {
            for mode in Theme.allCases {
                let theme = try StrataTheme(theme: mode, brand: brand)
                let bar = StrataDockedBar(theme: theme, style: .solid) {
                    Text("Actions")
                }
                let header = StrataSectionHeader(theme: theme, title: "Barbell", subtitle: "Chest", badgeText: "3") {
                    Button("More") {}
                }
                let rail = StrataIndexRail(
                    theme: theme,
                    items: [StrataIndexRailItem(id: "bar", shortLabel: "B", fullTitle: "Barbell")],
                    activeID: "bar",
                    showsHUD: true,
                    onSelect: { _ in }
                )
                _ = bar.body
                _ = header.body
                _ = rail.body
            }
        }
    }

    @MainActor
    func testOptionalHeaderContentAndEmptyRailDoNotRequirePlaceholderValues() throws {
        let theme = try StrataTheme(theme: .light, brand: "strata-blue")
        let header = StrataSectionHeader(theme: theme, title: "Equipment") {
            EmptyView()
        }
        let emptyRail = StrataIndexRail(theme: theme, items: [], activeID: nil, onSelect: { _ in })
        _ = header.body
        _ = emptyRail.body
    }

    func testIndexRailItemIsValueComparableAndSendable() {
        let item = StrataIndexRailItem(id: "cable", shortLabel: "C", fullTitle: "Cable")
        XCTAssertEqual(item, StrataIndexRailItem(id: "cable", shortLabel: "C", fullTitle: "Cable"))
        XCTAssertNotEqual(item, StrataIndexRailItem(id: "machine", shortLabel: "M", fullTitle: "Machine"))
    }

    func testIndexRailItemIndexUsesRenderedRailHeight() {
        XCTAssertEqual(StrataIndexRail.itemIndex(at: 44, railHeight: 132, itemCount: 3), 1)
        XCTAssertEqual(StrataIndexRail.itemIndex(at: 128, railHeight: 132, itemCount: 3), 2)
        XCTAssertEqual(StrataIndexRail.itemIndex(at: 64, railHeight: 192, itemCount: 3), 1)
        XCTAssertEqual(StrataIndexRail.itemIndex(at: 190, railHeight: 192, itemCount: 3), 2)
        XCTAssertNil(StrataIndexRail.itemIndex(at: 0, railHeight: 0, itemCount: 0))
    }
}
