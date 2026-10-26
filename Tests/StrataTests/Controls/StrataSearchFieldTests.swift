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
        for brand in ["strata-blue", "strata-green", "strata-pink", "strata-yellow", "strata-purple"] {
            for mode in [Theme.light, Theme.dark] {
                var value = "runner"
                let binding = Binding(get: { value }, set: { value = $0 })
                let config = try StrataSearchFieldConfiguration(label: "Search exercises",
                                                                 placeholder: "Find an exercise",
                                                                 clearLabel: "Clear search",
                                                                 resultSummary: "3 results",
                                                                 validationMessage: "Enter at least 2 characters",
                                                                 isDisabled: true)
                let theme = try StrataTheme(theme: mode, brand: brand)
                _ = StrataSearchField(theme: theme, text: binding, configuration: config,
                                      onSubmit: { value = "submitted" },
                                      onClear: { value = "" })
                XCTAssertEqual(value, "runner")
                XCTAssertTrue(config.isDisabled)
                XCTAssertEqual(config.validationMessage, "Enter at least 2 characters")
            }
        }
    }
}
