import AppKit
import SwiftUI
import XCTest

/// Renders the exact sample Catalog source through macOS's NSHostingView. Works without
/// XCUIAutomation's desktop session; this proves rendering, not macOS UI interaction.
@MainActor
final class NativeRenderTests: XCTestCase {
    func testRenderedMacOSMatrix() throws {
        _ = NSApplication.shared
        let output = ProcessInfo.processInfo.environment["NDK_EVIDENCE_DIR"].map { URL(fileURLWithPath: $0) }
        for width in [480.0, 1120.0] {
            for appearance in ["light", "dark"] {
                for page in ["Buttons", "Entry", "Values", "Motion"] {
                    let config = FixtureConfiguration(dark: appearance == "dark", accessible: false,
                        rtl: false, narrow: width == 480, page: page, allowsGlass: false)
                    try render(config: config, width: width, name: "mac-\(Int(width))-\(appearance)-\(page)", output: output)
                }
            }
        }
        for appearance in ["light", "dark"] {
            let config = FixtureConfiguration(dark: appearance == "dark", accessible: true,
                                               rtl: false, narrow: true, page: "Motion", allowsGlass: false)
            try render(config: config, width: 480, name: "mac-accessibility-\(appearance)-Motion", output: output)
        }
    }

    private func render(config: FixtureConfiguration, width: Double, name: String, output: URL?) throws {
        let resources = try FixtureResources(config: config, bundle: Bundle(for: Self.self))
        let root = Catalog(resources: resources, config: config)
            .preferredColorScheme(config.dark ? .dark : .light)
            .environment(\.controlActiveState, .key)
            .environment(\.dynamicTypeSize, config.accessible ? .accessibility3 : .large)
            .environment(\.layoutDirection, config.rtl ? .rightToLeft : .leftToRight)
        let host = NSHostingView(rootView: root)
        host.appearance = NSAppearance(named: config.dark ? .darkAqua : .aqua)
        host.frame = NSRect(x: 0, y: 0, width: width, height: 1000)
        let window = NSWindow(contentRect: host.frame, styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentView = host
        host.layoutSubtreeIfNeeded()
        // Native layout/preferences settle on the main run loop before bitmap capture.
        RunLoop.main.run(until: Date().addingTimeInterval(0.2))
        host.layoutSubtreeIfNeeded()
        let bitmap = try XCTUnwrap(host.bitmapImageRepForCachingDisplay(in: host.bounds))
        host.cacheDisplay(in: host.bounds, to: bitmap)
        let png = try XCTUnwrap(bitmap.representation(using: .png, properties: [:]))
        XCTAssertGreaterThan(png.count, 10_000, "A real populated native rendering is required")
        let attachment = XCTAttachment(data: png, uniformTypeIdentifier: "public.png")
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
        if let output {
            try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
            try png.write(to: output.appendingPathComponent(name + ".png"))
        }
        window.orderOut(nil)
    }
}
