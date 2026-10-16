import XCTest

@MainActor
final class ChipReviewUITests: XCTestCase {
    func testNativeRemovalDisabledBlockingAndStaticContent() {
        let app = launch(scenario: "interaction")
        let remove = app.buttons["Remove research note"]
        minimumTarget(remove)
        XCTAssertEqual(remove.label, "Remove research note")
        XCTAssertFalse(app.buttons["Static content"].exists)
        app.staticTexts["static-content"].tap()
        app.staticTexts["action-label"].tap()
        XCTAssertEqual(app.staticTexts["action-count"].label, "Removals: 0")
        let initial = app.staticTexts["action-geometry"].value as? String
        remove.tap()
        XCTAssertEqual(app.staticTexts["action-count"].label, "Removals: 1")
        XCTAssertTrue(app.staticTexts["action-label"].exists, "The component must leave removal state with the caller.")
        app.buttons["toggle-disabled"].tap()
        XCTAssertFalse(remove.isEnabled)
        XCTAssertEqual(app.staticTexts["action-geometry"].value as? String, initial,
                       "Disabled appearance must preserve the chip's footprint.")
        for _ in 0..<3 { remove.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
        XCTAssertEqual(app.staticTexts["action-count"].label, "Removals: 1")
        app.buttons["toggle-disabled"].tap()
        remove.tap()
        XCTAssertEqual(app.staticTexts["action-count"].label, "Removals: 2")
        app.buttons["Remove temporary note"].tap()
        XCTAssertEqual(app.staticTexts["caller-state"].label, "Caller removed item")
        XCTAssertFalse(app.staticTexts["owned-label"].exists)
    }

    func testLongNarrowAccessibilityGrowthAndFillSafety() {
        var app = launch(scenario: "long-label")
        let standardStatic = app.staticTexts["long-static-label"].frame
        let standardRemovable = app.staticTexts["long-removable-label"].frame
        app.terminate()
        app = launch(scenario: "long-label", size: "accessibility2", mode: "dark")
        let text = "Forschungsnotizen und ausführliche Beschreibungen gemeinsam organisieren"
        let staticLabel = app.staticTexts["long-static-label"]
        let removableLabel = app.staticTexts["long-removable-label"]
        for label in [staticLabel, removableLabel] {
            XCTAssertEqual(label.label, text)
            XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(label.frame))
            XCTAssertLessThanOrEqual(label.frame.width, 288)
        }
        XCTAssertGreaterThan(staticLabel.frame.height, standardStatic.height + 20)
        XCTAssertGreaterThan(removableLabel.frame.height, standardRemovable.height + 20)
        XCTAssertEqual(app.staticTexts["static-safety"].label, "Static shape: inside")
        XCTAssertEqual(app.staticTexts["removable-safety"].label, "Removable shape: inside")
        XCTAssertTrue(String(describing: app.staticTexts["static-safety"].value).contains("capsule=outside"),
                      "The actual multiline fixture must exercise the rejected capsule geometry.")
        let remove = app.buttons["Forschungsnotiz entfernen"]
        minimumTarget(remove)
        XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(remove.frame))
        XCTAssertTrue(app.frame.contains(app.staticTexts["long-end"].frame))
        capture("chip-accessibility-narrow", app)
        remove.tap()
        XCTAssertEqual(app.staticTexts["action-count"].label, "Removals: 1")
        XCTAssertEqual(removableLabel.label, text)
        print("Chip long text: standard static=\(standardStatic), large static=\(staticLabel.frame), " +
              "standard removable=\(standardRemovable), large removable=\(removableLabel.frame)")
        print("Fill safety: \(app.staticTexts["static-safety"].value ?? "missing"); " +
              "\(app.staticTexts["removable-safety"].value ?? "missing")")
    }

    func testVisualOceanLight() { matrix(brand: "ocean", mode: "light") }
    func testVisualOceanDark() { matrix(brand: "ocean", mode: "dark") }
    func testVisualGraphiteLight() { matrix(brand: "graphite", mode: "light") }
    func testVisualGraphiteDark() { matrix(brand: "graphite", mode: "dark") }

    func testInvalidBrandIsVisibleWithoutFallback() {
        let app = launch(scenario: "matrix", brand: "__invalid_chip_brand__", expectsError: true)
        XCTAssertTrue(app.staticTexts["fixture-error"].label.contains("__invalid_chip_brand__"))
        XCTAssertFalse(app.buttons["Remove neutral item"].exists)
    }

    private func matrix(brand: String, mode: String) {
        let app = launch(scenario: "matrix", brand: brand, mode: mode)
        for tone in ["neutral", "accent", "critical"] {
            let label = app.staticTexts["static-\(tone)"]
            XCTAssertTrue(label.exists)
            XCTAssertFalse(app.buttons["\(tone.capitalized) static"].exists)
            XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(label.frame))
            for disabled in [false, true] {
                let button = app.buttons["Remove \(disabled ? "disabled " : "")\(tone) item"]
                minimumTarget(button)
                XCTAssertEqual(button.isEnabled, !disabled)
                XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(button.frame))
            }
        }
        XCTAssertTrue(app.frame.contains(app.staticTexts["matrix-end"].frame))
        capture("chip-\(brand)-\(mode)", app)
    }

    private func minimumTarget(_ button: XCUIElement) {
        XCTAssertTrue(button.exists)
        // AX edge conversion may report 43.999969 for a true 44 pt frame.
        // Rounding to 1/1000 pt permits only subpixel arithmetic noise.
        XCTAssertGreaterThanOrEqual((button.frame.width * 1000).rounded() / 1000, 44)
        XCTAssertGreaterThanOrEqual((button.frame.height * 1000).rounded() / 1000, 44)
    }

    private func capture(_ name: String, _ app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func launch(scenario: String, size: String = "large", brand: String = "ocean",
                        mode: String = "light", expectsError: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment = ["NDK_SCENARIO": scenario, "NDK_TEXT_SIZE": size,
                                 "NDK_BRAND": brand, "NDK_THEME": mode]
        app.launch()
        let ready = expectsError ? app.staticTexts["fixture-error"] : app.scrollViews["review-scroll"]
        XCTAssertTrue(ready.waitForExistence(timeout: 10), app.debugDescription)
        return app
    }
}
