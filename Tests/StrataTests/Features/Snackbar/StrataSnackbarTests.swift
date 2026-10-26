import DesignTokens
import SwiftUI
import XCTest
@testable import Strata

final class StrataSnackbarTests: XCTestCase {
    @MainActor
    func testBlankLabelsAreRejectedInValidationOrder() throws {
        XCTAssertThrowsError(try StrataSnackbarItem(message: " ", closeLabel: "Close")) {
            XCTAssertEqual($0 as? StrataSnackbarConfigurationError, .emptyMessage)
        }
        XCTAssertThrowsError(try StrataSnackbarItem(message: "Saved", closeLabel: "\n")) {
            XCTAssertEqual($0 as? StrataSnackbarConfigurationError, .emptyCloseLabel)
        }
        XCTAssertThrowsError(try StrataSnackbarAction(label: "\t", perform: {})) {
            XCTAssertEqual($0 as? StrataSnackbarConfigurationError, .emptyActionLabel)
        }
    }

    @MainActor
    func testLifetimeCountsDownOnlyWithoutAction() throws {
        var lifetime = StrataFeedbackLifetime()
        let id = UUID()
        let epoch = UUID()
        lifetime.synchronize(id: id, hasAction: false, hostEpoch: epoch, now: 10)
        lifetime.setPaused(false, now: 10)
        lifetime.synchronize(id: id, hasAction: false, hostEpoch: epoch, now: 14)
        XCTAssertEqual(lifetime.remaining, 1, accuracy: 0.001)
        XCTAssertFalse(lifetime.permitsExpiry(id: id, hostEpoch: epoch, generation: lifetime.generation, now: 14))
        lifetime.synchronize(id: id, hasAction: false, hostEpoch: epoch, now: 15)
        XCTAssertEqual(lifetime.remaining, 0, accuracy: 0.001)
        XCTAssertTrue(lifetime.permitsExpiry(id: id, hostEpoch: epoch, generation: lifetime.generation, now: 15))
    }

    @MainActor
    func testLifetimePausesAndActionMessagesDoNotExpire() {
        var lifetime = StrataFeedbackLifetime()
        let id = UUID()
        let epoch = UUID()
        lifetime.synchronize(id: id, hasAction: false, hostEpoch: epoch, now: 10)
        lifetime.setPaused(true, now: 12)
        lifetime.synchronize(id: id, hasAction: false, hostEpoch: epoch, now: 100)
        XCTAssertEqual(lifetime.remaining, 3, accuracy: 0.001)
        lifetime.setPaused(false, now: 100)
        lifetime.synchronize(id: id, hasAction: false, hostEpoch: epoch, now: 103)
        XCTAssertEqual(lifetime.remaining, 0, accuracy: 0.001)

        lifetime.synchronize(id: id, hasAction: true, hostEpoch: epoch, now: 200)
        XCTAssertTrue(lifetime.remaining.isInfinite)
        XCTAssertFalse(lifetime.permitsExpiry(id: id, hostEpoch: epoch, generation: lifetime.generation, now: 10_000))
    }

    @MainActor
    func testLifetimeDoesNotSubtractSuspendedBackgroundTime() {
        var lifetime = StrataFeedbackLifetime()
        let id = UUID()
        let epoch = UUID()
        lifetime.synchronize(id: id, hasAction: false, hostEpoch: epoch, now: 0)
        lifetime.setPaused(false, now: 0)
        lifetime.synchronize(id: id, hasAction: false, hostEpoch: epoch, now: 1)
        XCTAssertEqual(lifetime.remaining, 4, accuracy: 0.001)
        lifetime.setPaused(true, now: 1)
        lifetime.synchronize(id: id, hasAction: false, hostEpoch: epoch, now: 11)
        XCTAssertEqual(lifetime.remaining, 4, accuracy: 0.001)
        lifetime.setPaused(false, now: 11)
        XCTAssertEqual(lifetime.remaining, 4, accuracy: 0.001)
    }

    @MainActor
    func testActionReplacementKeepsReplacementItemLifetime() throws {
        var item: StrataSnackbarItem?
        let replacement = try StrataSnackbarItem(message: "Undo available", closeLabel: "Close")
        let action = try StrataSnackbarAction(label: "Undo") {
            item = replacement
        }
        let original = try StrataSnackbarItem(message: "Set deleted", closeLabel: "Close", action: action)
        item = original
        original.action?.perform()
        XCTAssertEqual(item?.id, replacement.id)

        var lifetime = StrataFeedbackLifetime()
        let epoch = UUID()
        lifetime.synchronize(id: replacement.id, hasAction: false, hostEpoch: epoch, now: 10)
        lifetime.synchronize(id: replacement.id, hasAction: false, hostEpoch: epoch, now: 15)
        XCTAssertEqual(lifetime.remaining, 0, accuracy: 0.001)
    }

    @MainActor
    func testSnackbarConfigurationCoversAllBrandsAndThemes() throws {
        for brand in ["strata-blue", "strata-green", "strata-pink", "strata-yellow", "strata-purple"] {
            for mode in [Theme.light, Theme.dark] {
                let theme = try StrataTheme(theme: mode, brand: brand)
                var item: StrataSnackbarItem? = try StrataSnackbarItem(message: "Saved", closeLabel: "Close")
                let configuration = try StrataSnackbar<Text, EmptyView>.Configuration(
                    theme: theme,
                    item: Binding(get: { item }, set: { item = $0 }),
                    content: { Text("Content") },
                    bottomBar: { EmptyView() }
                )
                _ = StrataSnackbar<Text, EmptyView>(configuration: configuration).body
            }
        }
    }

    @MainActor
    func testPublicViewConfigurationResolvesTokensBeforeRendering() throws {
        let theme = try StrataTheme(theme: .light, brand: "strata-blue")
        var item: StrataSnackbarItem? = try StrataSnackbarItem(message: "Saved", closeLabel: "Close")
        let configuration = try StrataSnackbar<Text, EmptyView>.Configuration(
            theme: theme,
            item: Binding<StrataSnackbarItem?>(
                get: { item },
                set: { item = $0 }
            ),
            content: { Text("Content") },
            bottomBar: { EmptyView() }
        )
        _ = StrataSnackbar<Text, EmptyView>(configuration: configuration).body
    }
}
