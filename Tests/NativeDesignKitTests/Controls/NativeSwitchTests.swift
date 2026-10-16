import DesignTokens
import NativeDesignKit
import SwiftUI
import XCTest

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

final class NativeSwitchTests: XCTestCase {
    #if os(macOS)
    @MainActor
    func testNativeActivationWritesBindingAndReflectsCallerUpdates() throws {
        let state = SwitchState()
        let theme = try NativeDesignTheme(theme: .light, brand: "ocean")
        let host = host(BoundSwitch(state: state, theme: theme))
        defer { host.window.close() }
        let control = try XCTUnwrap(descendants(host.view).compactMap { $0 as? NSSwitch }.first)

        XCTAssertEqual(control.state, .off)
        control.performClick(nil)
        settle()
        XCTAssertTrue(state.isOn)
        XCTAssertEqual(control.state, .on)
        XCTAssertEqual(state.writes, 1)

        state.isOn = false
        settle()
        XCTAssertEqual(control.state, .off, "The caller remains the source of truth")
        control.performClick(nil)
        settle()
        XCTAssertTrue(state.isOn)
        XCTAssertEqual(state.writes, 2)
    }

    @MainActor
    func testDisabledNativeControlDoesNotWriteBinding() throws {
        for initiallyOn in [false, true] {
            let state = SwitchState(isOn: initiallyOn)
            let theme = try NativeDesignTheme(theme: .dark, brand: "graphite")
            let host = host(BoundSwitch(state: state, theme: theme).disabled(true))
            defer { host.window.close() }
            let control = try XCTUnwrap(descendants(host.view).compactMap { $0 as? NSSwitch }.first)
            XCTAssertFalse(control.isEnabled)
            XCTAssertFalse(control.accessibilityPerformPress())
            settle()
            XCTAssertEqual(state.isOn, initiallyOn)
            XCTAssertEqual(state.writes, 0)
        }
    }

    @MainActor
    func testNativeAccessibilityPressRetainsOnOffValue() throws {
        let state = SwitchState()
        let theme = try NativeDesignTheme(theme: .dark, brand: "ocean")
        let host = host(BoundSwitch(state: state, theme: theme)
            .accessibilityLabel("Allow notifications"))
        defer { host.window.close() }
        let toggle = try XCTUnwrap(descendants(host.view).compactMap { $0 as? NSSwitch }.first)
        XCTAssertTrue(toggle.isAccessibilityEnabled())
        XCTAssertEqual(toggle.accessibilitySubrole()?.rawValue, "AXSwitch")
        // NSSwitch's legacy switch protocol declares a String, while AppKit
        // returns an NSNumber. Read the complete protocol's untyped value.
        let accessibility: any NSAccessibilityProtocol = toggle
        XCTAssertEqual((accessibility.accessibilityValue() as? NSNumber)?.boolValue, false)
        _ = toggle.accessibilityPerformPress()
        settle()
        XCTAssertTrue(state.isOn)
        XCTAssertEqual((accessibility.accessibilityValue() as? NSNumber)?.boolValue, true)
    }

    @MainActor
    func testNativeSwitchCanReceiveKeyboardFocus() throws {
        let state = SwitchState()
        let theme = try NativeDesignTheme(theme: .light, brand: "graphite")
        let host = host(BoundSwitch(state: state, theme: theme))
        defer { host.window.close() }
        let control = try XCTUnwrap(descendants(host.view).compactMap { $0 as? NSSwitch }.first)
        XCTAssertTrue(host.window.makeFirstResponder(control))
        XCTAssertTrue(host.window.firstResponder === control)
    }

    @MainActor
    func testNarrowMultilineLabelGrowsAndRetainsNativeSwitch() throws {
        let theme = try NativeDesignTheme(theme: .light, brand: "ocean")
        let short = NSHostingView(rootView: NativeSwitch(theme: theme, isOn: .constant(false)) {
            Text("Notifications")
        }.frame(width: 240))
        let long = host(NativeSwitch(theme: theme, isOn: .constant(true)) {
            Text("Allow notifications about important updates and changes to your preferences, including reminders that need your attention before the next scheduled update")
        }.frame(width: 240))
        defer { long.window.close() }
        short.layoutSubtreeIfNeeded()
        let shortSize = short.fittingSize
        let longSize = long.view.fittingSize
        XCTAssertGreaterThanOrEqual(shortSize.height, 44)
        XCTAssertGreaterThan(longSize.height, shortSize.height + 10)
        XCTAssertEqual(longSize.width, 240, accuracy: 1)
        let control = try XCTUnwrap(descendants(long.view).compactMap { $0 as? NSSwitch }.first)
        XCTAssertTrue(long.view.bounds.contains(control.convert(control.bounds, to: long.view)))
        XCTAssertNotNil(control.hitTest(NSPoint(x: control.bounds.midX, y: control.bounds.midY)))
    }

