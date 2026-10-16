import XCTest

@MainActor
final class ButtonReviewUITests: XCTestCase {
    func testActionDispatchAndDisabledLoadingCoordinateTaps() {
        let app = launch(scenario: "interaction")
        let target = app.buttons["action-target"]
        XCTAssertTrue(target.isEnabled)
        target.tap()
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 1")

        app.buttons["toggle-disabled"].tap()
        XCTAssertFalse(target.isEnabled)
        for _ in 0..<3 { target.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 1")

        app.buttons["toggle-disabled"].tap()
        app.buttons["toggle-loading"].tap()
        XCTAssertFalse(target.isEnabled)
        for _ in 0..<3 { target.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 1")
        app.buttons["toggle-loading"].tap()
        target.tap()
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 2")
    }

    func testLoadingPreservesFootprintAndMinimumTarget() {
        let app = launch(scenario: "interaction")
        let target = app.buttons["action-target"]
        let idle = target.frame
        XCTAssertGreaterThanOrEqual(idle.width, 44)
        XCTAssertGreaterThanOrEqual(idle.height, 44)
        app.buttons["toggle-loading"].tap()
        XCTAssertEqual(app.staticTexts["loading-state"].label, "Loading")
        XCTAssertEqual(target.frame.width, idle.width, accuracy: 0.5)
        XCTAssertEqual(target.frame.height, idle.height, accuracy: 0.5)
        XCTAssertTrue(app.frame.contains(target.frame))
        print("Button footprint: idle=\(idle), loading=\(target.frame)")
    }

    func testLongLocalizedAccessibilityGrowthWithinNarrowBoard() {
        var app = launch(scenario: "long-label", language: "de")
        let standard = app.buttons["long-target"].frame
        XCTAssertGreaterThanOrEqual(standard.height, 44)
        app.terminate()
        app = launch(scenario: "long-label", size: "accessibility2", language: "de")
        let target = app.buttons["long-target"]
        let accessible = target.frame
        XCTAssertGreaterThan(accessible.height, standard.height + 20)
        XCTAssertGreaterThanOrEqual(accessible.width, 44)
        XCTAssertLessThanOrEqual(accessible.width, 272.5)
        assertFullLabel("Auswahl bestätigen und alle Änderungen speichern", inside: target, app: app)
        capture("button-accessibility-narrow", app: app)
        app.buttons["toggle-loading"].tap()
        XCTAssertEqual(target.frame.width, accessible.width, accuracy: 0.5)
        XCTAssertEqual(target.frame.height, accessible.height, accuracy: 0.5)
        assertFullLabel("Auswahl vorbereiten und alle Änderungen speichern…", inside: target, app: app)
        print("iOS localized layout: standard=\(standard), accessibility2=\(accessible), loading=\(target.frame)")
    }

    func testVisualMatrixOceanLight() { matrix(brand: "ocean", mode: "light") }
    func testVisualMatrixOceanDark() { matrix(brand: "ocean", mode: "dark") }
    func testVisualMatrixGraphiteLight() { matrix(brand: "graphite", mode: "light") }
    func testVisualMatrixGraphiteDark() { matrix(brand: "graphite", mode: "dark") }

    func testInvalidBrandShowsErrorWithoutFallback() {
        let app = launch(scenario: "matrix", brand: "__unknown_brand__", expectsError: true)
        XCTAssertTrue(app.staticTexts["fixture-error"].label.contains("__unknown_brand__"))
        XCTAssertFalse(app.buttons["matrix-primary-normal"].exists)
    }

    private func matrix(brand: String, mode: String) {
        let app = launch(scenario: "matrix", brand: brand, mode: mode)
        let scale = screenshotScale(app)
        for variant in ["primary", "secondary", "ghost"] {
            for state in ["normal", "loading", "disabled"] {
                let button = app.buttons["matrix-\(variant)-\(state)"]
                XCTAssertTrue(button.exists)
                XCTAssertEqual(button.isEnabled, state == "normal")
                assertMinimumTarget(button, scale: scale)
                XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(button.frame),
                              "Every matrix button must be fully onscreen before capture: \(variant)/\(state)")
            }
        }
        XCTAssertTrue(app.frame.contains(app.staticTexts["matrix-end"].frame))
        capture("button-\(brand)-\(mode)", app: app)
    }

    private func screenshotScale(_ app: XCUIApplication) -> CGFloat {
        // PNG IHDR width gives physical pixels without importing a UI framework.
        let png = [UInt8](app.screenshot().pngRepresentation)
        let pixels = png[16..<20].reduce(0) { ($0 << 8) | Int($1) }
        return CGFloat(pixels) / app.frame.width
    }

    private func assertMinimumTarget(_ button: XCUIElement, scale: CGFloat) {
        // AX uses floating point edges (e.g. a 44 pt height can be 43.999969).
        // Measure the rendered pixel edges; the minimum remains exactly 44 pt.
        let frame = button.frame
        let width = (frame.maxX * scale).rounded() - (frame.minX * scale).rounded()
        let height = (frame.maxY * scale).rounded() - (frame.minY * scale).rounded()
        XCTAssertGreaterThanOrEqual(width, (44 * scale).rounded(.up))
        XCTAssertGreaterThanOrEqual(height, (44 * scale).rounded(.up))
    }

    private func assertFullLabel(_ text: String, inside button: XCUIElement, app: XCUIApplication) {
        XCTAssertEqual(button.label, text)
        let label = button.staticTexts[text]
        XCTAssertTrue(label.exists, "The active localized text must be accessible.")
        XCTAssertTrue(button.frame.insetBy(dx: -0.5, dy: -0.5).contains(label.frame),
                      "The full text frame must stay within the button.")
        XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(button.frame))
        XCTAssertTrue(button.isHittable)
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func launch(scenario: String, brand: String = "ocean", mode: String = "light",
                        size: String = "large", language: String = "en", expectsError: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment = ["NDK_SCENARIO": scenario, "NDK_BRAND": brand, "NDK_THEME": mode,
                                 "NDK_TEXT_SIZE": size, "NDK_LANGUAGE": language]
        app.launch()
        let ready = expectsError ? app.staticTexts["fixture-error"] : app.scrollViews["review-scroll"]
        XCTAssertTrue(ready.waitForExistence(timeout: 10), app.debugDescription)
        return app
    }
}
