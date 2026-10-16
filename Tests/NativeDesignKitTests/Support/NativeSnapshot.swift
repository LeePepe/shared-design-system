#if os(macOS)
import AppKit
import SwiftUI
import XCTest

/// Opt-in evidence capture. PNG files stay outside the source tree.
@MainActor
enum NativeSnapshot {
    @discardableResult
    static func capture<Content: View>(
        _ name: String,
        width: CGFloat,
        height: CGFloat,
        @ViewBuilder content: () -> Content
    ) throws -> URL? {
        guard let directory = ProcessInfo.processInfo.environment["NDK_SNAPSHOT_DIR"] else { return nil }
        _ = NSApplication.shared
        let root = content().frame(width: width, height: height)
        let view = NSHostingView(rootView: root)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.borderless], backing: .buffered, defer: false
        )
        window.contentView = view
        window.orderFrontRegardless()
        view.layoutSubtreeIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.15))
        let bitmap = try XCTUnwrap(view.bitmapImageRepForCachingDisplay(in: view.bounds))
        view.cacheDisplay(in: view.bounds, to: bitmap)
        let data = try XCTUnwrap(bitmap.representation(using: .png, properties: [:]))
        let folder = URL(fileURLWithPath: directory, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let url = folder.appendingPathComponent(name).appendingPathExtension("png")
        try data.write(to: url)
        window.orderOut(nil)
        return url
    }
}
#endif
