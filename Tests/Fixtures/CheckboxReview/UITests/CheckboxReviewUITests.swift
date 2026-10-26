import XCTest

@MainActor
final class CheckboxReviewUITests: XCTestCase {
    override func setUpWithError() throws { continueAfterFailure = false }

    func testStrataBindingAndCallerUpdatesPreserveFootprint() {
        let app = launch()
        let target = app.switches["checkbox.primary"]
        let initialFrame = target.frame
        assertState(app, on: false, writes: 0)
        assertTarget(target, app: app)
        // Both the square and the far label edge belong to the same native action.
        target.coordinate(withNormalizedOffset: CGVector(dx: 0.03, dy: 0.5)).tap()
        assertState(app, on: true, writes: 1)
        XCTAssertEqual(target.frame.width, initialFrame.width, accuracy: 0.001)
        XCTAssertEqual(target.frame.height, initialFrame.height, accuracy: 0.001)
        target.coordinate(withNormalizedOffset: CGVector(dx: 0.96, dy: 0.5)).tap()
        assertState(app, on: false, writes: 2)
        app.buttons["checkbox.caller"].tap()
        assertState(app, on: true, writes: 2)
        target.tap()
        assertState(app, on: false, writes: 3)
    }

    func testDisabledCoordinateTapsCannotChangeEitherCheckedState() {
        for on in [false, true] {
            let app = launch(brand: "graphite", mode: "dark", disabled: true, initiallyOn: on)
            let target = app.switches["checkbox.primary"]
            XCTAssertFalse(target.isEnabled)
            assertTarget(target, app: app)
            for offset in [0.03, 0.5, 0.96] {
                target.coordinate(withNormalizedOffset: CGVector(dx: offset, dy: 0.5)).tap()
                assertState(app, on: on, writes: 0)
            }
            app.terminate()
        }
    }

    func testStrataAccessibilityExposesCompleteLabelAndCheckedValue() {
        let app = launch()
        let target = app.switches["checkbox.primary"]
        XCTAssertEqual(target.elementType, .switch)
        XCTAssertEqual(target.label, "Include attachments")
        XCTAssertTrue(target.isEnabled)
        XCTAssertTrue(target.isHittable)
        assertState(app, on: false, writes: 0)
        target.tap()
        assertState(app, on: true, writes: 1)
        XCTAssertEqual(target.label, "Include attachments")
        XCTAssertTrue(target.isHittable)
    }

    func testNarrowLongLabelGrowsAtAccessibilitySizeAndRemainsOperable() {
        let standardApp = launch(narrow: true)
        let standardFrame = standardApp.switches["checkbox.primary"].frame
        assertTarget(standardApp.switches["checkbox.primary"], app: standardApp)
        standardApp.terminate()
        for brand in ["ocean", "graphite"] {
            for mode in ["light", "dark"] {
                let app = launch(brand: brand, mode: mode, narrow: true, accessibility: true)
                let target = app.switches["checkbox.primary"]
                assertTarget(target, app: app)
                XCTAssertLessThanOrEqual(target.frame.width, 272.001)
                XCTAssertGreaterThan(target.frame.height, standardFrame.height + 30)
                XCTAssertEqual(target.label, "Auswahl und Benachrichtigungen für wichtige Änderungen bestätigen")
                XCTAssertTrue(app.scrollViews["checkbox.scroll"].frame.contains(app.staticTexts["checkbox.writes"].frame))
                let offFrame = target.frame
                target.coordinate(withNormalizedOffset: CGVector(dx: 0.96, dy: 0.5)).tap()
                assertState(app, on: true, writes: 1)
                XCTAssertEqual(target.frame.width, offFrame.width, accuracy: 0.001)
                XCTAssertEqual(target.frame.height, offFrame.height, accuracy: 0.001)
                capture("checkbox-\(brand)-\(mode)-narrow-accessibility2", app: app)
                print("Checkbox text growth: standard=\(standardFrame), accessibility2=\(target.frame)")
                app.terminate()
            }
        }
    }

    func testVisualMatrixOceanLight() { matrix(brand: "ocean", mode: "light") }
    func testVisualMatrixOceanDark() { matrix(brand: "ocean", mode: "dark") }
    func testVisualMatrixGraphiteLight() { matrix(brand: "graphite", mode: "light") }
    func testVisualMatrixGraphiteDark() { matrix(brand: "graphite", mode: "dark") }

    func testInvalidBrandDisplaysErrorWithoutFallbackControl() {
        let app = launch(brand: "__unsupported_brand__", expectsError: true)
        XCTAssertTrue(app.staticTexts["checkbox.error"].label.contains("__unsupported_brand__"))
        XCTAssertFalse(app.switches["checkbox.primary"].exists)
    }

    private func matrix(brand: String, mode: String) {
        let app = launch(brand: brand, mode: mode)
        for id in ["primary", "selected", "disabledOff", "disabledOn"] {
            let target = app.switches["checkbox.\(id)"]
            XCTAssertTrue(target.exists)
            XCTAssertEqual(target.isEnabled, !id.hasPrefix("disabled"))
            XCTAssertEqual(target.value as? String, ["selected", "disabledOn"].contains(id) ? "1" : "0")
            assertTarget(target, app: app)
        }
        XCTAssertTrue(app.scrollViews["checkbox.scroll"].frame.contains(app.staticTexts["checkbox.footer"].frame))
        capture("checkbox-\(brand)-\(mode)", app: app)
    }

    private func launch(brand: String = "ocean", mode: String = "light", narrow: Bool = false,
                        accessibility: Bool = false, disabled: Bool = false, initiallyOn: Bool = false,
                        expectsError: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment = [
            "NDK_BRAND": brand, "NDK_THEME": mode,
            "NDK_SCENARIO": narrow ? "narrow" : "matrix",
            "NDK_TEXT_SIZE": accessibility ? "accessibility2" : "large",
            "NDK_DISABLED": disabled ? "1" : "0", "NDK_INITIAL_ON": initiallyOn ? "1" : "0"
        ]
        app.launch()
        XCTAssertTrue(app.descendants(matching: .any)[expectsError ? "checkbox.error" : "checkbox.primary"].firstMatch.waitForExistence(timeout: 5))
        return app
    }

    private func assertState(_ app: XCUIApplication, on: Bool, writes: Int,
                             file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(app.switches["checkbox.primary"].value as? String, on ? "1" : "0", file: file, line: line)
        XCTAssertEqual(app.staticTexts["checkbox.state"].label, on ? "Checked" : "Unchecked", file: file, line: line)
        XCTAssertEqual(app.staticTexts["checkbox.writes"].label, "Binding writes: \(writes)", file: file, line: line)
    }

    private func assertTarget(_ target: XCUIElement, app: XCUIApplication,
                              file: StaticString = #filePath, line: UInt = #line) {
        // AX edge conversion can report 43.999969 for a 44 pt SwiftUI frame.
        // Round only subpixel arithmetic noise to 1/1000 pt; the minimum stays 44.
        XCTAssertGreaterThanOrEqual((target.frame.width * 1000).rounded() / 1000, 44, file: file, line: line)
        XCTAssertGreaterThanOrEqual((target.frame.height * 1000).rounded() / 1000, 44, file: file, line: line)
        XCTAssertTrue(app.scrollViews["checkbox.scroll"].frame.contains(target.frame), file: file, line: line)
        XCTAssertTrue(app.frame.contains(target.frame), file: file, line: line)
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
