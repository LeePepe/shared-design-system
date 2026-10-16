import DesignTokens
@testable import NativeDesignKit
import SwiftUI
import XCTest

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

final class NativeCardTests: XCTestCase {
    @MainActor
    func testLongContentGrowsAtNarrowWidth() throws {
        let theme = try NativeDesignTheme(theme: .light, brand: "ocean")
        let short = height(of: sample(theme: theme, surface: .solid, long: false), width: 280)
        let long = height(of: sample(theme: theme, surface: .solid, long: true), width: 280)
        XCTAssertGreaterThan(long, short + 40, "Long content must expand the card rather than truncate.")
        XCTAssertGreaterThan(short, 100, "All four slots must participate in layout.")
        print("CARD_LAYOUT width=280 short=\(short) long=\(long)")
    }

    @MainActor
    func testThemeMaterialAndTransparencyChangesKeepTheSameLayout() throws {
        var heights: [CGFloat] = []
        for mode in Theme.allCases {
            for brand in ["ocean", "graphite"] {
                let theme = try NativeDesignTheme(theme: mode, brand: brand)
                for surface in [NativeSurfaceStyle.solid, .glass] {
                    for reduceTransparency in [false, true] {
                        heights.append(height(
                            of: sample(theme: theme, surface: surface, long: true)
                                .environment(\.nativeReduceTransparencyOverride, reduceTransparency),
                            width: 320
                        ))
                    }
                }
            }
        }
        let reference = try XCTUnwrap(heights.first)
        for measured in heights {
            XCTAssertEqual(measured, reference, accuracy: 0.5,
                           "Theme, material and transparency preference must not shift content.")
        }
        print("CARD_STABLE_LAYOUT variants=\(heights.count) width=320 height=\(reference)")
    }

    @MainActor
    func testContentOnlyInitializerDoesNotReserveEmptySections() throws {
        let theme = try NativeDesignTheme(theme: .light, brand: "ocean")
        let full = NativeCard(theme: theme, surface: .solid) {
            EmptyView()
        } content: {
            Text("Only content")
        } supporting: {
            EmptyView()
        } actions: {
            EmptyView()
        }
        let compact = NativeCard(theme: theme, surface: .solid) {
            Text("Only content")
        }
        XCTAssertEqual(height(of: full, width: 280), height(of: compact, width: 280), accuracy: 0.5)
        XCTAssertLessThan(height(of: compact, width: 280), 80)
    }

    #if os(iOS)
    @MainActor
    func testAccessibilityDynamicTypeExpandsContent() throws {
        let theme = try NativeDesignTheme(theme: .dark, brand: "graphite")
        let card = sample(theme: theme, surface: .solid, long: true)
        let regular = height(of: card.dynamicTypeSize(.large), width: 320)
        let accessible = height(of: card.dynamicTypeSize(.accessibility3), width: 320)
        XCTAssertGreaterThan(accessible, regular + 40,
                             "Accessibility text must reflow without a fixed card height.")
        print("CARD_IOS_DYNAMIC_TYPE width=320 large=\(regular) accessibility3=\(accessible)")
    }
    #endif

    #if os(macOS)
    @MainActor
    func testGlassFallbackRendersTheExplicitThemesSolidSurface() throws {
        for mode in Theme.allCases {
            for brand in ["ocean", "graphite"] {
                let theme = try NativeDesignTheme(theme: mode, brand: brand)
                let solid = try surfacePixel(theme: theme, surface: .solid, reduceTransparency: false)
                let fallback = try surfacePixel(theme: theme, surface: .glass, reduceTransparency: true)
                let glass = try surfacePixel(theme: theme, surface: .glass, reduceTransparency: false)
                // Compare like-for-like hosted rendering: the display's color-management
                // transform is not the direct NSColor conversion of an encoded token.
                let expectedRGB = try renderedPixel(of:
                    Rectangle().fill(theme.surface).frame(width: 240, height: 152)
                )
                for channel in 0..<3 {
                    XCTAssertEqual(solid[channel], expectedRGB[channel], accuracy: 2 / 255)
                    XCTAssertEqual(fallback[channel], solid[channel], accuracy: 2 / 255,
                                   "Reduce Transparency must use this theme's opaque surface.")
                }
                let materialDifference = zip(glass, solid).map { abs($0 - $1) }.max() ?? 0
                XCTAssertGreaterThan(materialDifference, 0.02,
                                     "Normal Glass must render material over the token backdrop.")
                print("CARD_SURFACE \(brand)/\(mode) solid=\(solid) fallback=\(fallback) glass=\(glass)")
            }
        }
    }

