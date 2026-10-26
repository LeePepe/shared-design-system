import XCTest

@MainActor
final class SliderReviewUITests: XCTestCase {
    func testStrataAdjustmentUpdatesBindingInCallerUnitsAndForwardsEditing() {
        let app = launch(scenario: "interaction")
        let slider = app.sliders["adjustable"]
        XCTAssertEqual(slider.label, "Synthetic amount")
        XCTAssertTrue(slider.isEnabled)
        XCTAssertTrue(slider.isHittable)
        let initialAXValue = String(describing: slider.value)
        slider.adjust(toNormalizedSliderPosition: 0.8)
        let updated = boundValue(app)
        XCTAssertGreaterThan(updated, 0)
        XCTAssertLessThanOrEqual(updated, 50)
        XCTAssertEqual(updated.truncatingRemainder(dividingBy: 5), 0, accuracy: 0.001)
        XCTAssertNotEqual(String(describing: slider.value), initialAXValue)
        let events = editingEvents(app)
        XCTAssertGreaterThan(events.starts, 0)
        XCTAssertEqual(events.starts, events.ends)
        XCTAssertFalse(events.editing)
        slider.adjust(toNormalizedSliderPosition: 0)
        XCTAssertEqual(boundValue(app), -50)
        slider.adjust(toNormalizedSliderPosition: 1)
        XCTAssertEqual(boundValue(app), 50)
    }

