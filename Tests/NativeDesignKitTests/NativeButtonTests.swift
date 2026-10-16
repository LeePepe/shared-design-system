import DesignTokens
import SwiftUI
import XCTest
@testable import NativeDesignKit

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

    #if os(macOS)
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
                Text("Accessibility text size · 320 pt width").font(.caption)
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
