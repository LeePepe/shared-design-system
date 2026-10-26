import XCTest

final class SwitchReviewUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testInvalidConfigurationShowsErrorWithoutFallbackSwitch() {
        let app = XCUIApplication()
        app.launchEnvironment = ["NDK_SWITCH_BRAND": "unsupported", "NDK_SWITCH_MODE": "light"]
        app.launch()
        XCTAssertTrue(app.staticTexts["switch.configurationError"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.switches["switch.primary"].exists)
    }

    @MainActor
    func testStrataTapWritesBindingAndCallerUpdateChangesSwitch() {
        let app = launch()
        let control = app.switches["switch.primary"]
        assertState(app, control: control, on: false, writes: 0)

        control.tap()
        assertState(app, control: control, on: true, writes: 1)

        app.buttons["switch.callerUpdate"].tap()
        assertState(app, control: control, on: false, writes: 1)

        control.tap()
        assertState(app, control: control, on: true, writes: 2)
    }

    @MainActor
    func testDisabledCoordinateTapDoesNotWriteBindingInEitherState() {
        for initiallyOn in [false, true] {
            let app = launch(brand: "graphite", mode: "dark", disabled: true, initiallyOn: initiallyOn)
            let control = app.switches["switch.primary"]
            XCTAssertFalse(control.isEnabled)
            assertState(app, control: control, on: initiallyOn, writes: 0)
            for _ in 0..<3 {
                control.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5)).tap()
                assertState(app, control: control, on: initiallyOn, writes: 0)
            }
            app.terminate()
        }
    }

    @MainActor
    func testMeaningfulStrataAccessibilityLabelAndOnOffValue() {
        let app = launch(mode: "dark")
        let control = app.switches["switch.primary"]
        XCTAssertEqual(control.elementType, .switch)
        XCTAssertEqual(control.label, "Allow notifications")
        XCTAssertTrue(control.isEnabled)
        assertState(app, control: control, on: false, writes: 0)
        control.tap()
        assertState(app, control: control, on: true, writes: 1)
        XCTAssertEqual(control.label, "Allow notifications")
    }

    @MainActor
    func testStrataSwitchRemainsAnActionableAccessibilityTarget() {
        let app = launch(brand: "graphite")
        let control = app.switches["switch.primary"]
        XCTAssertTrue(control.isHittable)
        control.tap()
        assertState(app, control: control, on: true, writes: 1)
        XCTAssertTrue(control.isHittable)
        control.tap()
        assertState(app, control: control, on: false, writes: 2)
    }

    @MainActor
    func testNarrowLongLabelGrowsAtAccessibilitySizeAndRemainsOperable() {
        let standardApp = launch(narrow: true)
        let standard = standardApp.switches["switch.primary"]
        let standardFrame = standard.frame
        assertFullyVisible(standard, in: standardApp)
        assertFixtureEndVisible(in: standardApp, narrow: true)
        XCTAssertLessThanOrEqual(standardFrame.width, 281)
        standardApp.terminate()

        let app = launch(narrow: true, accessibility: true)
        let control = app.switches["switch.primary"]
        assertFullyVisible(control, in: app)
        assertFixtureEndVisible(in: app, narrow: true)
        XCTAssertGreaterThan(control.frame.height, standardFrame.height + 30)
        XCTAssertLessThanOrEqual(control.frame.width, 281)
        XCTAssertEqual(control.label, "Allow notifications about important updates and changes to your preferences")
        XCTAssertTrue(control.isHittable)
        control.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5)).tap()
        assertState(app, control: control, on: true, writes: 1)
        print("Switch UI layout: standard=\(standardFrame), accessibility3=\(control.frame)")
    }

    @MainActor
    func testStrataSwitchScreenshotMatrix() {
        for brand in ["ocean", "graphite"] {
            for mode in ["light", "dark"] {
                let app = launch(brand: brand, mode: mode)
                XCTAssertEqual(app.switches["switch.selected"].value as? String, "1")
                XCTAssertFalse(app.switches["switch.disabledOff"].isEnabled)
                XCTAssertFalse(app.switches["switch.disabledOn"].isEnabled)
                for identifier in ["switch.primary", "switch.selected", "switch.disabledOff", "switch.disabledOn"] {
                    assertFullyVisible(app.switches[identifier], in: app)
                }
                assertFixtureEndVisible(in: app, narrow: false)
                attach("switch-\(brand)-\(mode)", app: app)
                app.terminate()

                let narrowApp = launch(brand: brand, mode: mode, narrow: true, accessibility: true)
                let control = narrowApp.switches["switch.primary"]
                assertFullyVisible(control, in: narrowApp)
                assertFixtureEndVisible(in: narrowApp, narrow: true)
                XCTAssertTrue(control.isHittable)
                XCTAssertGreaterThan(control.frame.height, 100)
                attach("switch-\(brand)-\(mode)-narrow-accessibility3", app: narrowApp)
                narrowApp.terminate()
            }
        }
    }

    @MainActor
    private func launch(
        brand: String = "ocean", mode: String = "light", narrow: Bool = false,
        accessibility: Bool = false, disabled: Bool = false, initiallyOn: Bool = false
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment = [
            "NDK_SWITCH_BRAND": brand, "NDK_SWITCH_MODE": mode,
            "NDK_SWITCH_NARROW": narrow ? "1" : "0",
            "NDK_SWITCH_ACCESSIBILITY": accessibility ? "1" : "0",
            "NDK_SWITCH_DISABLED": disabled ? "1" : "0",
            "NDK_SWITCH_INITIAL_ON": initiallyOn ? "1" : "0"
        ]
        app.launch()
        XCTAssertTrue(app.switches["switch.primary"].waitForExistence(timeout: 5))
        return app
    }

    @MainActor
    private func assertState(_ app: XCUIApplication, control: XCUIElement, on: Bool, writes: Int,
                             file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(control.value as? String, on ? "1" : "0", file: file, line: line)
        XCTAssertEqual(app.staticTexts["switch.state"].label, on ? "On" : "Off", file: file, line: line)
        XCTAssertEqual(app.staticTexts["switch.writes"].label, "Binding writes: \(writes)", file: file, line: line)
    }

    @MainActor
    private func assertFixtureEndVisible(in app: XCUIApplication, narrow: Bool,
                                         file: StaticString = #filePath, line: UInt = #line) {
        let end = app.staticTexts[narrow ? "switch.writes" : "switch.footer"]
        XCTAssertTrue(end.exists, file: file, line: line)
        XCTAssertTrue(app.scrollViews.firstMatch.frame.contains(end.frame),
                      "Fixture content must fit its visible scroll viewport before capture", file: file, line: line)
    }

    @MainActor
    private func assertFullyVisible(_ control: XCUIElement, in app: XCUIApplication,
                                    file: StaticString = #filePath, line: UInt = #line) {
        // Subtracting AX frame coordinates can report 44 as 43.99999999999994.
        // A millionth of a point tolerates that arithmetic noise, not a smaller target.
        let minimum = 44.0 - 0.000_001
        XCTAssertGreaterThanOrEqual(control.frame.width, minimum, file: file, line: line)
        XCTAssertGreaterThanOrEqual(control.frame.height, minimum, file: file, line: line)
        XCTAssertTrue(app.frame.contains(control.frame), "Complete switch row must be onscreen", file: file, line: line)
    }

    @MainActor
    private func attach(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
