import DesignTokens
import SwiftUI
import XCTest
@testable import Strata

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

@available(macOS 13, iOS 16, *)
final class StrataRound4SnapshotTests: XCTestCase {
    @MainActor
    func testTabularContractResolvesTokenMetricsAndErrors() throws {
        let metrics = try StrataTabularRowMetrics()
        XCTAssertEqual(metrics.checkboxHitTarget, 44)
        XCTAssertEqual(metrics.minimumRowHeight, 44)
        XCTAssertEqual(metrics.compactCellRadius, 6)

        let expected = StyleTokenError.unknownToken("metrics.failure")
        XCTAssertThrowsError(
            try StrataTabularRowMetrics(dimension: { _ in throw expected })
        ) { error in
            XCTAssertEqual(error as? StyleTokenError, expected)
        }
    }

    @MainActor
    func testHighDensityTabularSnapshotsExportPNGForBothAppearancesAndRTL() throws {
        for mode in Theme.allCases {
            let theme = try StrataTheme(theme: mode, brand: "strata-blue")
            for (name, direction) in [("normal", LayoutDirection.leftToRight), ("rtl", .rightToLeft)] {
                try renderSnapshot(
                    try composite(theme: theme, isLargeMode: false)
                        .environment(\.layoutDirection, direction)
                        .frame(width: 390),
                    named: "round-4-\(mode.rawValue)-\(name)"
                )
                try renderSnapshot(
                    try composite(theme: theme, isLargeMode: true)
                        .environment(\.layoutDirection, direction)
                        .frame(width: 390),
                    named: "round-4-\(mode.rawValue)-\(name)-large"
                )
            }
        }
    }

    @MainActor
    private func composite(theme: StrataTheme, isLargeMode: Bool) throws -> some View {
        let metrics = try StrataTabularRowMetrics()
        let header = try StrataStickySectionHeader(
            theme: theme,
            index: 1,
            completedCount: 0,
            totalCount: 3,
            title: "弹力带俯身髋部伸展",
            isLargeMode: isLargeMode
        ) {
            Image(systemName: "ellipsis")
                .frame(width: 44, height: 44)
        }
        return VStack(spacing: 0) {
            header
            HStack(spacing: metrics.controlSpacing) {
                Text("1")
                    .frame(width: metrics.indexWidth)
                Image(systemName: "circle")
                    .frame(width: metrics.checkboxHitTarget, height: metrics.checkboxHitTarget)
                VStack(alignment: .leading, spacing: 2) {
                    Text("0 lb")
                    StrataInlineHint(theme: theme, label: "建议重量", hint: "建议 0lb")
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("12")
                    StrataInlineHint(theme: theme, label: "建议次数", hint: "建议 12")
                }
                Text("RPE 8")
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 6)
                    .frame(minHeight: metrics.compactBadgeHeight)
                    .background(theme.accentSubtle, in: Capsule())
            }
            .frame(minHeight: metrics.minimumRowHeight)
            .padding(.horizontal, 12)
            StrataBottomSlot(isActive: true) {
                Text("↳ 85% 递减组")
                    .frame(maxWidth: .infinity, minHeight: metrics.minimumRowHeight, alignment: .leading)
                    .padding(.horizontal, 12)
                    .transition(StrataMotion.subRowTransition(reduceMotion: false))
            }
            StrataBottomSlot(isActive: false) {
                Text("inactive")
            }
            StrataDockedBar(theme: theme, style: .solid) {
                Text("+ 添加动作")
                    .font(.subheadline.weight(.semibold))
            }
        }
        .background(theme.surface)
        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
    }

    @MainActor
    private func renderSnapshot<V: View>(_ view: V, named: String) throws {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        let data: Data?
        #if os(macOS)
        if let image = renderer.nsImage,
           let tiff = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiff) {
            data = bitmap.representation(using: .png, properties: [:])
        } else {
            data = nil
        }
        #elseif canImport(UIKit)
        data = renderer.uiImage?.pngData()
        #else
        data = nil
        #endif

        guard let data else {
            XCTFail("ImageRenderer did not produce PNG data for \(named)")
            return
        }
        XCTAssertEqual(Array(data.prefix(8)), [137, 80, 78, 71, 13, 10, 26, 10])
        let directory = snapshotDirectory()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try data.write(to: directory.appendingPathComponent("\(named).png"))
    }

    private func snapshotDirectory() -> URL {
        if let path = ProcessInfo.processInfo.environment["STRATA_SNAPSHOT_DIR"], !path.isEmpty {
            return URL(fileURLWithPath: path, isDirectory: true)
        }
        return FileManager.default.temporaryDirectory.appendingPathComponent("strata-snapshots/round-4")
    }
}
