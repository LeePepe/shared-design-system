import XCTest

@MainActor final class RadioGroupReviewUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    func testStrataBindingSelectionDisabledAndExternalWrites() {
        let app = launch(scenario: "interaction")
        print("INITIAL NATIVE PICKER TREE\n\(app.debugDescription)")
        let compact = option("option-compact-id", app: app)
        let balanced = option("option-balanced-id", app: app)
        let detailed = option("option-detail-id", app: app)
        let originalFrames = [compact.frame, balanced.frame, detailed.frame]
        assertSelection(balanced, others: [compact, detailed])
        compact.tap()
        XCTAssertEqual(app.staticTexts["selection-state"].label, "Selected: compact-id")
        XCTAssertEqual(app.staticTexts["write-count"].label, "Writes: 1")
        assertSelection(compact, others: [balanced, detailed])
        for (element, frame) in zip([compact, balanced, detailed], originalFrames) {
            assertSameFrame(element.frame, frame)
        }

        app.buttons["toggle-disabled"].tap()
        XCTAssertFalse(detailed.isEnabled)
        detailed.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        XCTAssertEqual(app.staticTexts["selection-state"].label, "Selected: compact-id")
        for (element, frame) in zip([compact, balanced, detailed], originalFrames) {
            assertSameFrame(element.frame, frame)
        }
        XCTAssertEqual(app.staticTexts["write-count"].label, "Writes: 1")
        app.buttons["toggle-disabled"].tap()
        detailed.tap()
        XCTAssertEqual(app.staticTexts["selection-state"].label, "Selected: detail-id")
        assertSelection(detailed, others: [compact, balanced])

