import DesignTokens
import SwiftUI
import XCTest
@testable import Strata

final class StrataCheckboxTests: XCTestCase {
    func testSelectedAndUnselectedUseExactThemeRolesWithoutFadingText() throws {
        for brand in DesignTokens.brandIDs {
            for mode in Theme.allCases {
                let theme = try StrataTheme(theme: mode, brand: brand)
                let selected = StrataCheckboxColors(theme: theme, isOn: true, isEnabled: true)
                XCTAssertEqual(selected.fill, theme.accent)
                XCTAssertEqual(selected.outline, theme.accent)
                XCTAssertEqual(selected.mark, theme.onAccent)
                XCTAssertEqual(selected.label, theme.foreground)
                let unselected = StrataCheckboxColors(theme: theme, isOn: false, isEnabled: true)
                XCTAssertEqual(unselected.fill, .clear)
                XCTAssertEqual(unselected.outline, theme.secondaryForeground)
                XCTAssertEqual(unselected.label, theme.foreground)
                for isOn in [false, true] {
                    let disabled = StrataCheckboxColors(theme: theme, isOn: isOn, isEnabled: false)
                    XCTAssertEqual(disabled.fill, isOn ? theme.surface : .clear)
                    XCTAssertEqual(disabled.outline, theme.secondaryForeground)
                    XCTAssertEqual(disabled.mark, theme.secondaryForeground)
                    XCTAssertEqual(disabled.label, theme.secondaryForeground)
                }
            }
        }
    }

    @MainActor
    func testPublicGenericConstructionDoesNotMutateCallerState() throws {
        let theme = try StrataTheme(theme: .light, brand: "ocean")
        for initialValue in [false, true] {
            var writes = 0
            let binding = Binding(get: { initialValue }, set: { _ in writes += 1 })
            let checkbox = StrataCheckbox(theme: theme, isOn: binding) {
                Label("Caller-localized selection", systemImage: "doc")
            }
            _ = checkbox.body
            XCTAssertEqual(writes, 0)
            XCTAssertEqual(binding.wrappedValue, initialValue)
        }
    }
}
