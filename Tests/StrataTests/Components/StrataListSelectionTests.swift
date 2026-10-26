import SwiftUI
import XCTest
@testable import Strata

final class StrataListSelectionTests: XCTestCase {
    @MainActor
    func testSingleSelectionReplacesWithoutTogglingOrRedundantWrites() {
        var value: String?
        var writes: [String?] = []
        let selection = StrataListSelection.single(Binding(get: { value }, set: { value = $0; writes.append($0) }))
        XCTAssertTrue(selection.isInteractive)
        XCTAssertFalse(selection.contains("first"))
        selection.activate("first", isEnabled: true)
        XCTAssertTrue(selection.contains("first"))
        selection.activate("first", isEnabled: true)
        XCTAssertEqual(writes, ["first"])
        selection.activate("second", isEnabled: true)
        XCTAssertEqual(value, "second")
        XCTAssertFalse(selection.contains("first"))
        XCTAssertTrue(selection.contains("second"))
        value = nil
        XCTAssertFalse(selection.contains("second"), "Caller changes are read through the binding.")
    }

    @MainActor
    func testMultipleSelectionTogglesOnlyActivatedIdentityAndPreservesUnavailableIDs() {
        var values: Set<String> = ["external"]
        let selection = StrataListSelection.multiple(Binding(get: { values }, set: { values = $0 }))
        selection.activate("first", isEnabled: true)
        selection.activate("second", isEnabled: true)
        XCTAssertEqual(values, ["external", "first", "second"])
        selection.activate("first", isEnabled: true)
        XCTAssertEqual(values, ["external", "second"])
        values = ["caller-update"]
        XCTAssertTrue(selection.contains("caller-update"))
        XCTAssertFalse(selection.contains("second"))
    }

    @MainActor
    func testDisabledSelectionAndReadOnlyNeverWrite() {
        var single: Int? = 8
        var multiple: Set<Int> = [8]
        var writes = 0
        let singleSelection = StrataListSelection.single(Binding(get: { single }, set: { single = $0; writes += 1 }))
        let multipleSelection = StrataListSelection.multiple(Binding(get: { multiple }, set: { multiple = $0; writes += 1 }))
        singleSelection.activate(9, isEnabled: false)
        multipleSelection.activate(9, isEnabled: false)
        multipleSelection.activate(8, isEnabled: false)
        XCTAssertEqual(single, 8)
        XCTAssertEqual(multiple, [8])
        XCTAssertEqual(writes, 0)
        let readOnly = StrataListSelection.readOnly(Set([8]))
        XCTAssertFalse(readOnly.isInteractive)
        for enabled in [true, false] { readOnly.activate(9, isEnabled: enabled) }
        XCTAssertTrue(readOnly.contains(8))
        XCTAssertFalse(readOnly.contains(9))
    }
}
