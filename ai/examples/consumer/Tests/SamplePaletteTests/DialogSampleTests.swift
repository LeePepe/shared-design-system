import DesignTokens
import SwiftUI
import XCTest
import SamplePalette
import Strata

final class DialogSampleTests: XCTestCase {
    @MainActor
    func testDialogSampleUsesPublicInterfaces() throws {
        let theme = try StrataTheme(theme: .light, brand: "strata-purple")
        let action = try StrataDialogAction(id: "save", label: "Save", role: .primary) { .dismiss }
        var presentation: StrataDialogPresentation? = try StrataDialogPresentation(
            title: "Effort", closeLabel: "Close", actions: [action]
        )
        var alertPresented = false
        _ = try DialogSampleView(
            theme: theme,
            presentation: Binding(get: { presentation }, set: { presentation = $0 }),
            isAlertPresented: Binding(get: { alertPresented }, set: { alertPresented = $0 }),
            confirm: {}
        ).body
    }
}
