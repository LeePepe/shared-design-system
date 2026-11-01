import DesignTokens
import SwiftUI
import XCTest
@testable import Strata

@available(macOS 13, iOS 16, *)
final class StrataNumericKeypadTests: XCTestCase {
    func testMetricsKeepTheClassAGridAt232Points() throws {
        let metrics = try StrataNumericKeypadMetrics()
        XCTAssertEqual(metrics.totalGridHeight, 232)
        XCTAssertEqual(metrics.digitRowHeight, metrics.actionHeight(forCount: 4))
        XCTAssertEqual(metrics.actionHeight(forCount: 2) * 2 + metrics.interRowSpacing,
                       metrics.totalGridHeight - metrics.verticalPadding * 2)
        XCTAssertGreaterThanOrEqual(metrics.compactCellRadius, 6)
        XCTAssertLessThanOrEqual(metrics.compactCellRadius, 8)
        XCTAssertGreaterThanOrEqual(metrics.interColumnSpacing, 6)
        XCTAssertLessThanOrEqual(metrics.interColumnSpacing, 8)
        XCTAssertGreaterThanOrEqual(metrics.interRowSpacing, 6)
        XCTAssertLessThanOrEqual(metrics.interRowSpacing, 8)
        XCTAssertGreaterThanOrEqual(metrics.digitRowHeight, 44)
        XCTAssertEqual(metrics.actionHeight(forCount: 0), 0)
        XCTAssertEqual(metrics.minimumScaleFactor, 0.85)
    }

    func testMetricsPropagateStyleTokenErrors() {
        let expected = StyleTokenError.unknownToken("spacing.failure")
        XCTAssertThrowsError(try StrataNumericKeypadMetrics(spacing: { _ in throw expected })) {
            XCTAssertEqual($0 as? StyleTokenError, expected)
        }

        XCTAssertThrowsError(try StrataNumericKeypadMetrics(radius: { _ in throw expected })) {
            XCTAssertEqual($0 as? StyleTokenError, expected)
        }
    }

    func testConfigurationIsValueTypedAndSideActionsAreIdentifiable() {
        let action = StrataNumericKeypadSideAction(id: "clear", title: "Clear", systemImage: "xmark")
        let configuration = StrataNumericKeypadConfiguration(mode: .integer, leftActions: [action])
        XCTAssertEqual(configuration.leftActions.first?.id, "clear")
        XCTAssertEqual(configuration.mode, .integer)
    }

    @MainActor
    func testKeypadModesAndCallbacksAreBehavioral() throws {
        var received: [StrataNumericKeypadKey] = []
        let theme = try StrataTheme(theme: .light, brand: "strata-blue")
        let decimal = try StrataNumericKeypad(
            theme: theme,
            configuration: .init(mode: .decimal),
            onKey: { received.append($0) }
        )
        let integer = try StrataNumericKeypad(
            theme: theme,
            configuration: .init(mode: .integer),
            onKey: { received.append($0) }
        )

        XCTAssertEqual(decimal.digitGridSlots.compactMap { $0 }.count, 12)
        XCTAssertTrue(decimal.digitGridSlots.contains(.decimalSeparator))
        XCTAssertEqual(integer.digitGridSlots.compactMap { $0 }.count, 11)
        XCTAssertFalse(integer.digitGridSlots.contains(.decimalSeparator))
        XCTAssertEqual(integer.digitGridSlots[9], nil)

        decimal.trigger(.digit(1))
        decimal.trigger(.decimalSeparator)
        decimal.trigger(.backspace)
        decimal.trigger(.sideAction(id: "clear"))
        decimal.trigger(.done)
        XCTAssertEqual(received, [.digit(1), .decimalSeparator, .backspace, .sideAction(id: "clear"), .done])
    }

    @MainActor
    func testKeypadCanBeRenderedAtSharedScaleAndHeight() throws {
        for themeMode in [Theme.light, Theme.dark] {
            let theme = try StrataTheme(theme: themeMode, brand: "strata-blue")
            for mode in [StrataNumericKeypadMode.decimal, .integer] {
                let keypad = try StrataNumericKeypad(
                    theme: theme,
                    configuration: .init(
                        mode: mode,
                        leftActions: [.init(id: "clear", title: "Clear")],
                        rightActions: [.init(id: "next", title: "Next")]
                    ),
                    colorScheme: themeMode == .light ? .light : .dark
                ) { _ in }
                let renderer = ImageRenderer(content: keypad.frame(width: 356))
                renderer.scale = 2
                let image = try XCTUnwrap(renderer.cgImage)
                XCTAssertEqual(image.width, 712)
                XCTAssertEqual(image.height, 464)

                let pixels = try NumericKeypadPixels(image)
                let surface = try NumericKeypadPixels(
                    ImageRenderer(content: theme.surface.frame(width: 1, height: 1)).cgImage!
                )
                let fill = surface.rgb(x: 0, y: 0)
                for y in [12, 452] {
                    XCTAssertGreaterThan(
                        pixels.runs(matching: fill, y: y).count,
                        0,
                        "keypad columns should share the \(y) edge band"
                    )
                }
            }

        }
    }
}

@available(macOS 13, iOS 16, *)
private struct NumericKeypadPixels {
    let width: Int
    let bytes: [UInt8]

    init(_ image: CGImage) throws {
        width = image.width
        var storage = [UInt8](repeating: 0, count: image.width * image.height * 4)
        try storage.withUnsafeMutableBytes { buffer in
            let context = try XCTUnwrap(CGContext(
                data: buffer.baseAddress,
                width: image.width,
                height: image.height,
                bitsPerComponent: 8,
                bytesPerRow: image.width * 4,
                space: CGColorSpace(name: CGColorSpace.sRGB)!,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ))
            context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        }
        bytes = storage
    }

    func rgb(x: Int, y: Int) -> [UInt8] {
        let offset = (y * width + x) * 4
        return Array(bytes[offset..<(offset + 3)])
    }

    func runs(matching color: [UInt8], y: Int) -> [Range<Int>] {
        var ranges: [Range<Int>] = []
        var start: Int?
        for x in 0...width {
            let matches = x < width && rgb(x: x, y: y) == color
            if matches, start == nil { start = x }
            if !matches, let lower = start {
                ranges.append(lower..<x)
                start = nil
            }
        }
        return ranges
    }
}
