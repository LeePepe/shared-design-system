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
    func testMotionRespectsReduceMotion() throws {
        let motion = try StrataMotion()
        XCTAssertNil(StrataMotion.animation(motion.standard, reduceMotion: true))
        XCTAssertNotNil(StrataMotion.animation(motion.standard, reduceMotion: false))
        XCTAssertNoThrow(try StrataMotion.snappy())
        XCTAssertNoThrow(try StrataMotion.gentle())
    }

    @MainActor
    func testMotionAndStickyHeaderPropagateTokenErrorsUnchanged() throws {
        let expected = StyleTokenError.unknownToken("spring.failure")
        XCTAssertThrowsError(
            try StrataMotion(spring: { _ in throw expected })
        ) { error in
            XCTAssertEqual(error as? StyleTokenError, expected)
        }

        let theme = try StrataTheme(theme: .light, brand: "ocean")
        let borderError = StyleTokenError.unknownToken("border.failure")
        XCTAssertThrowsError(
            try StrataStickySectionHeader(
                theme: theme,
                index: 1,
                completedCount: 0,
                totalCount: 1,
                title: "Section",
                border: { _ in throw borderError }
            ) {
                EmptyView()
            }
        ) { error in
            XCTAssertEqual(error as? StyleTokenError, borderError)
        }
    }

    @MainActor
    func testStickyHeaderRendersNormalLargeCompletedAndRTLInBothThemes() throws {
        for mode in Theme.allCases {
            let theme = try StrataTheme(theme: mode, brand: "ocean")
            try renderSnapshot(
                try header(theme: theme, title: "Strength", isLargeMode: false, completedCount: 2)
                    .frame(width: 390),
                named: "sticky-header-normal-\(mode.rawValue)"
            )
            try renderSnapshot(
                try header(theme: theme, title: "弹力带俯身髋部伸展", isLargeMode: true, completedCount: 2)
                    .frame(width: 390),
                named: "sticky-header-large-\(mode.rawValue)"
            )
            try renderSnapshot(
                try header(theme: theme, title: "Completed", isLargeMode: false, completedCount: 3)
                    .frame(width: 390),
                named: "sticky-header-completed-\(mode.rawValue)"
            )
            try renderSnapshot(
                try header(theme: theme, title: "RTL section", isLargeMode: true, completedCount: 1)
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
    ) throws -> some View {
        try StrataStickySectionHeader(
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
        let width = bytes[16...19].reduce(UInt32(0)) { ($0 << 8) | UInt32($1) }
        let height = bytes[20...23].reduce(UInt32(0)) { ($0 << 8) | UInt32($1) }
        XCTAssertEqual(width, 780, "\(named) PNG width")
        XCTAssertLessThanOrEqual(height, 88, "\(named) sticky-header PNG height")
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
