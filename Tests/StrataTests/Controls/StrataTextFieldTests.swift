import SwiftUI
import XCTest
import Strata

final class StrataTextFieldTests: XCTestCase {
    @MainActor
    func testPublicConstructionPreservesCallerOwnedInputAndSupportsStrataModifiers() throws {
        var value = "  Caller text — 原样  "
        let binding = Binding(get: { value }, set: { value = $0 })
        let theme = try StrataTheme(theme: .light, brand: "ocean")
        // Compile the public generic API, optional prompt and caller modifiers.
        // Editing, disabled, submit and layout assertions live in the real UI fixture.
        _ = StrataTextField(theme: theme, text: binding, prompt: Text("Enter a value"),
                            accessibilityLabel: Text("Display name")) {
            Label("Display name", systemImage: "person")
        }
        .disabled(true)
        .submitLabel(.done)
        .onSubmit { value = "Submitted by caller" }
        _ = StrataTextField(theme: theme, text: binding) { Text("Name") }
        _ = StrataTextField(theme: theme, text: binding, prompt: Text("Your name")) { Text("Name") }
        XCTAssertEqual(value, "  Caller text — 原样  ")
    }

    @MainActor
    func testControlsComposeWithStrataAlignmentGuides() throws {
        var value = ""
        let binding = Binding(get: { value }, set: { value = $0 })
        let theme = try StrataTheme(theme: .light, brand: "ocean")
        let searchConfiguration = try StrataSearchFieldConfiguration(
            label: "Search", clearLabel: "Clear"
        )
        let numberConfiguration = try StrataNumberSlotConfiguration(
            label: "Count", displayValue: "3"
        )

        _ = HStack(alignment: .strataControlCenter) {
            StrataTextField(theme: theme, text: binding) { Text("Name") }
            StrataSearchField(theme: theme, text: binding, configuration: searchConfiguration)
            StrataNumberSlot(theme: theme, configuration: numberConfiguration) {}
            StrataButton(theme: theme, variant: .primary, isLoading: false, action: {}) {
                Text("Save")
            } loadingLabel: {
                Text("Saving")
            }
        }
        _ = HStack(alignment: .strataInputBaseline) {
            StrataTextField(theme: theme, text: binding) { Text("Name") }
            StrataSearchField(theme: theme, text: binding, configuration: searchConfiguration)
            StrataNumberSlot(theme: theme, configuration: numberConfiguration) {}
            StrataButton(theme: theme, variant: .primary, isLoading: false, action: {}) {
                Text("Save")
            } loadingLabel: {
                Text("Saving")
            }
        }
    }
}
