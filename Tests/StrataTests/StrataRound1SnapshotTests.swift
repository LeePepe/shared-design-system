import Foundation
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
final class StrataRound1SnapshotTests: XCTestCase {
    @MainActor
    func testRound1ComponentsRenderPNGBaselinesInBothThemes() throws {
        for mode in Theme.allCases {
            let theme = try StrataTheme(theme: mode, brand: "ocean")
            try renderSnapshot(
                StrataButton(theme: theme, variant: .primary, isLoading: false, action: {}) {
                    Text("Primary")
                } loadingLabel: {
                    Text("Saving")
                },
                named: "button-primary-\(mode.rawValue)"
            )
            try renderSnapshot(
                StrataButton(theme: theme, variant: .toolbar, isLoading: false, action: {}) {
                    Image(systemName: "checkmark")
                } loadingLabel: {
                    EmptyView()
                },
                named: "button-toolbar-\(mode.rawValue)"
            )
            try renderSnapshot(
                VStack(spacing: 8) {
                    StrataProgressRing(theme: theme, value: 3, total: 5)
                    StrataStatusMetricBadge(theme: theme, value: "3/5", progress: 3, total: 5)
                }
                .padding()
                .background(theme.canvas),
                named: "status-metric-\(mode.rawValue)"
            )
            try renderSnapshot(
                VStack(spacing: 12) {
                    Text("Interactive accent")
                        .font(.headline)
                    Text("WCAG AA pair")
                        .foregroundStyle(theme.onInteractiveAccent)
                        .padding()
                        .background(theme.interactiveAccent, in: RoundedRectangle(cornerRadius: 12))
                }
                .foregroundStyle(theme.foreground)
                .padding()
                .background(theme.canvas),
                named: "contrast-card-\(mode.rawValue)"
            )
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
        let width = bytes[16..<20].reduce(0) { ($0 << 8) | Int($1) }
        let height = bytes[20..<24].reduce(0) { ($0 << 8) | Int($1) }
        XCTAssertGreaterThan(width, 0, "\(named) width")
        XCTAssertGreaterThan(height, 0, "\(named) height")

        let directory = snapshotDirectory()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try data.write(to: directory.appendingPathComponent("\(named).png"))
    }

    private func snapshotDirectory() -> URL {
        if let path = ProcessInfo.processInfo.environment["STRATA_SNAPSHOT_DIR"], !path.isEmpty {
            return URL(fileURLWithPath: path, isDirectory: true)
        }
        return FileManager.default.temporaryDirectory
            .appendingPathComponent("strata-snapshots/round-1", isDirectory: true)
    }
}
