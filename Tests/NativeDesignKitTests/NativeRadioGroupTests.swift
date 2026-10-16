import NativeDesignKit
import SwiftUI
import XCTest

@MainActor
final class NativeRadioGroupTests: XCTestCase {
    private struct Choice: Hashable { let id: String }

    func testPublicConstructionAcceptsCallerHashableIdentityAndGenericBuilders() throws {
        var selected = Choice(id: "second")
        var writes = 0
        let binding = Binding(get: { selected }, set: { selected = $0; writes += 1 })
        for brand in ["ocean", "graphite"] {
            let theme = try NativeDesignTheme(theme: .light, brand: brand)
            let group = NativeRadioGroup(theme: theme, selection: binding) {
                Label("Synthetic choice", systemImage: "list.bullet")
            } options: {
                Text("First").tag(Choice(id: "first"))
                Text("Second").tag(Choice(id: "second"))
            }
            _ = group.body
            XCTAssertEqual(selected, Choice(id: "second"))
            XCTAssertEqual(writes, 0, "Construction must not rewrite caller selection.")
        }
    }

    func testPublicConstructionSupportsDynamicTaggedOptionsAndOptionalSelection() throws {
        let theme = try NativeDesignTheme(theme: .dark, brand: "ocean")
        let group = NativeRadioGroup(theme: theme, selection: .constant(String?.none)) {
            Text("Caller-owned label")
        } options: {
            ForEach(["stable-c", "stable-a"], id: \.self) { value in
                Text(value).tag(Optional(value))
            }
        }
        _ = group.body
    }
}
