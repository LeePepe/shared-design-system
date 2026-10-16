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
final class NativeButtonDesignTests: XCTestCase {
    func testLoadingKeepsTheCompleteLocalizedLabelGeometry() throws {
        let theme = try NativeDesignTheme(theme: .light)
        for presentation in NativeButtonPresentation.allCases {
            for role in [nil, .cancel, .destructive] as [ButtonRole?] {
                let resting = size(theme: theme, presentation: presentation, role: role,
                                   loading: false, padding: 8)
                let loading = size(theme: theme, presentation: presentation, role: role,
                                   loading: true, padding: 8)
                XCTAssertEqual(resting.width, loading.width, accuracy: 0.5,
                               "Loading must not replace or collapse the localized label")
                XCTAssertEqual(resting.height, loading.height, accuracy: 0.5)
            }
        }
    }

    func testNativeStylesDoNotAddTheMetricsPaddingToTheirOwnBezelPadding() throws {
        let theme = try NativeDesignTheme(theme: .light)
        for presentation in NativeButtonPresentation.allCases {
            let withoutExtraPadding = size(theme: theme, presentation: presentation,
                                           role: nil, loading: false, padding: 0)
            let oversizedInputPadding = size(theme: theme, presentation: presentation,
                                             role: nil, loading: false, padding: 40)
            XCTAssertEqual(withoutExtraPadding.width, oversizedInputPadding.width, accuracy: 0.5)
            XCTAssertEqual(withoutExtraPadding.height, oversizedInputPadding.height, accuracy: 0.5,
                           "Native button styles own their bezel padding")
        }
    }

    func testIconTargetRetainsTheExplicitMinimumSize() throws {
        let theme = try NativeDesignTheme(theme: .light)
        let metrics = metrics(padding: 8)
        let button = NativeButton(theme: theme, metrics: metrics, presentation: .plain,
            isLoading: false, loadingLabel: Text("Adding note"), action: {}) {
                Image(systemName: "plus").font(.body)
            }
            .accessibilityLabel(Text("Add Note"))
        let measured = fittingSize(AnyView(button))
        XCTAssertGreaterThanOrEqual(measured.width, metrics.minimumHitSize)
        XCTAssertGreaterThanOrEqual(measured.height, metrics.minimumHitSize)
    }

    private func size(theme: NativeDesignTheme, presentation: NativeButtonPresentation,
                      role: ButtonRole?, loading: Bool, padding: CGFloat) -> CGSize {
        fittingSize(AnyView(NativeButton(theme: theme, metrics: metrics(padding: padding),
            presentation: presentation, role: role, isLoading: loading,
            loadingLabel: Text("正在保存文稿副本"), action: {}) {
                Text("保存文稿副本 Save a Copy").font(.body)
            }))
    }

    private func metrics(padding: CGFloat) -> NativeControlMetrics {
        NativeControlMetrics(padding: padding, spacing: 8, cornerRadius: 8,
            minimumHitSize: 44, iconSize: 20, borderWidth: 1, disabledOpacity: 0.5)
    }

    private func fittingSize(_ view: AnyView) -> CGSize {
        #if os(macOS)
        _ = NSApplication.shared
        let host = NSHostingView(rootView: view.fixedSize())
        return host.fittingSize
        #else
        let host = UIHostingController(rootView: view.fixedSize())
        return host.sizeThatFits(in: CGSize(width: 1_000, height: 1_000))
        #endif
    }
}
