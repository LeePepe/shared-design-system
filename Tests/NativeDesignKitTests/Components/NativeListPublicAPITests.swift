import DesignTokens
import NativeDesignKit
import SwiftUI
import XCTest

final class NativeListPublicAPITests: XCTestCase {
    private struct Entry {
        let identity: String
        let title: String
    }

    @MainActor
    func testPublicSlotsCustomIdentityAndSelectionModesConstructWithoutWriting() throws {
        let entries = [Entry(identity: "stable-a", title: "Caller content")]
        var writes = 0
        let selection = Binding<String?>(get: { nil }, set: { _ in writes += 1 })
        for mode in Theme.allCases {
            for brand in ["strata-blue", "strata-green", "strata-pink", "strata-yellow", "strata-purple"] {
                let theme = try NativeDesignTheme(theme: mode, brand: brand)
                for surface in [NativeSurfaceStyle.solid, .glass] {
                    let list = NativeList(
                        theme: theme, surface: surface, items: entries, id: \.identity,
                        selection: .single(selection), selectedLabel: Text("Chosen"),
                        isRowEnabled: { $0.identity != "disabled" }
                    ) { Text("Caller heading") } leading: { _ in Image(systemName: "doc") }
                    primary: { Text($0.title) } secondary: { _ in Text("Supporting copy") }
                    trailing: { _ in Text("04 items") } footer: { Text("Caller context") }
                    _ = list.body
                    let readOnly = NativeList(
                        theme: theme, surface: surface, items: entries, id: \.identity,
                        selection: .readOnly(["stable-a"])
                    ) { _ in EmptyView() } primary: { Text($0.title) }
                    secondary: { _ in EmptyView() } trailing: { _ in EmptyView() }
                    _ = readOnly.body
                    let empty = NativeList(
                        theme: theme, surface: surface, items: [Entry](), id: \.identity,
                        selection: .multiple(.constant(Set<String>()))
                    ) { _ in EmptyView() } primary: { Text($0.title) }
                    secondary: { _ in EmptyView() } trailing: { _ in EmptyView() }
                    _ = empty.body
                }
            }
        }
        XCTAssertEqual(writes, 0, "Constructing or evaluating the view must not initialize caller selection.")
    }
}
