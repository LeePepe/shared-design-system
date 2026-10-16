import DesignTokens
import NativeDesignKit
import SwiftUI
import XCTest

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

final class NativeAvatarTests: XCTestCase {
    // Public imports compile every content form used in the consumer contract.
    private let sizes: [(NativeAvatarSize, CGFloat)] = [(.small, 32), (.medium, 44), (.large, 64)]

    #if os(macOS)
    @MainActor
    func testHostedVisualBoundsAreStableAcrossThemesContentAndDisabledEnvironment() throws {
        for brand in ["ocean", "graphite"] {
            for mode in Theme.allCases {
                let theme = try NativeDesignTheme(theme: mode, brand: brand)
                for (size, diameter) in sizes {
                    for disabled in [false, true] {
                        let initials = NativeAvatar(theme: theme, size: size, accessibilityLabel: Text("Example member")) {
                            Text("AB")
                        }.disabled(disabled)
                        let symbol = NativeAvatar(theme: theme, size: size, accessibilityLabel: Text("Example group")) {
                            Image(systemName: "person.2.fill")
                        }.disabled(disabled)
                        let image = NativeAvatar(theme: theme, size: size, accessibilityLabel: Text("Example image")) {
                            fixture(theme).resizable().scaledToFill()
                        }.disabled(disabled)
                        for measured in [NSHostingView(rootView: initials).fittingSize,
                                         NSHostingView(rootView: symbol).fittingSize,
                                         NSHostingView(rootView: image).fittingSize] {
                            XCTAssertEqual(measured.width, diameter, accuracy: 0.5)
                            XCTAssertEqual(measured.height, diameter, accuracy: 0.5)
                        }
                    }
                }
            }
        }
    }

    @MainActor
    func testCallerFillIsClippedToCircleAndDoesNotPaintOutsideVisualBounds() throws {
        let theme = try NativeDesignTheme(theme: .light, brand: "ocean")
        try withHost(width: 132, height: 88, content: {
            HStack(spacing: 0) {
                NativeAvatar(theme: theme, size: .large, accessibilityLabel: Text("Abstract example")) {
                    Rectangle().fill(theme.accent).frame(width: 200, height: 120)
                }
                .frame(width: 88, height: 88)
                .background(theme.canvas)
                VStack(spacing: 0) {
                    Rectangle().fill(theme.accent)
                    Rectangle().fill(theme.canvas)
                }.frame(width: 44, height: 88)
            }
        }) { view in
            let bitmap = try XCTUnwrap(view.bitmapImageRepForCachingDisplay(in: view.bounds))
            view.cacheDisplay(in: view.bounds, to: bitmap)
            let scale = CGFloat(bitmap.pixelsWide) / 132
            // Compare references in the same display-profile bitmap.
            for (point, reference) in [(CGPoint(x: 44, y: 44), CGPoint(x: 110, y: 22)),
                                       (CGPoint(x: 13, y: 13), CGPoint(x: 110, y: 66)),
                                       (CGPoint(x: 2, y: 44), CGPoint(x: 110, y: 66))] {
                let actual = try XCTUnwrap(bitmap.colorAt(x: Int(point.x * scale), y: Int(point.y * scale)))
                let expected = try XCTUnwrap(bitmap.colorAt(x: Int(reference.x * scale), y: Int(reference.y * scale)))
                XCTAssertEqual(actual.redComponent, expected.redComponent, accuracy: 1 / 255)
                XCTAssertEqual(actual.greenComponent, expected.greenComponent, accuracy: 1 / 255)
                XCTAssertEqual(actual.blueComponent, expected.blueComponent, accuracy: 1 / 255)
            }
        }
    }

    @MainActor
    func testRealSwiftUIAvatarScreenshots() throws {
        for brand in ["ocean", "graphite"] {
            for mode in Theme.allCases {
                let theme = try NativeDesignTheme(theme: mode, brand: brand)
                let image = fixture(theme)
                try NativeSnapshot.capture("avatar-\(brand)-\(mode.rawValue)", width: 620, height: 510) {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Native Avatar").font(.largeTitle.bold())
                        Text("\(brand.capitalized) · \(mode.rawValue.capitalized) · Strata")
                            .font(.subheadline).foregroundStyle(theme.secondaryForeground)
                        HStack(spacing: 0) {
                            Text("Caller content").frame(width: 145, alignment: .leading)
                            ForEach(Array(sizes.enumerated()), id: \.offset) { entry in
                                Text("\(Int(entry.element.1)) pt").frame(width: 100)
                            }
                        }.font(.caption).foregroundStyle(theme.secondaryForeground)
                        snapshotRow("Initials", theme: theme) { Text("AB") }
                        snapshotRow("SF Symbol", theme: theme) { Image(systemName: "person.fill") }
                        snapshotRow("Local image · fill", theme: theme) { image.resizable().scaledToFill() }
                        snapshotRow("Local image · fit", theme: theme) { image.resizable().scaledToFit() }
                        Text("Caller-owned visuals · one accessible label · no interaction")
                            .font(.caption).foregroundStyle(theme.secondaryForeground)
                    }
                    .padding(28)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .foregroundStyle(theme.foreground).background(theme.canvas)
                    .environment(\.colorScheme, mode == .light ? .light : .dark)
                }
                try NativeSnapshot.capture("avatar-\(brand)-\(mode.rawValue)-narrow", width: 280, height: 430) {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Content stays outside the circle").font(.title2.bold())
                        HStack(alignment: .top, spacing: 12) {
                            NativeAvatar(theme: theme, size: .small, accessibilityLabel: Text("Example member with a long display name")) {
                                Text("AB")
                            }
                            Text("Example member with a long display name that wraps naturally beside a small avatar.")
                                .font(.body).fixedSize(horizontal: false, vertical: true)
                        }
                        HStack(alignment: .top, spacing: 12) {
                            NativeAvatar(theme: theme, size: .large, accessibilityLabel: Text("Example group")) {
                                Image(systemName: "person.2.fill")
                            }
                            Text("A larger visual keeps its size while ordinary labels use the available width.")
                                .font(.body).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .foregroundStyle(theme.foreground).background(theme.canvas)
                    .environment(\.colorScheme, mode == .light ? .light : .dark)
                }
            }
        }
    }

