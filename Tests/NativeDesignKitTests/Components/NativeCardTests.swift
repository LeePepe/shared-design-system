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
    }
    #endif

    #if os(macOS)
    @MainActor
    func testHostedSwiftUIEvidenceMatrix() throws {
        for mode in Theme.allCases {
            for brand in ["ocean", "graphite"] {
                let theme = try NativeDesignTheme(theme: mode, brand: brand)
                let scheme: ColorScheme = mode == .light ? .light : .dark
                let root = evidence(theme: theme, brand: brand, mode: String(describing: mode))
                    .environment(\.colorScheme, scheme)
                // The layout always runs. PNG writing is opt-in and stays outside git.
                XCTAssertGreaterThan(height(of: root, width: 840), 300)
                try NativeSnapshot.capture("card-\(brand)-\(mode)", width: 840, height: 960) {
                    root
                }
            }
        }
    }

    @MainActor
    private func evidence(theme: NativeDesignTheme, brand: String, mode: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Card").font(.largeTitle.bold())
                Text("Strata · \(brand) · \(mode) · synthetic content").font(.subheadline)
                    .foregroundStyle(theme.secondaryForeground)
            }
            HStack(alignment: .top, spacing: 16) {
                evidenceColumn(theme: theme, surface: .solid, label: "Solid")
                evidenceColumn(theme: theme, surface: .glass, label: "Glass")
            }
            Text("Narrow · long text · accessibility3 request").font(.headline)
            HStack(alignment: .top, spacing: 16) {
                sample(theme: theme, surface: .solid, long: true)
                    .dynamicTypeSize(.accessibility3)
                sample(theme: theme, surface: .glass, long: true)
                    .dynamicTypeSize(.accessibility3)
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
        label: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(label).font(.headline)
            sample(theme: theme, surface: surface, long: false)
            Text("Reduce Transparency → solid").font(.subheadline)
            sample(theme: theme, surface: surface, long: false)
                .environment(\.nativeReduceTransparencyOverride, true)
        }
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
            Button("Continue") {}
                .buttonStyle(.plain)
                .frame(minHeight: 44)
                .contentShape(Rectangle())
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
        return host.view.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        #endif
    }
}