    @MainActor
    func testRealSwiftUISwitchScreenshots() throws {
        for brand in DesignTokens.brandIDs {
            for mode in Theme.allCases {
                let theme = try NativeDesignTheme(theme: mode, brand: brand)
                try NativeSnapshot.capture("switch-\(brand)-\(mode.rawValue)", width: 620, height: 480) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Native Switch").font(.largeTitle.bold())
                        Text("\(brand.capitalized) · \(mode.rawValue.capitalized) · Strata")
                            .font(.subheadline).foregroundStyle(theme.secondaryForeground)
                        NativeSwitch(theme: theme, isOn: .constant(false)) { Text("Off") }
                        NativeSwitch(theme: theme, isOn: .constant(true)) { Text("On") }
                        NativeSwitch(theme: theme, isOn: .constant(false)) { Text("Disabled · off") }.disabled(true)
                        NativeSwitch(theme: theme, isOn: .constant(true)) { Text("Disabled · on") }.disabled(true)
                        Text("Native SwiftUI · caller-owned state · solid control")
                            .font(.caption).foregroundStyle(theme.secondaryForeground)
                    }
                    .padding(32)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .foregroundStyle(theme.foreground)
                    .background(theme.canvas)
                    // Deliberately oppose the explicit theme to exercise native chrome isolation.
                    .environment(\.colorScheme, mode == .light ? .dark : .light)
                }
                try NativeSnapshot.capture("switch-\(brand)-\(mode.rawValue)-narrow", width: 280, height: 480) {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Long labels").font(.title.bold())
                        NativeSwitch(theme: theme, isOn: .constant(true)) {
                            Text("Allow notifications about important updates and changes to your preferences")
                        }
                        NativeSwitch(theme: theme, isOn: .constant(false)) {
                            Text("Keep this preference turned off until you are ready to enable it")
                        }.disabled(true)
                        Text("280 pt width · semantic body font")
                            .font(.caption).foregroundStyle(theme.secondaryForeground)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .foregroundStyle(theme.foreground)
                    .background(theme.canvas)
                    .environment(\.colorScheme, mode == .light ? .light : .dark)
                }
            }
        }
    }

    @MainActor
    private func host<Content: View>(_ content: Content) -> (view: NSHostingView<Content>, window: NSWindow) {
        _ = NSApplication.shared
        NSApp.setActivationPolicy(.regular)
        let view = NSHostingView(rootView: content)
        let size = view.fittingSize
        let window = NSWindow(contentRect: NSRect(origin: .zero, size: size), styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = view
        window.makeKeyAndOrderFront(nil)
        if #available(macOS 14, *) { NSApp.activate() }
        settle()
        view.layoutSubtreeIfNeeded()
        return (view, window)
    }

    @MainActor
    private func descendants(_ view: NSView) -> [NSView] {
        [view] + view.subviews.flatMap(descendants)
    }

    @MainActor
    private func settle() {
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
    }
    #elseif os(iOS)
    @MainActor
    func testAccessibilityDynamicTypeIncreasesNarrowLabelHeight() throws {
        let theme = try NativeDesignTheme(theme: .light, brand: "ocean")
        func measure(_ size: DynamicTypeSize) -> CGSize {
            let content = NativeSwitch(theme: theme, isOn: .constant(true)) {
                Text("Allow notifications about important updates and changes to your preferences")
            }
            .environment(\.dynamicTypeSize, size)
            .frame(width: 280)
            let controller = UIHostingController(rootView: content)
            controller.loadViewIfNeeded()
            controller.view.frame = CGRect(x: 0, y: 0, width: 280, height: 1_000)
            controller.view.layoutIfNeeded()
            return controller.sizeThatFits(in: CGSize(width: 280, height: 1_000))
        }
        let normal = measure(.large)
        let accessible = measure(.accessibility3)
        XCTAssertGreaterThanOrEqual(normal.height, 44)
        XCTAssertGreaterThan(accessible.height, normal.height + 30)
        XCTAssertEqual(accessible.width, 280, accuracy: 1)
        print("iOS Switch layout: standard=\(normal), accessibility3=\(accessible), availableWidth=280")
    }
    #endif
}

#if os(macOS)
@MainActor
private final class SwitchState: ObservableObject {
    @Published var isOn: Bool
    var writes = 0

    init(isOn: Bool = false) { self.isOn = isOn }

    var binding: Binding<Bool> {
        Binding(get: { self.isOn }, set: { self.isOn = $0; self.writes += 1 })
    }
}

private struct BoundSwitch: View {
    @ObservedObject var state: SwitchState
    let theme: NativeDesignTheme

    var body: some View {
        NativeSwitch(theme: theme, isOn: state.binding) { Text("Enable notifications") }
    }
}
#endif