    func testDisabledStrataInputCannotChangeBindingOrEditingEffects() {
        let app = launch(scenario: "interaction")
        let slider = app.sliders["adjustable"]
        slider.adjust(toNormalizedSliderPosition: 0.7)
        let before = boundValue(app)
        let events = app.staticTexts["editing-events"].label
        app.buttons["toggle-disabled"].tap()
        XCTAssertFalse(slider.isEnabled)
        slider.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5))
            .press(forDuration: 0.1, thenDragTo: slider.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.5)))
        XCTAssertEqual(boundValue(app), before)
        XCTAssertEqual(app.staticTexts["editing-events"].label, events)
        app.buttons["toggle-disabled"].tap()
        slider.adjust(toNormalizedSliderPosition: 0.2)
        XCTAssertLessThan(boundValue(app), before)
    }

    func testCallerUpdatesAndDisabledStatePreserveStrataFootprint() {
        let app = launch(scenario: "interaction")
        let slider = app.sliders["adjustable"]
        let initial = slider.frame
        assertMinimumTarget(slider)
        for (button, expected) in [("minimum", -50.0), ("maximum", 50.0), ("midpoint", 0.0)] {
            app.buttons["set-\(button)"].tap()
            XCTAssertEqual(boundValue(app), expected)
            assertFrame(slider.frame, equals: initial)
        }
        app.buttons["toggle-disabled"].tap()
        assertFrame(slider.frame, equals: initial)
        XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(slider.frame))
    }

    func testStrataTouchTargetIncludesTopAndBottomOf44PointFrame() {
        let app = launch(scenario: "interaction")
        let slider = app.sliders["adjustable"]
        assertMinimumTarget(slider)
        for edge in [0.02, 0.98] {
            app.buttons["set-midpoint"].tap()
            slider.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: edge))
                .press(forDuration: 0.1, thenDragTo: slider.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: edge)))
            XCTAssertGreaterThan(boundValue(app), 0, "The entire 44 pt frame must accept native adjustment, including its edges")
        }
    }

    func testLongLabelAndEndpointsGrowAtAccessibilitySizeWithinNarrowBoard() {
        var app = launch(scenario: "long-label")
        let standard = metrics(app)
        app.terminate()
        app = launch(scenario: "long-label", size: "accessibility2")
        let accessible = metrics(app)
        XCTAssertGreaterThan(accessible["height", default: 0], standard["height", default: 0] + 40)
        XCTAssertGreaterThan(accessible["titleHeight", default: 0], standard["titleHeight", default: 0] + 20)
        XCTAssertLessThanOrEqual(accessible["width", default: 1000], 288.001)
        XCTAssertTrue(app.staticTexts["layout-metrics"].value.debugDescription.contains("titleInside=true"))
        let slider = app.sliders["long"]
        XCTAssertEqual(slider.label, "Lautstärke für alle verbundenen Geräte gemeinsam einstellen")
        assertMinimumTarget(slider)
        let viewport = app.scrollViews["review-scroll"].frame
        for element in [slider, app.staticTexts["Leise Wiedergabe"], app.staticTexts["Laute Wiedergabe"], app.staticTexts["long-end"]] {
            XCTAssertTrue(element.exists)
            XCTAssertTrue(viewport.contains(element.frame), "Long content must remain fully onscreen: \(element)")
        }
        let minimum = app.staticTexts["Leise Wiedergabe"].frame
        let maximum = app.staticTexts["Laute Wiedergabe"].frame
        XCTAssertLessThanOrEqual(slider.frame.maxY, minimum.minY + 0.001)
        XCTAssertLessThanOrEqual(minimum.maxX, maximum.minX)
        XCTAssertEqual(minimum.minY, maximum.minY, accuracy: 0.001)
        capture("slider-accessibility-narrow", app: app)
        print("Slider narrow metrics: standard=\(standard), accessibility2=\(accessible)")
    }

    func testVisualMatrixOceanLight() { matrix(brand: "ocean", mode: "light") }
    func testVisualMatrixOceanDark() { matrix(brand: "ocean", mode: "dark") }
    func testVisualMatrixGraphiteLight() { matrix(brand: "graphite", mode: "light") }
    func testVisualMatrixGraphiteDark() { matrix(brand: "graphite", mode: "dark") }

    func testUnknownBrandShowsExactErrorWithoutControl() {
        let app = launch(scenario: "matrix", brand: "__unknown_brand__", expectsError: true)
        XCTAssertTrue(app.staticTexts["fixture-error"].label.contains("__unknown_brand__"))
        XCTAssertEqual(app.sliders.count, 0)
    }

    private func matrix(brand: String, mode: String) {
        let app = launch(scenario: "matrix", brand: brand, mode: mode)
        var frames: [CGRect] = []
        for state in ["minimum", "midpoint", "maximum", "disabled"] {
            let slider = app.sliders["matrix-\(state)"]
            XCTAssertTrue(slider.exists)
            XCTAssertEqual(slider.isEnabled, state != "disabled")
            assertMinimumTarget(slider)
            XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(slider.frame))
            frames.append(slider.frame)
        }
        for frame in frames.dropFirst() {
            XCTAssertEqual(frame.width, frames[0].width, accuracy: 0.001)
            XCTAssertEqual(frame.height, frames[0].height, accuracy: 0.001)
        }
        XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(app.staticTexts["matrix-end"].frame))
        capture("slider-\(brand)-\(mode)", app: app)
    }

    private func boundValue(_ app: XCUIApplication) -> Double {
        let text = app.staticTexts["bound-value"].label
        guard let value = Double(text.replacingOccurrences(of: "Value: ", with: "").replacingOccurrences(of: " units", with: "")) else {
            XCTFail("Missing caller value: \(text)")
            return .nan
        }
        return value
    }

    private func editingEvents(_ app: XCUIApplication) -> (starts: Int, ends: Int, editing: Bool) {
        let fields = app.staticTexts["editing-events"].label.components(separatedBy: "; ")
        return (Int(fields[0].replacingOccurrences(of: "Starts: ", with: "")) ?? -1,
                Int(fields[1].replacingOccurrences(of: "ends: ", with: "")) ?? -2,
                fields[2] == "editing: true")
    }

    private func metrics(_ app: XCUIApplication) -> [String: Double] {
        let element = app.staticTexts["layout-metrics"]
        let ready = NSPredicate(format: "value CONTAINS %@", "titleInside=true")
        expectation(for: ready, evaluatedWith: element)
        waitForExpectations(timeout: 5)
        let text = String(describing: element.value ?? "")
        var result: [String: Double] = [:]
        for field in text.components(separatedBy: ";") {
            let pair = field.components(separatedBy: "=")
            if pair.count == 2, let value = Double(pair[1]) { result[pair[0]] = value }
        }
        return result
    }

    private func assertMinimumTarget(_ element: XCUIElement) {
        // AX edges can turn an exact 44 pt frame into 43.999969 pt.
        XCTAssertGreaterThanOrEqual((element.frame.width * 1000).rounded() / 1000, 44)
        XCTAssertGreaterThanOrEqual((element.frame.height * 1000).rounded() / 1000, 44)
    }

    private func assertFrame(_ frame: CGRect, equals expected: CGRect) {
        XCTAssertEqual(frame.minX, expected.minX, accuracy: 0.001)
        XCTAssertEqual(frame.minY, expected.minY, accuracy: 0.001)
        XCTAssertEqual(frame.width, expected.width, accuracy: 0.001)
        XCTAssertEqual(frame.height, expected.height, accuracy: 0.001)
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func launch(scenario: String, brand: String = "ocean", mode: String = "light",
                        size: String = "large", expectsError: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment = ["NDK_SCENARIO": scenario, "NDK_BRAND": brand, "NDK_THEME": mode, "NDK_TEXT_SIZE": size]
        app.launch()
        let ready = expectsError ? app.staticTexts["fixture-error"] : app.scrollViews["review-scroll"]
        XCTAssertTrue(ready.waitForExistence(timeout: 10), app.debugDescription)
        return app
    }
}
