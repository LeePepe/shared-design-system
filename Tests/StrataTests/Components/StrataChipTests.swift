import DesignTokens
import SwiftUI
import XCTest
@testable import Strata

final class StrataChipTests: XCTestCase {
    @MainActor
    func testPublicStaticAndRemovableConstructionForEveryToneAndTheme() throws {
        for brand in DesignTokens.brandIDs {
            for mode in Theme.allCases {
                let theme = try StrataTheme(theme: mode, brand: brand)
                let selection = Binding<String?>(
                    get: { nil },
                    set: { _ in }
                )
                _ = StrataFilterChipRail(
                    theme: theme,
                    items: [StrataFilterItem(id: "all", title: "All")],
                    selection: selection
                )
                _ = StrataStatusRing(theme: theme, value: 0.5, total: 1)
                for tone in [StrataChipTone.neutral, .accent, .critical] {
                    _ = StrataChip(theme: theme, tone: tone) { Text("Caller label") }
                    _ = StrataChip(theme: theme, tone: tone,
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
                StrataChipActivation.perform(isEnabled: enabled) { count += 1 }
            }
            XCTAssertEqual(count, enabled ? 3 : 0)
        }
    }

    func testGrowingShapeContainsPaddedMultilineLabelCorners() {
        let rect = CGRect(x: 0, y: 0, width: 240, height: 240)
        let label = rect.insetBy(dx: 12, dy: 8)
        let corners = [CGPoint(x: label.minX, y: label.minY), CGPoint(x: label.maxX, y: label.minY),
                       CGPoint(x: label.minX, y: label.maxY), CGPoint(x: label.maxX, y: label.maxY)]
        XCTAssertTrue(corners.allSatisfy { StrataChipShape().path(in: rect).contains($0) })
        XCTAssertFalse(corners.allSatisfy { Capsule().path(in: rect).contains($0) },
                       "The control must exercise the multiline capsule regression.")
    }

    func testRemovalTargetUsesCompactVisualBoxAndExpandedHitTarget() {
        XCTAssertEqual(StrataChipRemovalMetrics.visualIconSize, 18)
        XCTAssertEqual(StrataChipRemovalMetrics.hitTargetSize, 44)
    }

    @MainActor
    @available(macOS 13, iOS 16, *)
    func testStaticAndRemovableChipsRenderAtTheSameVisualHeight() throws {
        let scale: CGFloat = 2
        let expectedWidthDelta = Int((
            StrataChipRemovalMetrics.visualLeadingSpacing
                + StrataChipRemovalMetrics.visualIconSize
                + StrataChipRemovalMetrics.visualTrailingInset - 12
        ) * scale)
        XCTAssertEqual(expectedWidthDelta, 50)

        for mode in Theme.allCases {
            let theme = try StrataTheme(theme: mode, brand: DesignTokens.brandIDs[0])
            for tone in [StrataChipTone.neutral, .accent, .critical] {
                let staticImage = try XCTUnwrap(
                    ImageRenderer(
                        content: StrataChip(theme: theme, tone: tone) {
                            Text("Caller label")
                        }
                    ).renderedImage(scale: scale)
                )
                let removableImage = try XCTUnwrap(
                    ImageRenderer(
                        content: StrataChip(
                            theme: theme,
                            tone: tone,
                            removalAccessibilityLabel: Text("Remove caller label"),
                            onRemove: {}
                        ) {
                            Text("Caller label")
                        }
                    ).renderedImage(scale: scale)
                )

                XCTAssertEqual(staticImage.height, 72, "\(mode), \(tone)")
                XCTAssertEqual(removableImage.height, 72, "\(mode), \(tone)")
                XCTAssertEqual(staticImage.height, removableImage.height)
                XCTAssertEqual(removableImage.width - staticImage.width, expectedWidthDelta,
                               "Removal must reserve the icon and a positive label gap: \(mode), \(tone)")
            }
        }
    }
}

@available(macOS 13, iOS 16, *)
private extension ImageRenderer {
    @MainActor
    func renderedImage(scale: CGFloat) -> CGImage? {
        self.scale = scale
        return cgImage
    }
}
