import SwiftUI
import XCTest
import NativeDesignKit

final class NativeTextFieldTests: XCTestCase {
    @MainActor
    func testPublicConstructionPreservesCallerOwnedInputAndSupportsNativeModifiers() throws {
        var value = "  Caller text — 原样  "
        let binding = Binding(get: { value }, set: { value = $0 })
        let theme = try NativeDesignTheme(theme: .light, brand: "ocean")
        // Compile the public generic API, optional prompt and caller modifiers.
        // Editing, disabled, submit and layout assertions live in the real UI fixture.
        _ = NativeTextField(theme: theme, text: binding, prompt: Text("Enter a value"),
                            accessibilityLabel: Text("Display name")) {
            Label("Display name", systemImage: "person")
        }
        .disabled(true)
        .submitLabel(.done)
        .onSubmit { value = "Submitted by caller" }
        _ = NativeTextField(theme: theme, text: binding) { Text("Name") }
        _ = NativeTextField(theme: theme, text: binding, prompt: Text("Your name")) { Text("Name") }
        XCTAssertEqual(value, "  Caller text — 原样  ")
    }
}
