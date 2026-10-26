import XCTest

@MainActor
final class ProgressBarReviewUITests: XCTestCase {
    func testStrataProgressUpdatesNormalizationAndStableFootprint() {
        let app = launch(scenario: "interaction")
        let progress = app.progressIndicators["progress-target"]
        XCTAssertTrue(progress.exists, app.debugDescription)
        XCTAssertEqual(progress.label, "Preparing files")
        let footprint = renderedSize(app.staticTexts["progress-footprint"])
        let next = app.buttons["next-state"]
        XCTAssertGreaterThanOrEqual((next.frame.width * 1_000).rounded() / 1_000, 44)
        XCTAssertGreaterThanOrEqual((next.frame.height * 1_000).rounded() / 1_000, 44)
        let expected = ["0%", "50%", "100%", "", "0%", "100%"]
        for state in expected.indices {
            XCTAssertEqual(app.staticTexts["caller-state"].label, "State: \(state)")
            let indicator = state == 3 ? app.activityIndicators["progress-target"] : progress
            XCTAssertTrue(indicator.exists, app.debugDescription)
            XCTAssertEqual(indicator.label, "Preparing files")
            if state == 3 {
                XCTAssertEqual(indicator.value as? String, "1", "Strata activity state must be active, rather than a fabricated percentage.")
                XCTAssertTrue(app.staticTexts["Waiting for update"].exists, app.debugDescription)
            } else {
                XCTAssertEqual(progress.value as? String, expected[state], app.debugDescription)
            }
            let rendered = renderedSize(app.staticTexts["progress-footprint"])
            XCTAssertEqual(rendered.width, footprint.width, accuracy: 0.5)
            XCTAssertEqual(rendered.height, footprint.height, accuracy: 0.5)
            XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(indicator.frame))
            if state < expected.count - 1 { next.tap() }
        }
        print("Strata progress semantics and footprint: \(footprint)")
    }

    func testLongNarrowTextGrowsAtAccessibilitySizeWithoutOverlap() {
        var app = launch(scenario: "long-label")
        let standard = renderedSize(app.staticTexts["long-footprint"])
        XCTAssertTrue(app.staticTexts["layout-safety"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["layout-safety"].label, "Layout: inside", app.debugDescription)
        print("Standard text geometry: \(app.staticTexts["layout-safety"].value ?? "missing")")
        capture("progress-bar-long-narrow", app: app)
        app.terminate()
        app = launch(scenario: "long-label", size: "accessibility2")
        let progress = app.progressIndicators["long-progress"]
        XCTAssertTrue(progress.exists, app.debugDescription)
        XCTAssertEqual(progress.label, "Vorbereitung aller ausgewählten Dateien für die nächste Übertragung")
        let accessible = renderedSize(app.staticTexts["long-footprint"])
        XCTAssertLessThanOrEqual(accessible.width, 288.5)
        XCTAssertGreaterThan(accessible.height, standard.height + 40)
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

    func testReduceMotionRequestReportsObservedSettingAndReadableIndeterminateStatus() {
        let app = launch(scenario: "matrix", motion: true)
        XCTAssertEqual(app.staticTexts["motion-request"].label, "Fixture request: Reduce Motion")
        XCTAssertTrue(app.staticTexts["motion-observed"].exists)
        print("Reduce Motion request evidence: \(app.staticTexts["motion-observed"].label)")
        let waiting = app.activityIndicators["matrix-indeterminate"]
        XCTAssertEqual(waiting.label, "Waiting")
        XCTAssertEqual(waiting.value as? String, "1", "Strata activity state must be active, rather than a fabricated percentage.")
        XCTAssertTrue(app.staticTexts["Waiting for the next update…"].exists, app.debugDescription)
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
            let progress = id == "matrix-indeterminate" ? app.activityIndicators[id] : app.progressIndicators[id]
            XCTAssertTrue(progress.exists, app.debugDescription)
            XCTAssertFalse(progress.frame.isEmpty)
            XCTAssertTrue(viewport.contains(progress.frame), "Every complete progress indicator must be onscreen: \(id)")
        }
        for current in ["0 of 100 files · 0%", "50 of 100 files · 50%", "100 of 100 files · 100%", "Waiting for the next update…"] {
            let text = app.staticTexts[current]
            XCTAssertTrue(text.exists, app.debugDescription)
            XCTAssertTrue(viewport.contains(text.frame))
        }
        XCTAssertTrue(app.frame.contains(app.staticTexts["review-end"].frame))
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func renderedSize(_ element: XCUIElement) -> CGSize {
        let parts = (element.value as? String ?? "").split(separator: "|").compactMap { Double($0) }
        XCTAssertEqual(parts.count, 2, "The SwiftUI geometry measurement must be available.")
        guard parts.count == 2 else { return .zero }
        XCTAssertGreaterThan(parts[0], 0)
        XCTAssertGreaterThan(parts[1], 0)
        return CGSize(width: parts[0], height: parts[1])
    }

    private func launch(scenario: String, brand: String = "ocean", mode: String = "light",
                        size: String = "large", motion: Bool = false, expectsError: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment = ["NDK_SCENARIO": scenario, "NDK_BRAND": brand, "NDK_THEME": mode,
                                 "NDK_TEXT_SIZE": size, "NDK_REDUCE_MOTION_REQUEST": motion ? "true" : "false"]
        app.launch()
        let ready = expectsError ? app.staticTexts["fixture-error"] : app.scrollViews["review-scroll"]
        XCTAssertTrue(ready.waitForExistence(timeout: 10), app.debugDescription)
        return app
    }
}
