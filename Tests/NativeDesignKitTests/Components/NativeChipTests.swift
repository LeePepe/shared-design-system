import DesignTokens
import SwiftUI
import XCTest
@testable import NativeDesignKit

final class NativeChipTests: XCTestCase {
    @MainActor
    func testPublicStaticAndRemovableConstructionForEveryToneAndTheme() throws {
        for brand in DesignTokens.brandIDs {
            for mode in Theme.allCases {
                let theme = try NativeDesignTheme(theme: mode, brand: brand)
                for tone in [NativeChipTone.neutral, .accent, .critical] {
                    _ = NativeChip(theme: theme, tone: tone) { Text("Caller label") }
                    _ = NativeChip(theme: theme, tone: tone,
                                   removalAccessibilityLabel: Text("Remove caller label"), onRemove: {}) {
                        Label("Caller label", systemImage: "tag")
                    }
                }
            }
        }
    }

    func testDisabledRemovalBlocksRepeatedDispatch() {
        for enabled in [false, true] {
            var count = 0
            for _ in 0..<3 {
                NativeChipActivation.perform(isEnabled: enabled) { count += 1 }
            }
            XCTAssertEqual(count, enabled ? 3 : 0)
        }
    }

    func testGrowingShapeContainsPaddedMultilineLabelCorners() {
        let rect = CGRect(x: 0, y: 0, width: 240, height: 240)
        let label = rect.insetBy(dx: 12, dy: 8)
        let corners = [CGPoint(x: label.minX, y: label.minY), CGPoint(x: label.maxX, y: label.minY),
                       CGPoint(x: label.minX, y: label.maxY), CGPoint(x: label.maxX, y: label.maxY)]
        XCTAssertTrue(corners.allSatisfy { NativeChipShape().path(in: rect).contains($0) })
        XCTAssertFalse(corners.allSatisfy { Capsule().path(in: rect).contains($0) },
                       "The control must exercise the multiline capsule regression.")
    }
}
