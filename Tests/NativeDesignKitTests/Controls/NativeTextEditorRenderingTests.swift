import DesignTokens
import SwiftUI
import XCTest
@testable import NativeDesignKit
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Exercises the actual iOS 15/macOS 12 route, not scrollContentBackground(.hidden).
/// Native-host assertions catch a theme mismatch even on SDKs newer than the floors.
@MainActor
final class NativeTextEditorRenderingTests: XCTestCase {
    func testForcedLegacyDarkEditorInsideLightNativeHost() async throws {
        try await assertLegacyEditor(theme: .dark, surrounding: .light)
    }

    func testForcedLegacyLightEditorInsideDarkNativeHost() async throws {
        try await assertLegacyEditor(theme: .light, surrounding: .dark)
    }

    private func assertLegacyEditor(theme: Theme, surrounding: ColorScheme) async throws {
        let explicitTheme = try NativeDesignTheme(theme: theme)
        let metrics = NativeControlMetrics(padding: 12, spacing: 8, cornerRadius: 8,
            minimumHitSize: 44, iconSize: 20, borderWidth: 1, disabledOpacity: 0.5)
        let content = AnyView(VStack(alignment: .leading, spacing: 16) {
            Text("Surrounding native host: \(surrounding == .dark ? "dark" : "light")")
            NativeTextEditor(text: .constant("Readable native editor\nExplicit \(theme) theme"),
                theme: explicitTheme, metrics: metrics, accessibilityLabel: Text("Notes"),
                forceLegacyBackground: true) { Text(verbatim: "Explicit \(theme) editor") }
                .frame(height: 180)
        }.padding(20).frame(width: 420, height: 300, alignment: .topLeading)
            .background(.background).environment(\.colorScheme, surrounding))
        let host = EditorRenderHost(content, surrounding: surrounding)
        defer { host.close() }
        // Let native representable creation, trait propagation and text layout settle.
        for _ in 0..<20 {
            host.layout()
            try await Task.sleep(nanoseconds: 25_000_000)
        }
        let editor = try XCTUnwrap(host.editor)
        XCTAssertTrue(editor.isEditable, "Must retain the real editable native TextEditor")
        #if os(macOS)
        XCTAssertEqual(editor.string, "Readable native editor\nExplicit \(theme) theme")
        XCTAssertEqual(host.appearance, surrounding == .dark ? .darkAqua : .aqua)
        XCTAssertEqual(editor.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]),
                       theme == .dark ? .darkAqua : .aqua)
        var foreground: NSColor?
        var background: NSColor?
        editor.effectiveAppearance.performAsCurrentDrawingAppearance {
            foreground = editor.textColor?.usingColorSpace(.sRGB)
            background = editor.backgroundColor.usingColorSpace(.sRGB)
        }
        let fg = try XCTUnwrap(foreground), bg = try XCTUnwrap(background)
        let textRGB = [fg.redComponent, fg.greenComponent, fg.blueComponent]
        let backgroundRGB = [bg.redComponent, bg.greenComponent, bg.blueComponent]
        #else
        XCTAssertEqual(editor.text, "Readable native editor\nExplicit \(theme) theme")
        XCTAssertEqual(host.appearance, surrounding == .dark ? .dark : .light)
        XCTAssertEqual(editor.traitCollection.userInterfaceStyle, theme == .dark ? .dark : .light)
        let fg = try XCTUnwrap(editor.textColor).resolvedColor(with: editor.traitCollection)
        let bg = try XCTUnwrap(editor.backgroundColor).resolvedColor(with: editor.traitCollection)
        func rgb(_ color: UIColor) -> [CGFloat] {
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            XCTAssertTrue(color.getRed(&r, green: &g, blue: &b, alpha: &a))
            XCTAssertEqual(a, 1, accuracy: 0.01, "Native retained background must be opaque")
            return [r, g, b]
        }
        let textRGB = rgb(fg), backgroundRGB = rgb(bg)
        #endif
        let textLuminance = luminance(textRGB), backgroundLuminance = luminance(backgroundRGB)
        XCTAssertGreaterThan((max(textLuminance, backgroundLuminance) + 0.05) /
                             (min(textLuminance, backgroundLuminance) + 0.05), 4.5,
                             "Actual native text and retained background must remain readable")
        if theme == .dark {
            XCTAssertLessThan(backgroundLuminance, 0.2)
            XCTAssertGreaterThan(textLuminance, 0.7)
        } else {
            XCTAssertGreaterThan(backgroundLuminance, 0.7)
            XCTAssertLessThan(textLuminance, 0.2)
        }
        let png = try XCTUnwrap(host.png())
        XCTAssertGreaterThan(png.count, 2_000)
        let attachment = XCTAttachment(data: png, uniformTypeIdentifier: "public.png")
        attachment.name = "legacy-editor-\(theme)-inside-\(surrounding)-host"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func luminance(_ rgb: [CGFloat]) -> Double {
        let linear = rgb.map { Double($0) <= 0.04045 ? Double($0) / 12.92 : pow((Double($0) + 0.055) / 1.055, 2.4) }
        return zip(linear, [0.2126, 0.7152, 0.0722]).map(*).reduce(0, +)
    }
}

@MainActor
private final class EditorRenderHost {
    #if os(macOS)
    private let window: NSWindow
    private let view: NSHostingView<AnyView>
    var appearance: NSAppearance.Name? { window.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) }
    var editor: NSTextView? { findEditor(in: view) }
    private func findEditor(in view: NSView) -> NSTextView? {
        if let editor = view as? NSTextView { return editor }
        return view.subviews.lazy.compactMap { self.findEditor(in: $0) }.first
    }
    #else
    private let window: UIWindow
    private let controller: UIHostingController<AnyView>
    var appearance: UIUserInterfaceStyle { window.traitCollection.userInterfaceStyle }
    var editor: UITextView? { findEditor(in: controller.view) }
    private func findEditor(in view: UIView) -> UITextView? {
        if let editor = view as? UITextView { return editor }
        return view.subviews.lazy.compactMap { self.findEditor(in: $0) }.first
    }
    #endif

    init(_ root: AnyView, surrounding: ColorScheme) {
        let bounds = CGRect(x: 0, y: 0, width: 420, height: 300)
        #if os(macOS)
        _ = NSApplication.shared
        view = NSHostingView(rootView: root)
        window = NSWindow(contentRect: bounds, styleMask: [.borderless], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.appearance = NSAppearance(named: surrounding == .dark ? .darkAqua : .aqua)
        window.contentView = view
        window.orderFront(nil)
        #else
        controller = UIHostingController(rootView: root)
        window = UIWindow(frame: bounds)
        window.overrideUserInterfaceStyle = surrounding == .dark ? .dark : .light
        window.rootViewController = controller
        window.isHidden = false
        controller.view.frame = bounds
        #endif
        layout()
    }

    func layout() {
        #if os(macOS)
        view.layoutSubtreeIfNeeded()
        #else
        controller.view.layoutIfNeeded()
        #endif
    }

    func close() {
        #if os(macOS)
        window.close()
        #else
        window.isHidden = true
        #endif
    }

    func png() -> Data? {
        layout()
        #if os(macOS)
        guard let bitmap = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return nil }
        view.cacheDisplay(in: view.bounds, to: bitmap)
        return bitmap.representation(using: .png, properties: [:])
        #else
        return UIGraphicsImageRenderer(bounds: controller.view.bounds).pngData { context in
            controller.view.layer.render(in: context.cgContext)
        }
        #endif
    }
}
