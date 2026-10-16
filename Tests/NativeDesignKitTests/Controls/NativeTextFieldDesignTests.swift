import DesignTokens
import SwiftUI
import XCTest
@testable import NativeDesignKit
#if os(macOS)
import AppKit
#else
import UIKit
#endif

@MainActor
final class NativeTextFieldDesignTests: XCTestCase {
    func testNativeBezelDoesNotReceiveAdditionalMetricsPadding() throws {
        let theme = try NativeDesignTheme(theme: .light)
        func size(padding: CGFloat) -> CGSize {
            let field = NativeTextField("Name", text: .constant("Studio Notes"),
                theme: theme, metrics: metrics(padding: padding))
                .frame(width: 320).fixedSize(horizontal: false, vertical: true)
            #if os(macOS)
            _ = NSApplication.shared
            return NSHostingView(rootView: field).fittingSize
            #else
            return UIHostingController(rootView: field)
                .sizeThatFits(in: CGSize(width: 320, height: 1_000))
            #endif
        }
        let nativeInsets = size(padding: 0)
        let oversizedMetrics = size(padding: 40)
        XCTAssertEqual(nativeInsets.width, oversizedMetrics.width, accuracy: 0.5)
        XCTAssertEqual(nativeInsets.height, oversizedMetrics.height, accuracy: 0.5,
                       "The system rounded-border style owns its bezel insets")
        XCTAssertGreaterThanOrEqual(nativeInsets.height, metrics(padding: 0).minimumHitSize)
    }

