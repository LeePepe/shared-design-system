import DesignTokens
import SwiftUI
import XCTest
@testable import NativeDesignKit

#if os(macOS)
import AppKit
#elseif os(iOS)
import CoreGraphics
import UIKit
#endif

final class NativeTokenColorTests: XCTestCase {
    @MainActor
    func testEveryTokenInBothThemes() throws {
        XCTAssertFalse(DesignTokens.ids.isEmpty)
        for theme in Theme.allCases {
            for id in DesignTokens.ids {
                let expected = try DesignTokens.color(id, theme: theme)
                let actual = try NativeTokenColor.resolve(id, theme: theme)
                try assertSRGB(actual, equals: expected, context: "\(id), \(theme)")
            }
        }
    }

    @MainActor
    func testAlternatingThemeDoesNotReuseAnotherThemesColor() throws {
        let id = try XCTUnwrap(
            try DesignTokens.ids.first { id in
                let light = try DesignTokens.color(id, theme: .light)
                let dark = try DesignTokens.color(id, theme: .dark)
                return light != dark
            },
            "The pinned candidate must expose a theme-varying token for this test."
        )

        for theme in [Theme.light, .dark, .light] {
            let actual = try NativeTokenColor.resolve(id, theme: theme)
            let expected = try DesignTokens.color(id, theme: theme)
            try assertSRGB(actual, equals: expected, context: "\(id), \(theme)")
        }
    }

    func testUnknownTokenErrorsPreserveExactIDInBothThemes() {
        for id in ["", "__native_design_kit_unknown_token__"] {
            XCTAssertFalse(DesignTokens.ids.contains(id))
            for theme in Theme.allCases {
                XCTAssertThrowsError(try NativeTokenColor.resolve(id, theme: theme)) { error in
                    XCTAssertEqual(error as? TokenError, TokenError.unknownToken(id))
                }
            }
        }
    }

    @MainActor
    func testProductionConversionPreservesAsymmetricRGBAndAlpha() throws {
        for alpha in [0.0, 0.25, 1.0] {
            let rgba = try RGBA(red: 37, green: 113, blue: 211, alpha: alpha)
            let actual = NativeTokenColor.color(from: rgba)
            try assertSRGB(actual, equals: rgba, context: "synthetic alpha \(alpha)")
        }
    }

    @MainActor
    private func assertSRGB(
        _ color: SwiftUI.Color,
        equals expected: RGBA,
        context: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let actual = try extractSRGB(color, file: file, line: line)
        let tolerance = 0.00001
        XCTAssertEqual(actual.alpha, expected.a, accuracy: tolerance, context, file: file, line: line)

        // Native bridges may discard hidden RGB channels at zero alpha.
        guard expected.a != 0 else { return }
        XCTAssertEqual(actual.red, Double(expected.r) / 255, accuracy: tolerance, context, file: file, line: line)
        XCTAssertEqual(actual.green, Double(expected.g) / 255, accuracy: tolerance, context, file: file, line: line)
        XCTAssertEqual(actual.blue, Double(expected.b) / 255, accuracy: tolerance, context, file: file, line: line)
    }

    private struct SRGBComponents {
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double
    }

    @MainActor
    private func extractSRGB(
        _ color: SwiftUI.Color,
        file: StaticString,
        line: UInt
    ) throws -> SRGBComponents {
        #if os(macOS)
        let native = try XCTUnwrap(
            NSColor(color).usingColorSpace(.sRGB),
            "AppKit could not convert the color to sRGB.",
            file: file,
            line: line
        )
        return SRGBComponents(
            red: Double(native.redComponent),
            green: Double(native.greenComponent),
            blue: Double(native.blueComponent),
            alpha: Double(native.alphaComponent)
        )
        #elseif os(iOS)
        let space = try XCTUnwrap(CGColorSpace(name: CGColorSpace.sRGB), file: file, line: line)
        let native = try XCTUnwrap(
            UIColor(color).cgColor.converted(to: space, intent: .defaultIntent, options: nil),
            "UIKit could not convert the color to sRGB.",
            file: file,
            line: line
        )
        let components = try XCTUnwrap(native.components, file: file, line: line)
        let rgba = try XCTUnwrap(
            components.count == 4 ? components : nil,
            "Expected four components after sRGB conversion.",
            file: file,
            line: line
        )
        return SRGBComponents(
            red: Double(rgba[0]),
            green: Double(rgba[1]),
            blue: Double(rgba[2]),
            alpha: Double(rgba[3])
        )
        #else
        #error("NativeTokenColor tests cover only the declared iOS and macOS platforms.")
        #endif
    }
}