    @MainActor
    private func snapshotRow<Content: View>(_ title: String, theme: NativeDesignTheme,
                                             @ViewBuilder content: @escaping () -> Content) -> some View {
        HStack(spacing: 0) {
            Text(title).font(.subheadline).frame(width: 145, alignment: .leading)
            ForEach(Array(sizes.enumerated()), id: \.offset) { entry in
                NativeAvatar(theme: theme, size: entry.element.0, accessibilityLabel: Text(title), content: content)
                    .frame(width: 100)
            }
        }.frame(height: 64)
    }

    @MainActor
    private func fixture(_ theme: NativeDesignTheme) -> Image {
        let image = NSImage(size: NSSize(width: 140, height: 88), flipped: false) { rect in
            NSColor(theme.accent).setFill()
            rect.fill()
            NSColor(theme.onAccent).setFill()
            NSBezierPath(ovalIn: NSRect(x: 46, y: 18, width: 48, height: 48)).fill()
            return true
        }
        return Image(nsImage: image)
    }

    @MainActor
    private func withHost<Content: View>(width: CGFloat, height: CGFloat,
                                         @ViewBuilder content: () -> Content,
                                         check: (NSHostingView<Content>) throws -> Void) rethrows {
        _ = NSApplication.shared
        let view = NSHostingView(rootView: content())
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: width, height: height),
                              styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentView = view
        window.orderFrontRegardless()
        defer { window.orderOut(nil) }
        view.layoutSubtreeIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        try check(view)
    }
    #elseif os(iOS)
    @MainActor
    func testAccessibilityExposesOnlyTheCallerLabelAndImageTrait() throws {
        let theme = try NativeDesignTheme(theme: .light, brand: "ocean")
        let host = UIHostingController(rootView:
            NativeAvatar(theme: theme, size: .large, accessibilityLabel: Text("Localized example member")) {
                Text("AB").accessibilityLabel("Redundant child glyph")
            }
        )
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        window.rootViewController = host
        window.makeKeyAndVisible()
        defer { window.isHidden = true }
        host.view.layoutIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        let elements = accessibilityDescendants(host.view).filter(\.isAccessibilityElement)
        let avatar = try XCTUnwrap(elements.first { $0.accessibilityLabel == "Localized example member" })
        XCTAssertTrue(avatar.accessibilityTraits.contains(.image))
        XCTAssertFalse(avatar.accessibilityTraits.contains(.button))
        XCTAssertFalse(elements.contains { $0.accessibilityLabel == "Redundant child glyph" })
        XCTAssertEqual(elements.count, 1)
    }

    @MainActor
    func testAccessibilityDynamicTypeRetainsFixedAvatarVisual() throws {
        let theme = try NativeDesignTheme(theme: .dark, brand: "graphite")
        for (size, diameter) in sizes {
            for typeSize in [DynamicTypeSize.large, .accessibility5] {
                let avatar = NativeAvatar(theme: theme, size: size,
                                          accessibilityLabel: Text("Example member with a full accessible name")) {
                    Text("AB")
                }.environment(\.dynamicTypeSize, typeSize)
                let host = UIHostingController(rootView: avatar)
                let measured = host.view.sizeThatFits(CGSize(width: 280, height: 400))
                XCTAssertEqual(measured.width, diameter, accuracy: 0.5)
                XCTAssertEqual(measured.height, diameter, accuracy: 0.5)
            }
        }
    }

    @MainActor
    private func accessibilityDescendants(_ element: NSObject) -> [NSObject] {
        let children: [NSObject]
        if let elements = element.accessibilityElements {
            children = elements.compactMap { $0 as? NSObject }
        } else {
            children = (element as? UIView)?.subviews ?? []
        }
        return [element] + children.flatMap(accessibilityDescendants)
    }
    #endif
}