    @MainActor
    func testCallerButtonsKeepTheirNativeActionsAndDisabledState() throws {
        let theme = try NativeDesignTheme(theme: .light, brand: "ocean")
        var activations = 0
        var actionFrames: [String: CGRect] = [:]
        let card = NativeCard(theme: theme, surface: .solid) {
            Text("Independent caller controls")
        } content: {
            Text("The container has no activation behavior of its own.")
        } supporting: {
            EmptyView()
        } actions: {
            Button { activations += 1 } label: {
                Text("Perform caller action")
                    .frame(minWidth: 180, minHeight: 44)
                    .contentShape(Rectangle())
                    .background {
                        GeometryReader { geometry in
                            theme.canvas.opacity(0).onAppear {
                                actionFrames["enabled"] = geometry.frame(in: .named("card-test"))
                            }
                        }
                    }
            }
            .buttonStyle(.plain)
            Button { activations += 100 } label: {
                Text("Unavailable caller action")
                    .frame(minWidth: 180, minHeight: 44)
                    .contentShape(Rectangle())
                    .background {
                        GeometryReader { geometry in
                            theme.canvas.opacity(0).onAppear {
                                actionFrames["disabled"] = geometry.frame(in: .named("card-test"))
                            }
                        }
                    }
            }
            .buttonStyle(.plain)
            .disabled(true)
        }
        _ = NSApplication.shared
        let host = NSHostingView(rootView: card.frame(width: 320).coordinateSpace(name: "card-test"))
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 320, height: 320),
                              styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentView = host
        window.orderFrontRegardless()
        defer { window.orderOut(nil) }
        host.layoutSubtreeIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.05))
        let enabled = try XCTUnwrap(actionFrames["enabled"])
        let disabled = try XCTUnwrap(actionFrames["disabled"])
        XCTAssertGreaterThanOrEqual(enabled.height, 44)
        XCTAssertGreaterThanOrEqual(disabled.height, 44)
        try click(frame: enabled, host: host, window: window)
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.02))
        XCTAssertEqual(activations, 1, "Card must preserve the caller's native button action.")
        try click(frame: disabled, host: host, window: window)
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.02))
        XCTAssertEqual(activations, 1, "Disabled descendants must not invoke caller actions.")
    }

    @MainActor
    func testHostedSwiftUIEvidenceMatrix() throws {
        for mode in Theme.allCases {
            for brand in ["ocean", "graphite"] {
                let theme = try NativeDesignTheme(theme: mode, brand: brand)
                let scheme: ColorScheme = mode == .light ? .light : .dark
                let root = evidence(theme: theme, brand: brand, mode: String(describing: mode))
                    .environment(\.colorScheme, scheme)
                // Measure the real content instead of cropping it to a fixed screenshot height.
                let measured = height(of: root, width: 980)
                XCTAssertGreaterThan(measured, 600)
                print("CARD_SNAPSHOT \(brand)/\(mode) width=980 height=\(measured)")
                try NativeSnapshot.capture("card-\(brand)-\(mode)", width: 980, height: ceil(measured)) {
                    root
                }
            }
        }
    }

    @MainActor
    private func evidence(theme: NativeDesignTheme, brand: String, mode: String) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Card").font(.largeTitle.bold())
                Text("Strata · \(brand) · \(mode) · synthetic content").font(.subheadline)
                    .foregroundStyle(theme.secondaryForeground)
            }
            Text("Material preference is forced through an internal test input; production follows the system setting.")
                .font(.footnote)
                .foregroundStyle(theme.secondaryForeground)
            HStack(alignment: .top, spacing: 16) {
                evidenceColumn(theme: theme, surface: .solid, reduceTransparency: false, label: "Solid")
                evidenceColumn(theme: theme, surface: .glass, reduceTransparency: false, label: "Glass · preference off")
                evidenceColumn(theme: theme, surface: .glass, reduceTransparency: true, label: "Glass → solid · preference on")
            }
            Text("Narrow · long text · same three surface choices").font(.headline)
            HStack(alignment: .top, spacing: 16) {
                sample(theme: theme, surface: .solid, long: true)
                sample(theme: theme, surface: .glass, long: true)
                    .environment(\.nativeReduceTransparencyOverride, false)
                sample(theme: theme, surface: .glass, long: true)
                    .environment(\.nativeReduceTransparencyOverride, true)
            }
            Text("macOS semantic fonts follow platform behavior. iOS Dynamic Type growth is tested separately.")
                .font(.footnote)
                .foregroundStyle(theme.secondaryForeground)
        }
        .padding(24)
        .foregroundStyle(theme.foreground)
        .background(theme.canvas)
    }

    @MainActor
    private func evidenceColumn(
        theme: NativeDesignTheme,
        surface: NativeSurfaceStyle,
        reduceTransparency: Bool,
        label: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label).font(.headline)
            sample(theme: theme, surface: surface, long: false)
                .environment(\.nativeReduceTransparencyOverride, reduceTransparency)
                .background(alignment: .leading) {
                    // Token-derived backdrop cue behind the actual hosted material.
                    RoundedRectangle(cornerRadius: 20)
                        .fill(theme.accent.opacity(0.25))
                        .frame(width: 76)
                        .padding(.vertical, 12)
                }
        }
    }

    @MainActor
    private func click(frame: CGRect, host: NSView, window: NSWindow) throws {
        let point = host.convert(NSPoint(x: frame.midX, y: frame.midY), to: nil)
        for type in [NSEvent.EventType.leftMouseDown, .leftMouseUp] {
            let event = try XCTUnwrap(NSEvent.mouseEvent(
                with: type, location: point, modifierFlags: [], timestamp: ProcessInfo.processInfo.systemUptime,
                windowNumber: window.windowNumber, context: nil, eventNumber: 0, clickCount: 1, pressure: 1
            ))
            window.sendEvent(event)
        }
    }

    @MainActor
    private func surfacePixel(
        theme: NativeDesignTheme,
        surface: NativeSurfaceStyle,
        reduceTransparency: Bool
    ) throws -> [CGFloat] {
        let content = NativeCard(theme: theme, surface: surface) {
            Text("Material routing").frame(height: 120)
        }
        .frame(width: 240)
        .environment(\.nativeReduceTransparencyOverride, reduceTransparency)
        .background(theme.accent)
        return try renderedPixel(of: content)
    }

    @MainActor
    private func renderedPixel<Content: View>(of content: Content) throws -> [CGFloat] {
        _ = NSApplication.shared
        let host = NSHostingView(rootView: content)
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 240, height: 152),
                              styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentView = host
        window.orderFrontRegardless()
        defer { window.orderOut(nil) }
        host.layoutSubtreeIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.03))
        let bitmap = try XCTUnwrap(host.bitmapImageRepForCachingDisplay(in: host.bounds))
        host.cacheDisplay(in: host.bounds, to: bitmap)
        // Above the text and away from the rounded corners, in the real card background.
        let pixel = try XCTUnwrap(bitmap.colorAt(x: bitmap.pixelsWide / 2, y: bitmap.pixelsHigh / 8))
        let rgb = try XCTUnwrap(pixel.usingColorSpace(.sRGB))
        return [rgb.redComponent, rgb.greenComponent, rgb.blueComponent]
    }
    #endif

    @MainActor
    private func sample(theme: NativeDesignTheme, surface: NativeSurfaceStyle, long: Bool) -> some View {
        NativeCard(theme: theme, surface: surface) {
            Text(long ? "A longer title remains clear as the available width narrows" : "A clear place to begin")
        } content: {
            Text(long
                 ? "This deliberately long sample explains the content without truncation. It stays in reading order, wraps at the proposed width and lets the card grow. No product data, formatting or navigation is owned by the component."
                 : "A quiet surface keeps caller-owned content in focus.")
        } supporting: {
            Text(long
                 ? "Supporting context uses a separate semantic text style. This is synthetic content for layout validation."
                 : "Synthetic example · no business meaning")
        } actions: {
            VStack(alignment: .leading, spacing: 0) {
                Button {} label: {
                    Text("Continue")
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Button {} label: {
                    Text("Unavailable action")
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(true)
            }
        }
    }

    @MainActor
    private func height<Content: View>(of content: Content, width: CGFloat) -> CGFloat {
        #if os(macOS)
        let host = NSHostingView(rootView: content.frame(width: width))
        host.layoutSubtreeIfNeeded()
        return host.fittingSize.height
        #elseif os(iOS)
        let host = UIHostingController(rootView: content.frame(width: width))
        host.loadViewIfNeeded()
        // Ask SwiftUI for its content height at this width. A compressed UIKit
        // proposal instead requests zero height and permits text compression.
        let proposal = CGSize(width: width, height: 10_000)
        host.view.frame = CGRect(origin: .zero, size: proposal)
        host.view.layoutIfNeeded()
        return host.sizeThatFits(in: proposal).height
        #endif
    }
}
