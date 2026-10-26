import DesignTokens
import SwiftUI
import XCTest
@testable import Strata

final class StrataDialogTests: XCTestCase {
    @MainActor
    func testValidationFollowsDeclaredOrder() throws {
        XCTAssertThrowsError(try StrataDialogPresentation(title: " ", closeLabel: "Close", actions: [])) {
            XCTAssertEqual($0 as? StrataDialogConfigurationError, .emptyTitle)
        }
        XCTAssertThrowsError(try StrataDialogPresentation(title: "Title", closeLabel: " ", actions: [])) {
            XCTAssertEqual($0 as? StrataDialogConfigurationError, .emptyCloseLabel)
        }
        XCTAssertThrowsError(try StrataDialogPresentation(
            title: "Title", closeLabel: "Close", state: .loading(message: " "), actions: []
        )) {
            XCTAssertEqual($0 as? StrataDialogConfigurationError, .emptyStatusMessage)
        }
        XCTAssertThrowsError(try StrataDialogPresentation(
            title: "Title", closeLabel: "Close", dismissalPolicy: .guarded(reason: " "), actions: []
        )) {
            XCTAssertEqual($0 as? StrataDialogConfigurationError, .emptyGuardReason)
        }
    }

    @MainActor
    func testDuplicateAndPrimaryActionValidation() throws {
        let first = try StrataDialogAction(id: "same", label: "One", role: .secondary) { .stayPresented }
        let second = try StrataDialogAction(id: "same", label: "Two", role: .secondary) { .stayPresented }
        XCTAssertThrowsError(try StrataDialogPresentation(
            title: "Title", closeLabel: "Close", actions: [first, second]
        )) {
            XCTAssertEqual($0 as? StrataDialogConfigurationError, .duplicateActionID("same"))
        }
        let primary = try StrataDialogAction(id: "one", label: "One", role: .primary) { .stayPresented }
        let otherPrimary = try StrataDialogAction(id: "two", label: "Two", role: .primary) { .stayPresented }
        XCTAssertThrowsError(try StrataDialogPresentation(
            title: "Title", closeLabel: "Close", actions: [primary, otherPrimary]
        )) {
            XCTAssertEqual($0 as? StrataDialogConfigurationError, .multiplePrimaryActions)
        }
    }

    @MainActor
    func testModalSessionGenerationInvalidatesOldCallbacks() {
        var session = StrataModalSession(id: UUID())
        let firstID = session.id
        let generation = session.generation
        XCTAssertTrue(session.matches(id: firstID, generation: generation))
        session.replace(id: UUID())
        XCTAssertFalse(session.matches(id: firstID, generation: generation))
        session.invalidate()
        XCTAssertFalse(session.matches(id: session.id, generation: generation))
    }

    @MainActor
    func testConfigurationResolvesTokensForAllSupportedThemesAndBrands() throws {
        let action = try StrataDialogAction(id: "save", label: "Save", role: .primary) { .dismiss }
        for brand in ["strata-blue", "strata-purple"] {
            for mode in [Theme.light, Theme.dark] {
                let theme = try StrataTheme(theme: mode, brand: brand)
                var presentation: StrataDialogPresentation? = try StrataDialogPresentation(
                    title: "Effort", closeLabel: "Close", state: .loading(message: "Loading"),
                    dismissalPolicy: .guarded(reason: "Finish the set first"), actions: [action]
                )
                let configuration = try StrataDialog<Text, Text>.Configuration(
                    theme: theme,
                    presentation: Binding(get: { presentation }, set: { presentation = $0 }),
                    base: { Text("Workout") },
                    content: { _ in Text("RPE 6.0–10.0") }
                )
                _ = StrataDialog(configuration: configuration).body
            }
        }
    }

    @MainActor
    func testAlertDialogValidatesAndBuilds() throws {
        let theme = try StrataTheme(theme: .light, brand: "strata-blue")
        var isPresented = true
        let configuration = try StrataAlertDialog<Text>.Configuration(
            theme: theme,
            isPresented: Binding(get: { isPresented }, set: { isPresented = $0 }),
            title: "Finish workout?",
            message: "Your current set will be ended.",
            confirmLabel: "Finish",
            cancelLabel: "Keep going",
            isDestructive: true,
            confirm: {},
            base: { Text("Workout") }
        )
        _ = StrataAlertDialog(configuration: configuration).body
    }
}
