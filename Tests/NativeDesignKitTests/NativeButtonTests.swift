import DesignTokens
import SwiftUI
import XCTest
@testable import NativeDesignKit

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

final class NativeButtonTests: XCTestCase {
    func testLoadingAndDisabledBlockEveryActionDispatch() {
        for enabled in [false, true] {
            for loading in [false, true] {
                var count = 0
                for _ in 0..<3 {
                    NativeButtonActivation.perform(isEnabled: enabled, isLoading: loading) { count += 1 }
                }
                XCTAssertEqual(count, enabled && !loading ? 3 : 0)
            }
        }
    }

    #if os(iOS)
    @MainActor
    func testLongLabelsGrowAtAccessibilitySizeWithinNarrowIOSHost() throws {
        let theme = try NativeDesignTheme(theme: .light, brand: "ocean")
        let width: CGFloat = 272 // 320 pt host minus 24 pt padding on each side.
        func measure(_ size: DynamicTypeSize, loading: Bool) -> CGSize {
            let button = NativeButton(theme: theme, variant: .primary, isLoading: loading, action: {}) {
                Text("Confirm your selection and save all changes")
            } loadingLabel: {
                Text("Preparing your selection and saving all changes…")
            }
            .environment(\.dynamicTypeSize, size)
            let host = UIHostingController(rootView: button)
            host.loadViewIfNeeded()
            host.view.frame = CGRect(x: 0, y: 0, width: width, height: 1_000)
            host.view.layoutIfNeeded()
            return host.sizeThatFits(in: CGSize(width: width, height: 1_000))
        }

        let standard = measure(.large, loading: false)
        let accessible = measure(.accessibility2, loading: false)
        let loading = measure(.accessibility2, loading: true)
        XCTAssertGreaterThanOrEqual(standard.height, 44)
        XCTAssertGreaterThan(accessible.height, standard.height + 20,
                             "Long text must wrap and increase the button height at iOS accessibility sizes.")
        XCTAssertLessThanOrEqual(accessible.width, width + 0.5)
        XCTAssertGreaterThanOrEqual(accessible.width, 44)
        XCTAssertEqual(accessible.width, loading.width, accuracy: 0.5)
        XCTAssertEqual(accessible.height, loading.height, accuracy: 0.5)
        print("iOS Button layout: width=\(width), standard=\(standard), accessibility=\(accessible), loading=\(loading)")
    }
    #endif

    #if os(macOS)
    @MainActor
    func testLoadingPreservesMeasuredFootprintAndMinimumHitSize() throws {
        let theme = try NativeDesignTheme(theme: .light, brand: "ocean")
        func measure(_ loading: Bool) -> NSSize {
            let button = NativeButton(theme: theme, variant: .primary, isLoading: loading, action: {}) {
                Text("Save")
            } loadingLabel: { Text("Saving all your changes…") }
            let view = NSHostingView(rootView: button)
            view.layoutSubtreeIfNeeded()
            return view.fittingSize
        }
        let idle = measure(false)
        let loading = measure(true)
        XCTAssertEqual(idle.width, loading.width, accuracy: 0.5)
        XCTAssertEqual(idle.height, loading.height, accuracy: 0.5)
        XCTAssertGreaterThanOrEqual(idle.width, 44)
        XCTAssertGreaterThanOrEqual(idle.height, 44)
    }

    @MainActor
    func testRealSwiftUIButtonScreenshots() throws {
        for brand in DesignTokens.brandIDs {
            for mode in Theme.allCases {
                let theme = try NativeDesignTheme(theme: mode, brand: brand)
                try NativeSnapshot.capture("button-\(brand)-\(mode.rawValue)", width: 820, height: 460) {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Native Button").font(.largeTitle.bold())
                        Text("\(brand.capitalized) · \(mode.rawValue.capitalized) · Strata")
                            .font(.subheadline).foregroundStyle(theme.secondaryForeground)
                        ForEach(["Normal", "Loading", "Disabled"], id: \.self) { state in
                            HStack(spacing: 16) {
                                Text(state).font(.subheadline).frame(width: 90, alignment: .leading)
                                self.sample(theme, variant: .primary, loading: state == "Loading").disabled(state == "Disabled")
                                self.sample(theme, variant: .secondary, loading: state == "Loading").disabled(state == "Disabled")
                                self.sample(theme, variant: .ghost, loading: state == "Loading").disabled(state == "Disabled")
                            }
                        }
                        Text("Native SwiftUI · caller-owned localized labels · no product data")
                            .font(.caption).foregroundStyle(theme.secondaryForeground)
                    }
                    .padding(32)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .foregroundStyle(theme.foreground)
                    .background(theme.canvas)
                    .environment(\.colorScheme, mode == .light ? .light : .dark)
                }
            }
        }
    }

    @MainActor
    func testNarrowAccessibilitySizeScreenshot() throws {
        let theme = try NativeDesignTheme(theme: .dark, brand: "ocean")
        try NativeSnapshot.capture("button-accessibility-narrow", width: 320, height: 540) {
            VStack(alignment: .leading, spacing: 24) {
                Text("Scalable actions").font(.title.bold())
                NativeButton(theme: theme, variant: .primary, isLoading: false, action: {}) {
                    Text("Confirm your selection")
                } loadingLabel: { Text("Confirming selection") }
                NativeButton(theme: theme, variant: .secondary, isLoading: true, action: {}) {
                    Text("Continue")
                } loadingLabel: { Text("Preparing your next step") }
                Text("320 pt narrow layout · accessibility environment requested").font(.caption)
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .foregroundStyle(theme.foreground)
            .background(theme.canvas)
            .environment(\.colorScheme, .dark)
            .environment(\.dynamicTypeSize, .accessibility2)
        }
    }

    @MainActor
    private func sample(_ theme: NativeDesignTheme, variant: NativeButtonVariant, loading: Bool) -> some View {
        NativeButton(theme: theme, variant: variant, isLoading: loading, action: {}) {
            Text(variant == .primary ? "Continue" : variant == .secondary ? "Save draft" : "Learn more")
        } loadingLabel: { Text("Working…") }
    }
    #endif
}
