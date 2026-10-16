import DesignTokens
import SwiftUI
import XCTest
@testable import NativeDesignKit

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

final class NativeTextFieldTests: XCTestCase {
    @MainActor
    func testNativeEditingWritesTheCallerBindingWithoutRewritingInput() throws {
        let text = TextStorage("Initial value")
        let theme = try NativeDesignTheme(theme: .light, brand: "ocean")
        let content = NativeTextField(theme: theme, text: text.binding, prompt: Text("Enter a value")) {
            Text("Display name")
        }

        try withHostedTextField(content) { field in
            #if os(macOS)
            XCTAssertEqual(field.stringValue, "Initial value")
            XCTAssertNotNil(field.delegate)
            field.stringValue = "  Caller text — 原样  "
            field.delegate?.controlTextDidChange?(
                Notification(name: NSControl.textDidChangeNotification, object: field)
            )
            #elseif os(iOS)
            XCTAssertEqual(field.text, "Initial value")
            field.text = "  Caller text — 原样  "
            field.sendActions(for: .editingChanged)
            #endif
            XCTAssertEqual(text.value, "  Caller text — 原样  ")
        }
    }

    @MainActor
    func testDisabledEnvironmentReachesTheNativeInput() throws {
        let text = TextStorage("Unavailable")
        let theme = try NativeDesignTheme(theme: .dark, brand: "graphite")
        let content = NativeTextField(theme: theme, text: text.binding) {
            Label("Display name", systemImage: "person")
        }
        .disabled(true)

        try withHostedTextField(content) { field in
            XCTAssertFalse(field.isEnabled)
        }
        XCTAssertEqual(text.value, "Unavailable")
    }

    @MainActor
    func testNativeSubmitReachesTheCaller() throws {
        let text = TextStorage("Ready")
        var submissions = 0
        let theme = try NativeDesignTheme(theme: .light, brand: "ocean")
        let content = NativeTextField(theme: theme, text: text.binding) {
            Text("Display name")
        }
        .onSubmit { submissions += 1 }

        try withHostedTextField(content) { field in
            #if os(macOS)
            let action = try XCTUnwrap(field.action)
            XCTAssertTrue(field.sendAction(action, to: field.target))
            #elseif os(iOS)
            field.sendActions(for: .editingDidEndOnExit)
            #endif
            XCTAssertEqual(submissions, 1)
        }
    }

    #if os(macOS)
    @MainActor
    func testScreenshotBoards() throws {
        for mode in Theme.allCases {
            for brand in ["ocean", "graphite"] {
                let theme = try NativeDesignTheme(theme: mode, brand: brand)
                let scheme: ColorScheme = mode == .light ? .light : .dark
                let name = "textfield-\(brand)-\(mode)"
                try NativeSnapshot.capture("\(name)-wide", width: 640, height: 670) {
                    TextFieldBoard(theme: theme, brand: brand)
                        .environment(\.colorScheme, scheme)
                }
                try NativeSnapshot.capture("\(name)-narrow-accessibility", width: 320, height: 1120) {
                    TextFieldBoard(theme: theme, brand: brand)
                        .environment(\.colorScheme, scheme)
                        .dynamicTypeSize(.accessibility3)
                }
            }
        }
    }
    #endif

    @MainActor
    private final class TextStorage {
        var value: String

        init(_ value: String) { self.value = value }

        var binding: Binding<String> {
            Binding(get: { self.value }, set: { self.value = $0 })
        }
    }

    #if os(macOS)
    @MainActor
    private func withHostedTextField<Content: View>(
        _ content: Content,
        assertion: (NSTextField) throws -> Void
    ) throws {
        _ = NSApplication.shared
        let hosting = NSHostingView(rootView: content.padding(16).frame(width: 320, height: 180))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 180),
            styleMask: [.borderless], backing: .buffered, defer: false
        )
        window.contentView = hosting
        window.orderFrontRegardless()
        defer { window.orderOut(nil) }
        hosting.layoutSubtreeIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
        let field: NSTextField = try XCTUnwrap(firstSubview(in: hosting, matching: NSTextField.self))
        try assertion(field)
    }

    @MainActor
    private func firstSubview<T: NSView>(in view: NSView, matching type: T.Type) -> T? {
        if let result = view as? T { return result }
        for child in view.subviews {
            if let result = firstSubview(in: child, matching: type) { return result }
        }
        return nil
    }
    #elseif os(iOS)
    @MainActor
    private func withHostedTextField<Content: View>(
        _ content: Content,
        assertion: (UITextField) throws -> Void
    ) throws {
        let hosting = UIHostingController(rootView: content.padding(16).frame(width: 320, height: 180))
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 180))
        window.rootViewController = hosting
        window.makeKeyAndVisible()
        defer { window.isHidden = true }
        hosting.view.layoutIfNeeded()
        let field: UITextField = try XCTUnwrap(firstSubview(in: hosting.view, matching: UITextField.self))
        try assertion(field)
    }

    @MainActor
    private func firstSubview<T: UIView>(in view: UIView, matching type: T.Type) -> T? {
        if let result = view as? T { return result }
        for child in view.subviews {
            if let result = firstSubview(in: child, matching: type) { return result }
        }
        return nil
    }
    #endif
}

#if os(macOS)
private struct TextFieldBoard: View {
    let theme: NativeDesignTheme
    let brand: String
    @State private var name = "River Chen"
    @State private var empty = ""
    @State private var unavailable = "Managed by your organization"
    @State private var contact = "example"

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("NativeTextField").font(.title2.weight(.semibold))
                Text("Synthetic examples · \(brand) · \(theme.mode == .light ? "Light" : "Dark")")
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryForeground)
            }

            NativeTextField(theme: theme, text: $name) {
                Text("Display name")
            }
            NativeTextField(theme: theme, text: $empty, prompt: Text("Enter a short note")) {
                Text("A longer label that can wrap at narrow widths")
            }
            NativeTextField(theme: theme, text: $unavailable) {
                Text("Unavailable field")
            }
            .disabled(true)
            VStack(alignment: .leading, spacing: 8) {
                NativeTextField(theme: theme, text: $contact, prompt: Text("name@example.com")) {
                    Text("Email address")
                }
                Label("Enter a complete email address.", systemImage: "exclamationmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(theme.critical)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .foregroundStyle(theme.foreground)
        .background(theme.canvas)
    }
}
#endif
