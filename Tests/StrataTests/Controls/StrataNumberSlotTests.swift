import XCTest
import SwiftUI
import DesignTokens
@testable import Strata

final class StrataNumberSlotTests: XCTestCase {
    func testConfigurationRejectsMissingLabel() {
        XCTAssertThrowsError(try StrataNumberSlotConfiguration(label: "", displayValue: "10"))
    }

    @MainActor
    func testPublicConstructionSupportsEmptyActiveInvalidAndDisabledStates() throws {
        for brand in ["strata-blue", "strata-green", "strata-pink", "strata-yellow", "strata-purple"] {
            for mode in [Theme.light, Theme.dark] {
                let theme = try StrataTheme(theme: mode, brand: brand)
                for state in [(false, false, false), (true, false, false), (false, true, false), (false, false, true)] {
                    let config = try StrataNumberSlotConfiguration(label: "Weight", displayValue: "",
                                                                    prefixBadge: "L", unitLabel: "kg",
                                                                    isActive: state.0, isInvalid: state.1,
                                                                    isDisabled: state.2)
                    _ = StrataNumberSlot(theme: theme, configuration: config, action: {})
                }
            }
        }
    }

    func testCompletedConfigurationPreservesCompletionStateAndValue() throws {
        let theme = try StrataTheme(theme: .light, brand: "strata-blue")
        let config = try StrataNumberSlotConfiguration(label: "Completed weight",
                                                        displayValue: "20",
                                                        unitLabel: "kg",
                                                        isCompleted: true)
        XCTAssertTrue(config.isCompleted)
        XCTAssertEqual(config.displayValue, "20")
        let appearance = StrataNumberSlot.StrataNumberSlotAppearance(theme: theme, configuration: config)
        XCTAssertEqual(appearance.fill, theme.successSurface)
        XCTAssertEqual(appearance.foreground, theme.success)
        XCTAssertEqual(appearance.outline, theme.success)
        XCTAssertEqual(appearance.accessibilityValue, "20 kg")
    }

    func testDisabledForegroundUsesSecondaryThemeColorAcrossBrandsAndModes() throws {
        for brand in ["strata-blue", "strata-green", "strata-pink", "strata-yellow", "strata-purple"] {
            for mode in [Theme.light, Theme.dark] {
                let theme = try StrataTheme(theme: mode, brand: brand)
                let config = try StrataNumberSlotConfiguration(label: "Disabled weight",
                                                                displayValue: "60",
                                                                unitLabel: "kg",
                                                                isCompleted: true,
                                                                isDisabled: true)
                let appearance = StrataNumberSlot.StrataNumberSlotAppearance(theme: theme, configuration: config)
                XCTAssertEqual(appearance.foreground, theme.secondaryForeground)
            }
        }
    }
}