        app.buttons["select-external"].tap()
        assertSelection(compact, others: [balanced, detailed])
        XCTAssertEqual(app.staticTexts["selection-state"].label, "Selected: compact-id")
    }

    func testTaggedIdentitySurvivesCallerReordering() {
        let app = launch(scenario: "interaction")
        option("option-detail-id", app: app).tap()
        app.buttons["reverse-order"].tap()
        let compact = option("option-compact-id", app: app)
        let balanced = option("option-balanced-id", app: app)
        let detailed = option("option-detail-id", app: app)
        XCTAssertLessThan(detailed.frame.minY, compact.frame.minY)
        assertSelection(detailed, others: [compact, balanced])
        compact.tap()
        XCTAssertEqual(app.staticTexts["selection-state"].label, "Selected: compact-id")
        assertSelection(compact, others: [balanced, detailed])
    }

    func testVisualMatrixOceanLight() { matrix(brand: "ocean", mode: "light") }
    func testVisualMatrixOceanDark() { matrix(brand: "ocean", mode: "dark") }
    func testVisualMatrixGraphiteLight() { matrix(brand: "graphite", mode: "light") }
    func testVisualMatrixGraphiteDark() { matrix(brand: "graphite", mode: "dark") }

    func testExplicitThemeReachesStrataPickerWhileCallerEnvironmentRemainsOpposing() {
        for mode in ["light", "dark"] {
            let opposing = mode == "light" ? "dark" : "light"
            let app = launch(scenario: "theme-boundary", brand: "graphite", mode: mode, hostMode: opposing)
            let first = option("boundary-first", app: app)
            let second = option("boundary-second", app: app)
            XCTAssertEqual(app.staticTexts["caller-scheme"].label, "Caller scheme: \(opposing)")
            XCTAssertEqual(app.staticTexts["picker-label-scheme"].label, "Picker label scheme: \(mode)")
            XCTAssertEqual(first.label, "First option scheme: \(mode)")
            XCTAssertEqual(second.label, "Second option scheme: \(mode)")
            assertLayout([first, second], app: app)
            assertSelection(second, others: [first])
            first.tap()
            XCTAssertEqual(app.staticTexts["selection-state"].label, "Selected: compact-id")
            assertSelection(first, others: [second])
            capture("radio-group-explicit-\(mode)-opposing-\(opposing)", app: app)

            app.buttons["toggle-disabled"].tap()
            XCTAssertFalse(first.isEnabled)
            XCTAssertFalse(second.isEnabled)
            second.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            XCTAssertEqual(app.staticTexts["selection-state"].label, "Selected: compact-id")
            assertSelection(first, others: [second])
            XCTAssertEqual(first.label, "First option scheme: \(mode)")
            XCTAssertEqual(second.label, "Second option scheme: \(mode)")
            XCTAssertEqual(app.staticTexts["caller-scheme"].label, "Caller scheme: \(opposing)")
            app.terminate()
        }
    }

    func testLongLabelsGrowWithoutClippingAtAccessibilitySizeInNarrowLayout() {
        var app = launch(scenario: "long-label")
        let standard = option("long-first", app: app).frame
        app.terminate()
        app = launch(scenario: "long-label", size: "accessibility2")
        let first = option("long-first", app: app)
        let second = option("long-second", app: app)
        XCTAssertGreaterThan(first.frame.height, standard.height + 20)
        XCTAssertEqual(first.label, "Show the complete description of every synthetic review option")
        XCTAssertEqual(second.label, "Keep all detailed review notes visible")
        assertLayout([first, second], app: app)
        XCTAssertLessThanOrEqual(first.frame.maxY, second.frame.minY + 0.001)
        XCTAssertLessThanOrEqual(first.frame.width, 320.001)
        XCTAssertLessThanOrEqual(second.frame.width, 320.001)
        assertSelection(second, others: [first])
        capture("radio-group-accessibility-narrow", app: app)
        first.tap()
        XCTAssertEqual(app.staticTexts["selection-state"].label, "Selected: compact-id")
        assertSelection(first, others: [second])
        print("Long inline rows: standard=\(standard) accessibility=\(first.frame)")
    }

    func testInvalidBrandShowsOriginalFailureWithoutControl() {
        let app = launch(scenario: "matrix", brand: "__unknown_brand__", expectsError: true)
        XCTAssertTrue(app.staticTexts["fixture-error"].label.contains("__unknown_brand__"))
        XCTAssertFalse(app.buttons["option-compact-id"].exists)
    }

    private func matrix(brand: String, mode: String) {
        let app = launch(scenario: "matrix", brand: brand, mode: mode)
        let enabled = ["option-compact-id", "option-balanced-id", "option-detail-id"].map { option($0, app: app) }
        let disabled = ["disabled-summary", "disabled-detail"].map { option($0, app: app) }
        assertLayout(enabled + disabled, app: app)
        enabled.forEach { XCTAssertTrue($0.isEnabled) }
        disabled.forEach { XCTAssertFalse($0.isEnabled) }
        assertSelection(enabled[1], others: [enabled[0], enabled[2]])
        assertSelection(disabled[1], others: [disabled[0]])
        XCTAssertTrue(app.frame.contains(app.staticTexts["review-end"].frame))
        let name = "radio-group-\(brand)-\(mode)"
        func coordinates(_ frame: CGRect) -> String {
            "[\(frame.minX),\(frame.minY),\(frame.width),\(frame.height)]"
        }
        // Pixel review uses this capture's real app/row frames, not screen guesses.
        print("RADIO_GROUP_CHECKMARK {\"name\":\"\(name)\",\"app\":\(coordinates(app.frame)),\"selected\":\(coordinates(enabled[1].frame)),\"unselected\":\(coordinates(enabled[0].frame))}")
        capture(name, app: app)
    }

    private func option(_ identifier: String, app: XCUIApplication) -> XCUIElement {
        let element = app.buttons[identifier]
        XCTAssertTrue(element.exists, "Strata inline option must be accessible as a button.\n\(app.debugDescription)")
        return element
    }

    private func assertSelection(_ selected: XCUIElement, others: [XCUIElement]) {
        XCTAssertTrue(selected.isSelected, "Strata selected trait must expose the selection: \(selected.debugDescription)")
        others.forEach { XCTAssertFalse($0.isSelected) }
    }

    private func assertSameFrame(_ actual: CGRect, _ expected: CGRect) {
        XCTAssertEqual(actual.minX, expected.minX, accuracy: 0.001)
        XCTAssertEqual(actual.minY, expected.minY, accuracy: 0.001)
        XCTAssertEqual(actual.width, expected.width, accuracy: 0.001)
        XCTAssertEqual(actual.height, expected.height, accuracy: 0.001)
    }

    private func assertLayout(_ elements: [XCUIElement], app: XCUIApplication) {
        let viewport = app.descendants(matching: .any).matching(identifier: "review-list").firstMatch.frame
        for element in elements {
            // Round only subpixel arithmetic noise; the target remains >=44 pt.
            XCTAssertGreaterThanOrEqual((element.frame.width * 1000).rounded() / 1000, 44)
            XCTAssertGreaterThanOrEqual((element.frame.height * 1000).rounded() / 1000, 44)
            XCTAssertTrue(viewport.contains(element.frame), "Every row must be fully visible before capture: \(element.frame)")
            XCTAssertTrue(element.isHittable)
        }
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func launch(scenario: String, brand: String = "ocean", mode: String = "light",
                        size: String = "large", hostMode: String? = nil,
                        expectsError: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment = ["NDK_SCENARIO": scenario, "NDK_BRAND": brand,
                                 "NDK_THEME": mode, "NDK_TEXT_SIZE": size,
                                 "NDK_HOST_THEME": hostMode ?? mode]
        app.launch()
        let ready = expectsError ? app.staticTexts["fixture-error"] : app.descendants(matching: .any).matching(identifier: "review-list").firstMatch
        XCTAssertTrue(ready.waitForExistence(timeout: 10), app.debugDescription)
        return app
    }
}