    func testExplicitThemeReachesNativeEditorInsideOppositeAppearance() async throws {
        for explicit in Theme.allCases {
            let surrounding: ColorScheme = explicit == .dark ? .light : .dark
            let theme = try NativeDesignTheme(theme: explicit)
            let content = AnyView(NativeTextField("Name", text: .constant("文稿 Draft"),
                theme: theme, metrics: metrics(padding: 8))
                .environment(\.colorScheme, surrounding))
            let host = TextFieldDesignHost(content, surrounding: surrounding)
            defer { host.close() }
            await host.settle()
            let field = try XCTUnwrap(host.field)
            #if os(macOS)
            XCTAssertEqual(field.stringValue, "文稿 Draft")
            XCTAssertTrue(field.isEditable)
            XCTAssertTrue(field.isBezeled, "Use the native field bezel")
            XCTAssertNotEqual(field.focusRingType, .none, "Keep the native keyboard focus ring")
            XCTAssertEqual(field.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]),
                           explicit == .dark ? .darkAqua : .aqua)
            #else
            XCTAssertEqual(field.text, "文稿 Draft")
            XCTAssertEqual(field.borderStyle, .roundedRect)
            XCTAssertEqual(field.traitCollection.userInterfaceStyle, explicit == .dark ? .dark : .light)
            #endif
        }
    }

    func testDisabledEnvironmentReachesNativeEditor() async throws {
        let content = AnyView(NativeTextField("Name", text: .constant("Read Only"),
            theme: try NativeDesignTheme(theme: .light), metrics: metrics(padding: 8))
            .disabled(true))
        let host = TextFieldDesignHost(content, surrounding: .light)
        defer { host.close() }
        await host.settle()
        let field = try XCTUnwrap(host.field)
        XCTAssertFalse(field.isEnabled, "Disabled must reach the real native control")
    }

    #if os(macOS)
    func testMinimumTargetFocusesNativeEditorOutsideItsBezel() async throws {
        let theme = try NativeDesignTheme(theme: .light)
        let field = NativeTextField("Name", text: .constant("Draft"),
            theme: theme, metrics: metrics(padding: 8)).frame(width: 320, height: 44)
        let host = TextFieldDesignHost(AnyView(field), surrounding: .light,
                                       height: 44)
        defer { host.close() }
        await host.settle()
        let nativeField = try XCTUnwrap(host.field)
        let bezel = nativeField.convert(nativeField.bounds, to: nil)
        for targetEdge in [NSPoint(x: 2, y: 2), NSPoint(x: 318, y: 42)] {
            host.resignFocus()
            await host.settle()
            XCTAssertFalse(bezel.contains(targetEdge), "Exercise the target outside the visible bezel")
            host.click(at: targetEdge)
            await host.settle()
            XCTAssertNotNil(nativeField.currentEditor(), "The complete target must focus the real editor")
        }
    }

    func testDisabledMinimumTargetCannotFocusOrEdit() async throws {
        let state = TextFieldDesignState()
        let field = NativeTextField("Name", text: Binding(get: { state.text }, set: { state.text = $0 }),
            theme: try NativeDesignTheme(theme: .light), metrics: metrics(padding: 8))
            .onSubmit { state.submissions += 1 }
            .disabled(true).frame(width: 320, height: 44)
        let host = TextFieldDesignHost(AnyView(field), surrounding: .light, height: 44)
        defer { host.close() }
        await host.settle()
        let nativeField = try XCTUnwrap(host.field)
        for point in [NSPoint(x: 2, y: 2), NSPoint(x: 160, y: 22)] {
            host.click(at: point)
            host.pressKey("x", keyCode: 7)
            host.pressKey("\r", keyCode: 36)
            await host.settle()
            XCTAssertNil(nativeField.currentEditor(), "Disabled target activation must not focus the field")
            XCTAssertEqual(state.text, "Draft")
            XCTAssertEqual(state.submissions, 0)
        }
    }

    func testNativeWordSelectionEditingAndReturnSubmission() async throws {
        let state = TextFieldDesignState()
        let field = NativeTextField("Name", text: Binding(get: { state.text }, set: { state.text = $0 }),
            theme: try NativeDesignTheme(theme: .light), metrics: metrics(padding: 8))
            .onSubmit { state.submissions += 1 }.frame(width: 320, height: 44)
        let host = TextFieldDesignHost(AnyView(field), surrounding: .light, height: 44)
        defer { host.close() }
        await host.settle()
        let nativeField = try XCTUnwrap(host.field)
        let bezel = nativeField.convert(nativeField.bounds, to: nil)
        host.click(at: NSPoint(x: bezel.minX + 24, y: bezel.midY), clickCount: 2)
        await host.settle()
        let editor = try XCTUnwrap(nativeField.currentEditor())
        XCTAssertGreaterThan(editor.selectedRange.length, 0, "Native double-click word selection must survive target activation")
        host.pressKey("x", keyCode: 7)
        await host.settle()
        XCTAssertEqual(state.text, "x", "Typing must replace the native selection and update the caller binding")
        XCTAssertEqual(editor.string, "x")
        host.pressKey("\r", keyCode: 36)
        await host.settle()
        XCTAssertEqual(state.submissions, 1, "Native Return must reach the caller's onSubmit exactly once")
    }

    func testCallerFocusedModifierStillControlsAndObservesNativeFocus() async throws {
        let state = TextFieldDesignState()
        let field = CallerFocusedTextField(theme: try NativeDesignTheme(theme: .light),
                                           metrics: metrics(padding: 8), state: state)
        let host = TextFieldDesignHost(AnyView(field), surrounding: .light, height: 44)
        defer { host.close() }
        await host.settle()
        let nativeField = try XCTUnwrap(host.field)
        XCTAssertNil(nativeField.currentEditor(), "The component must not request initial focus")
        XCTAssertFalse(state.observedFocus)
        state.requestedFocus = true
        await host.settle()
        XCTAssertNotNil(nativeField.currentEditor(), "Caller .focused(true) must reach the native editor")
        XCTAssertTrue(state.observedFocus)
        state.requestedFocus = false
        await host.settle()
        XCTAssertNil(nativeField.currentEditor(), "Caller .focused(false) must dismiss native focus")
        XCTAssertFalse(state.observedFocus)
        host.click(at: NSPoint(x: 160, y: 2))
        await host.settle()
        XCTAssertNotNil(nativeField.currentEditor())
        XCTAssertTrue(state.observedFocus, "Target activation must update the caller's focus binding")
    }
    #endif

    private func metrics(padding: CGFloat) -> NativeControlMetrics {
        NativeControlMetrics(padding: padding, spacing: 8, cornerRadius: 8,
            minimumHitSize: 44, iconSize: 20, borderWidth: 1, disabledOpacity: 0.5)
    }
}

