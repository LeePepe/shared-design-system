import XCTest

@MainActor
final class ProgressBarReviewUITests: XCTestCase {
    func testNativeProgressUpdatesNormalizationAndStableFootprint() {
        let app = launch(scenario: "interaction")
        let progress = app.progressIndicators["progress-target"]
        XCTAssertTrue(progress.exists, app.debugDescription)
        XCTAssertEqual(progress.label, "Preparing files")
        let footprint = progress.frame
        let next = app.buttons["next-state"]
        XCTAssertGreaterThanOrEqual((next.frame.width * 1_000).rounded() / 1_000, 44)
        XCTAssertGreaterThanOrEqual((next.frame.height * 1_000).rounded() / 1_000, 44)
        let expected = ["0%", "50%", "100%", "Waiting for update", "0%", "100%"]
        for state in expected.indices {
            XCTAssertEqual(app.staticTexts["caller-state"].label, "State: \(state)")
            if state == 3 {
                XCTAssertTrue(String(describing: progress.value).contains(expected[state]), app.debugDescription)
            } else {
                XCTAssertEqual(progress.value as? String, expected[state], app.debugDescription)
            }
            XCTAssertEqual(progress.frame.width, footprint.width, accuracy: 0.5)
            XCTAssertEqual(progress.frame.height, footprint.height, accuracy: 0.5)
            XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(progress.frame))
            if state < expected.count - 1 { next.tap() }
        }
        print("Native progress semantics and footprint: \(footprint)")
    }

    func testLongNarrowTextGrowsAtAccessibilitySizeWithoutOverlap() {
        var app = launch(scenario: "long-label")
        let standard = app.progressIndicators["long-progress"].frame
        XCTAssertTrue(app.staticTexts["layout-safety"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["layout-safety"].label, "Layout: inside", app.debugDescription)
        print("Standard text geometry: \(app.staticTexts["layout-safety"].value ?? "missing")")
        capture("progress-bar-long-narrow", app: app)
        app.terminate()
        app = launch(scenario: "long-label", size: "accessibility2")
        let progress = app.progressIndicators["long-progress"]
        XCTAssertTrue(progress.exists, app.debugDescription)
        XCTAssertEqual(progress.label, "Vorbereitung aller ausgewählten Dateien für die nächste Übertragung")
        XCTAssertLessThanOrEqual(progress.frame.width, 288.5)
        XCTAssertGreaterThan(progress.frame.height, standard.height + 40)
        XCTAssertEqual(app.staticTexts["layout-safety"].label, "Layout: inside", app.debugDescription)
        XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(progress.frame))
        XCTAssertTrue(app.frame.contains(app.staticTexts["review-end"].frame))
        print("Accessibility text geometry: \(app.staticTexts["layout-safety"].value ?? "missing")")
        capture("progress-bar-accessibility-narrow", app: app)
    }

    func testVisualMatrixOceanLight() { matrix(brand: "ocean", mode: "light") }
    func testVisualMatrixOceanDark() { matrix(brand: "ocean", mode: "dark") }
    func testVisualMatrixGraphiteLight() { matrix(brand: "graphite", mode: "light") }
    func testVisualMatrixGraphiteDark() { matrix(brand: "graphite", mode: "dark") }

    func testReduceMotionEnvironmentRequestRetainsReadableIndeterminateStatus() {
        let app = launch(scenario: "matrix", motion: true)
        XCTAssertEqual(app.staticTexts["motion-request"].label, "Reduce Motion requested in SwiftUI environment")
        let waiting = app.progressIndicators["matrix-indeterminate"]
        XCTAssertEqual(waiting.label, "Waiting")
        XCTAssertTrue(String(describing: waiting.value).contains("Waiting for the next update"), app.debugDescription)
        assertMatrixVisible(app)
        capture("progress-bar-reduced-motion-request", app: app)
    }

    func testInvalidBrandShowsErrorWithoutProgressFallback() {
        let app = launch(scenario: "matrix", brand: "__unknown_brand__", expectsError: true)
        XCTAssertTrue(app.staticTexts["fixture-error"].label.contains("__unknown_brand__"))
        XCTAssertEqual(app.progressIndicators.count, 0)
    }

    private func matrix(brand: String, mode: String) {
        let app = launch(scenario: "matrix", brand: brand, mode: mode)
        assertMatrixVisible(app)
        XCTAssertEqual(app.progressIndicators["matrix-zero"].value as? String, "0%")
        XCTAssertEqual(app.progressIndicators["matrix-mid"].value as? String, "50%")
        XCTAssertEqual(app.progressIndicators["matrix-complete"].value as? String, "100%")
        capture("progress-bar-\(brand)-\(mode)", app: app)
    }

    private func assertMatrixVisible(_ app: XCUIApplication) {
        let viewport = app.scrollViews["review-scroll"].frame
        for id in ["matrix-zero", "matrix-mid", "matrix-complete", "matrix-indeterminate"] {
            let progress = app.progressIndicators[id]
            XCTAssertTrue(progress.exists, app.debugDescription)
            XCTAssertFalse(progress.frame.isEmpty)
            XCTAssertTrue(viewport.contains(progress.frame), "Every complete progress indicator must be onscreen: \(id)")
        }
        XCTAssertTrue(app.frame.contains(app.staticTexts["review-end"].frame))
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func launch(scenario: String, brand: String = "ocean", mode: String = "light",
                        size: String = "large", motion: Bool = false, expectsError: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment = ["NDK_SCENARIO": scenario, "NDK_BRAND": brand, "NDK_THEME": mode,
                                 "NDK_TEXT_SIZE": size, "NDK_REDUCE_MOTION": motion ? "true" : "false"]
        app.launch()
        let ready = expectsError ? app.staticTexts["fixture-error"] : app.scrollViews["review-scroll"]
        XCTAssertTrue(ready.waitForExistence(timeout: 10), app.debugDescription)
        return app
    }
}
