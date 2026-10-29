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
final class StrataRound3SnapshotTests: XCTestCase {
    @MainActor
    func testMotionRespectsReduceMotion() {
        XCTAssertNil(StrataMotion.animation(reduceMotion: true))
        XCTAssertNotNil(StrataMotion.animation(reduceMotion: false))
        XCTAssertNotNil(Animation.strataSnappy)
        XCTAssertNotNil(Animation.strataGentle)
    }

    @MainActor
    func testStickyHeaderRendersNormalLargeCompletedAndRTLInBothThemes() throws {
        for mode in Theme.allCases {
            let theme = try StrataTheme(theme: mode, brand: "ocean")
            try renderSnapshot(
                header(theme: theme, title: "Strength", isLargeMode: false, completedCount: 2)
                    .frame(width: 390),
                named: "sticky-header-normal-\(mode.rawValue)"
            )
            try renderSnapshot(
                header(theme: theme, title: "弹力带俯身髋部伸展", isLargeMode: true, completedCount: 2)
                    .frame(width: 390),
                named: "sticky-header-large-\(mode.rawValue)"
            )
            try renderSnapshot(
                header(theme: theme, title: "Completed", isLargeMode: false, completedCount: 3)
                    .frame(width: 390),
                named: "sticky-header-completed-\(mode.rawValue)"
            )
            try renderSnapshot(
                header(theme: theme, title: "RTL section", isLargeMode: true, completedCount: 1)
                    .environment(\.layoutDirection, .rightToLeft)
                    .frame(width: 390),
                named: "sticky-header-rtl-\(mode.rawValue)"
            )
        }
    }

    @ViewBuilder
    @MainActor
    private func header(
        theme: StrataTheme,
        title: String,
        isLargeMode: Bool,
        completedCount: Int
    ) -> some View {
        StrataStickySectionHeader(
            theme: theme,
            index: 2,
            completedCount: completedCount,
            totalCount: 3,
            title: title,
            isLargeMode: isLargeMode
        ) {
            Button("Add", systemImage: "plus") {}
                .labelStyle(.iconOnly)
                .frame(width: 44, height: 44)
        }
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
        let bytes = [UInt8](data)
        XCTAssertEqual(
            Array(bytes.prefix(8)),
            [137, 80, 78, 71, 13, 10, 26, 10],
            "\(named) PNG signature"
        )
        XCTAssertGreaterThanOrEqual(bytes.count, 24, "\(named) PNG IHDR")
        let directory = snapshotDirectory()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try data.write(to: directory.appendingPathComponent("\(named).png"))
    }

    private func snapshotDirectory() -> URL {
        if let path = ProcessInfo.processInfo.environment["STRATA_SNAPSHOT_DIR"], !path.isEmpty {
            return URL(fileURLWithPath: path, isDirectory: true)
        }
        return FileManager.default.temporaryDirectory
            .appendingPathComponent("strata-snapshots/round-3", isDirectory: true)
    }
}
