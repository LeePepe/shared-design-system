import DesignTokens
import SwiftUI
import XCTest
@testable import NativeDesignKit

final class NativeSliderTests: XCTestCase {
    func testFiniteIncreasingBoundsAndPositiveStepsAcceptNativeUnits() throws {
        for (range, step) in [(-50.0...50.0, 5.0), (0.25...1.0, 0.1), (10.0...20.0, 50.0)] {
            try NativeSliderConfiguration.validate(range: range, step: step)
        }
    }

    func testInvalidRangesRejectNonfiniteDegenerateAndOverflowingSpans() {
        for range in [0.0...Double.infinity, -Double.infinity...1.0, 4.0...4.0,
                      -Double.greatestFiniteMagnitude...Double.greatestFiniteMagnitude] {
            XCTAssertThrowsError(try NativeSliderConfiguration.validate(range: range, step: 1)) {
                XCTAssertEqual($0 as? NativeSliderConfigurationError, .invalidRange)
            }
        }
    }

    func testInvalidStepsRejectZeroNegativeNaNAndInfinities() {
        for step in [0, -1, Double.nan, Double.infinity, -Double.infinity] {
            XCTAssertThrowsError(try NativeSliderConfiguration.validate(range: 0...100, step: step)) {
                XCTAssertEqual($0 as? NativeSliderConfigurationError, .invalidStep)
            }
        }
    }

    @MainActor
    func testPublicConstructionPreservesCallerStateAndGenericBuildersAcrossThemes() throws {
        for mode in [Theme.light, .dark] {
            for brand in ["ocean", "graphite"] {
                var stored = 35.0
                var writes = 0
                var editing: [Bool] = []
                var builders: [String] = []
                let binding = Binding(get: { stored }, set: { stored = $0; writes += 1 })
                _ = try NativeSlider(theme: NativeDesignTheme(theme: mode, brand: brand), value: binding,
                                     in: -50...50, step: 5, onEditingChanged: { editing.append($0) }) {
                    builders.append("label")
                    return Label("Synthetic value", systemImage: "slider.horizontal.3")
                } minimumValueLabel: {
                    builders.append("minimum")
                    return Text("−50 units")
                } maximumValueLabel: {
                    builders.append("maximum")
                    return HStack { Text("50"); Text("units") }
                }
                XCTAssertEqual(stored, 35)
                XCTAssertEqual(writes, 0)
                XCTAssertTrue(editing.isEmpty)
                XCTAssertEqual(builders, ["label", "minimum", "maximum"])
            }
        }
    }

    @MainActor
    func testPublicInitializerRejectsConfigurationBeforeBuildersOrSideEffects() throws {
        let theme = try NativeDesignTheme(theme: .light, brand: "ocean")
        for (range, step, expected) in [(0.0...Double.infinity, 1.0, NativeSliderConfigurationError.invalidRange),
                                        (0.0...1.0, 0.0, .invalidStep)] {
            let binding = Binding<Double>(get: { 0.5 }, set: { _ in XCTFail("Must not change caller state") })
            XCTAssertThrowsError(try NativeSlider(theme: theme, value: binding, in: range, step: step,
                                                 onEditingChanged: { _ in XCTFail("Must not begin editing") }) {
                XCTFail("Invalid configuration must be rejected before content is evaluated")
                return Text("Value")
            } minimumValueLabel: { Text("Minimum") } maximumValueLabel: { Text("Maximum") }) {
                XCTAssertEqual($0 as? NativeSliderConfigurationError, expected)
            }
        }
    }
}
