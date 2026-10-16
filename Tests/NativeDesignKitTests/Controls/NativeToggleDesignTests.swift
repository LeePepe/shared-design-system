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
final class NativeToggleDesignTests: XCTestCase {
    func testDisabledSwitchDoesNotReceiveASecondMetricsOpacity() throws {
        for theme in Theme.allCases {
            let snapshot = try NativeDesignTheme(theme: theme)
            for isOn in [false, true] {
                let transparentMetrics = try disabledPNG(theme: snapshot, isOn: isOn, opacity: 0)
                let opaqueMetrics = try disabledPNG(theme: snapshot, isOn: isOn, opacity: 1)
                XCTAssertGreaterThan(transparentMetrics.count, 1_000,
                                     "The disabled label and native control must remain visible")
                XCTAssertTrue(transparentMetrics == opaqueMetrics,
                              "Native disabled appearance must not be faded again by metrics.disabledOpacity")
            }
        }
    }

    func testLongChineseLabelGrowsWithinNarrowWidthAndKeepsStateGeometry() throws {
        let theme = try NativeDesignTheme(theme: .light)
        for dynamicType in [DynamicTypeSize.large, .accessibility3] {
            let narrow = fittingSize(theme: theme, width: 180, dynamicType: dynamicType,
                                     isOn: false, disabled: false)
            let wide = fittingSize(theme: theme, width: 480, dynamicType: dynamicType,
                                   isOn: false, disabled: false)
            XCTAssertEqual(narrow.width, 180, accuracy: 0.5)
            XCTAssertGreaterThan(narrow.height, wide.height + 10,
                                 "Long labels must grow vertically instead of clipping or shrinking")
            XCTAssertGreaterThanOrEqual(narrow.height, metrics().minimumHitSize)
            for isOn in [false, true] {
                for disabled in [false, true] {
                    let measured = fittingSize(theme: theme, width: 180, dynamicType: dynamicType,
                                               isOn: isOn, disabled: disabled)
                    XCTAssertEqual(measured.width, narrow.width, accuracy: 0.5)
                    XCTAssertEqual(measured.height, narrow.height, accuracy: 0.5,
                                   "On/off and disabled states must not move neighbouring rows")
                }
            }
        }
    }

    private func fittingSize(theme: NativeDesignTheme, width: CGFloat, dynamicType: DynamicTypeSize,
                             isOn: Bool, disabled: Bool) -> CGSize {
        let view = NativeToggle(isOn: .constant(isOn), theme: theme, metrics: metrics()) {
            Text("在所有设备上保留本次修改，并在下次打开时恢复这些选项")
                .font(.body)
        }
        .disabled(disabled).dynamicTypeSize(dynamicType)
        .frame(width: width).fixedSize(horizontal: false, vertical: true)
        #if os(macOS)
        _ = NSApplication.shared
        return NSHostingView(rootView: view).fittingSize
        #else
        return UIHostingController(rootView: view)
            .sizeThatFits(in: CGSize(width: width, height: 10_000))
        #endif
    }

    private func disabledPNG(theme: NativeDesignTheme, isOn: Bool, opacity: Double) throws -> Data {
        let bounds = CGRect(x: 0, y: 0, width: 360, height: 100)
        let view = NativeToggle(isOn: .constant(isOn), theme: theme, metrics: metrics(opacity: opacity)) {
            Text("Keep Changes").font(.body)
        }
        .disabled(true).controlSize(.regular)
        .padding(12).frame(width: bounds.width, height: bounds.height)
        .background(theme.surfaceRaised)
        .environment(\.colorScheme, theme.theme == .dark ? .dark : .light)
        #if os(macOS)
        _ = NSApplication.shared
        let host = NSHostingView(rootView: view)
        host.frame = bounds
        host.appearance = NSAppearance(named: theme.theme == .dark ? .darkAqua : .aqua)
        host.layoutSubtreeIfNeeded()
        let bitmap = try XCTUnwrap(host.bitmapImageRepForCachingDisplay(in: bounds))
        host.cacheDisplay(in: bounds, to: bitmap)
        return try XCTUnwrap(bitmap.representation(using: .png, properties: [:]))
        #else
        let host = UIHostingController(rootView: view)
        host.overrideUserInterfaceStyle = theme.theme == .dark ? .dark : .light
        host.view.frame = bounds
        host.view.layoutIfNeeded()
        return UIGraphicsImageRenderer(bounds: bounds).pngData { context in
            host.view.layer.render(in: context.cgContext)
        }
        #endif
    }

    private func metrics(opacity: Double = 0.5) -> NativeControlMetrics {
        #if os(macOS)
        let minimum: CGFloat = 28
        #else
        let minimum: CGFloat = 44
        #endif
        return NativeControlMetrics(padding: 8, spacing: 8, cornerRadius: 8,
            minimumHitSize: minimum, iconSize: 20, borderWidth: 1, disabledOpacity: opacity)
    }
}