@MainActor
private final class TextFieldDesignState: ObservableObject {
    @Published var text = "Draft"
    @Published var requestedFocus = false
    var observedFocus = false
    var submissions = 0
}

private struct CallerFocusedTextField: View {
    let theme: NativeDesignTheme
    let metrics: NativeControlMetrics
    @ObservedObject var state: TextFieldDesignState
    @FocusState private var isFocused: Bool

    var body: some View {
        if #available(iOS 17, macOS 14, *) {
            field
                .onChange(of: state.requestedFocus) { _, value in isFocused = value }
                .onChange(of: isFocused) { _, value in state.observedFocus = value }
        } else {
            field
                .onChange(of: state.requestedFocus) { isFocused = $0 }
                .onChange(of: isFocused) { state.observedFocus = $0 }
        }
    }

    private var field: some View {
        NativeTextField("Name", text: $state.text, theme: theme, metrics: metrics)
            .focused($isFocused)
            .frame(width: 320, height: 44)
    }
}

@MainActor
private final class TextFieldDesignHost {
    #if os(macOS)
    private let window: NSWindow
    private let view: NSHostingView<AnyView>
    var field: NSTextField? { findField(in: view) }

    private func findField(in view: NSView) -> NSTextField? {
        if let field = view as? NSTextField { return field }
        return view.subviews.lazy.compactMap { self.findField(in: $0) }.first
    }
    #else
    private let window: UIWindow
    private let controller: UIHostingController<AnyView>
    var field: UITextField? { findField(in: controller.view) }

    private func findField(in view: UIView) -> UITextField? {
        if let field = view as? UITextField { return field }
        return view.subviews.lazy.compactMap { self.findField(in: $0) }.first
    }
    #endif

    init(_ root: AnyView, surrounding: ColorScheme, height: CGFloat = 100) {
        let bounds = CGRect(x: 0, y: 0, width: 320, height: height)
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
    }

    func settle() async {
        for _ in 0..<10 {
            #if os(macOS)
            view.layoutSubtreeIfNeeded()
            #else
            controller.view.layoutIfNeeded()
            #endif
            try? await Task.sleep(nanoseconds: 25_000_000)
        }
    }

    func close() {
        #if os(macOS)
        window.close()
        #else
        window.isHidden = true
        #endif
    }

    #if os(macOS)
    func resignFocus() {
        window.makeFirstResponder(nil)
    }

    func click(at point: NSPoint, clickCount: Int = 1) {
        window.makeKeyAndOrderFront(nil)
        for type in [NSEvent.EventType.leftMouseDown, .leftMouseUp] {
            if let event = NSEvent.mouseEvent(with: type, location: point,
                modifierFlags: [], timestamp: ProcessInfo.processInfo.systemUptime,
                windowNumber: window.windowNumber, context: nil, eventNumber: 0,
                clickCount: clickCount, pressure: 1) {
                window.sendEvent(event)
            }
        }
    }

    func pressKey(_ characters: String, keyCode: UInt16) {
        for type in [NSEvent.EventType.keyDown, .keyUp] {
            if let event = NSEvent.keyEvent(with: type, location: .zero,
                modifierFlags: [], timestamp: ProcessInfo.processInfo.systemUptime,
                windowNumber: window.windowNumber, context: nil, characters: characters,
                charactersIgnoringModifiers: characters, isARepeat: false, keyCode: keyCode) {
                window.sendEvent(event)
            }
        }
    }
    #endif
}
