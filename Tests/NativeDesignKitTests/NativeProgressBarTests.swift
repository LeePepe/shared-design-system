import DesignTokens
import SwiftUI
import XCTest
@testable import NativeDesignKit

final class NativeProgressBarTests: XCTestCase {
    func testFiniteRangeNormalizesWithoutOverflow() {
        let cases: [(Double, Double, Double)] = [
            (-20, 100, 0), (0, 100, 0), (50, 100, 50), (100, 100, 100),
            (200, 100, 100), (-Double.greatestFiniteMagnitude, 1, 0),
            (Double.greatestFiniteMagnitude, 1, 1),
            (Double.leastNonzeroMagnitude, Double.leastNonzeroMagnitude, Double.leastNonzeroMagnitude),
            (Double.greatestFiniteMagnitude, Double.greatestFiniteMagnitude, Double.greatestFiniteMagnitude)
        ]
        for (input, total, expected) in cases {
            let progress = NativeProgressBarValue(value: input, total: total)
            XCTAssertEqual(progress.value, expected)
            XCTAssertEqual(progress.total, total)
        }
    }

    func testNilRemainsIndeterminateWithExplicitTotal() {
        let progress = NativeProgressBarValue(value: nil, total: 200)
        XCTAssertNil(progress.value)
        XCTAssertEqual(progress.total, 200)
    }

    func testPreconditionPolicyRejectsUndefinedInputs() {
        for total in [0, -1, Double.nan, .infinity, -.infinity] {
            XCTAssertFalse(NativeProgressBarValue.accepts(value: 0, total: total))
            XCTAssertFalse(NativeProgressBarValue.accepts(value: nil, total: total))
        }
        for value in [Double.nan, .infinity, -.infinity] {
            XCTAssertFalse(NativeProgressBarValue.accepts(value: value, total: 100))
        }
        for value: Double? in [nil, -1, 0, 50, 100, 101] {
            XCTAssertTrue(NativeProgressBarValue.accepts(value: value, total: 100))
        }
    }

    @MainActor
    func testPublicConstructionAcrossStatesBrandsAndModes() throws {
        for brand in ["ocean", "graphite"] {
            for mode in Theme.allCases {
                let theme = try NativeDesignTheme(theme: mode, brand: brand)
                for value: Double? in [0, 50, 100, nil] {
                    _ = NativeProgressBar(theme: theme, value: value, total: 100) {
                        Label("Synthetic progress", systemImage: "tray")
                    } currentValueLabel: {
                        VStack { Text("Caller-formatted status"); Text("Localized detail") }
                    }
                }
            }
        }
    }
}
