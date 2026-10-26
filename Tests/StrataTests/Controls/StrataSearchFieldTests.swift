import XCTest
import SwiftUI
import DesignTokens
@testable import Strata

final class StrataSearchFieldTests: XCTestCase {
    func testConfigurationRejectsMissingAccessibleLabels() {
        XCTAssertThrowsError(try StrataSearchFieldConfiguration(label: "", clearLabel: "Clear"))
        XCTAssertThrowsError(try StrataSearchFieldConfiguration(label: "Search", clearLabel: ""))
    }

    @MainActor
    func testPublicConstructionKeepsCallerStateAndCallbacks() throws {
        var value = "runner"
        let binding = Binding(get: { value }, set: { value = $0 })
        let config = try StrataSearchFieldConfiguration(label: "Search exercises",
                                                         placeholder: "Find an exercise",
                                                         clearLabel: "Clear search",
                                                         resultSummary: "3 results")
        let theme = try StrataTheme(theme: .light, brand: "strata-blue")
        _ = StrataSearchField(theme: theme, text: binding, configuration: config,
                              onSubmit: {}, onClear: {})
        XCTAssertEqual(value, "runner")
    }
}
