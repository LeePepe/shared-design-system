import XCTest

@MainActor
final class ShowcaseUITests: XCTestCase {
    private func launch(page: String, appearance: String = "light", width: String = "wide",
                        accessibility: Bool = false, rtl: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment = ["FIXTURE_PAGE": page, "FIXTURE_APPEARANCE": appearance,
            "FIXTURE_WIDTH": width, "FIXTURE_ACCESSIBILITY": accessibility ? "1" : "0",
            "FIXTURE_RTL": rtl ? "1" : "0", "TZ": "UTC"]
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        XCTAssertFalse(app.staticTexts["fixture-error"].exists, "Provider artifact must be prepared")
        XCTAssertTrue(app.staticTexts["NATIVE DESIGN KIT"].waitForExistence(timeout: 10))
        return app
    }

    private func activate(_ element: XCUIElement) {
        #if os(macOS)
        element.click()
        #else
        element.tap()
        #endif
    }

    private func scrollDown(_ app: XCUIApplication) {
        #if os(macOS)
        app.scrollViews["catalog"].scroll(byDeltaX: 0, deltaY: -500)
        #else
        app.scrollViews["catalog"].swipeUp()
        #endif
    }

    private func reveal(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<6 {
            if element.isHittable { return }
            let viewport = app.scrollViews["catalog"]
            if element.exists && element.frame.midY < viewport.frame.midY {
                #if os(macOS)
                viewport.scroll(byDeltaX: 0, deltaY: 400)
                #else
                viewport.swipeDown()
                #endif
            } else {
                scrollDown(app)
            }
        }
        XCTAssertTrue(element.isHittable, "Could not reveal \(element)")
    }

    private func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    func testButtonsCheckboxAndSelection() {
        let app = launch(page: "Buttons")
        activate(app.buttons["run-action"])
        XCTAssertTrue(app.staticTexts["Actions: 1"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.buttons["loading-action"].isEnabled)
        XCTAssertFalse(app.buttons["disabled-action"].isEnabled)
        #if os(macOS)
        let checkbox = app.checkBoxes["include-details"]
        #else
        let checkbox = app.descendants(matching: .any).matching(identifier: "include-details").firstMatch
        #endif
        reveal(checkbox, in: app)
        activate(checkbox)
        XCTAssertTrue(app.staticTexts["Details included"].waitForExistence(timeout: 3))
        #if os(macOS)
        let second = app.radioButtons["Second"]
        #else
        let second = app.buttons["Second"]
        #endif
        reveal(second, in: app)
        activate(second)
        XCTAssertTrue(app.staticTexts["Selection: Second"].waitForExistence(timeout: 3))
        capture(app, "interaction-selection")
    }

    func testTextSearchAndSecureEditing() {
        let app = launch(page: "Entry")
        let field = app.textFields["display-name"]
        reveal(field, in: app); activate(field); field.typeText("Sample\n")
        XCTAssertTrue(app.staticTexts["Name: Sample"].waitForExistence(timeout: 3))
        let secure = app.secureTextFields["private-phrase"]
        reveal(secure, in: app); activate(secure); secure.typeText("private\n")
        XCTAssertFalse(app.staticTexts["private"].exists)
        let search = app.textFields["Search catalog"]
        reveal(search, in: app); activate(search); search.typeText("query")
        let clear = app.buttons["Clear search"]
        XCTAssertTrue(clear.waitForExistence(timeout: 3)); activate(clear)
        XCTAssertEqual(search.value as? String, "Search catalog")
        capture(app, "interaction-text-entry")
    }

    func testValuesRemovalAndReducedMotionEndState() {
        let app = launch(page: "Values", accessibility: true)
        let slider = app.sliders["level-slider"]
        reveal(slider, in: app)
        #if os(iOS)
        slider.adjust(toNormalizedSliderPosition: 0.8)
        XCTAssertFalse(app.staticTexts["Level: 40"].exists)
        #endif
        let ring = app.descendants(matching: .any).matching(identifier: "ring-progress").firstMatch
        reveal(ring, in: app)
        XCTAssertTrue((ring.value as? String)?.contains("percent") == true)
        let stepper = app.steppers["count-stepper"]
        reveal(stepper, in: app)
        #if os(iOS)
        activate(stepper.buttons["Increment"])
        XCTAssertTrue(app.staticTexts["Count value: 3"].waitForExistence(timeout: 3))
        #endif
        let animate = app.buttons["animate-number"]
        reveal(animate, in: app); activate(animate)
        let number = app.descendants(matching: .any).matching(identifier: "animated-number").firstMatch
        XCTAssertEqual(number.value as? String, "256")
        let remove = app.buttons["Remove sample tag"]
        reveal(remove, in: app); activate(remove)
        XCTAssertFalse(app.buttons["Remove sample tag"].exists)
        capture(app, "interaction-values-reduced-motion")
        app.terminate()
        let motion = launch(page: "Motion", accessibility: true)
        activate(motion.buttons["replay-sequence"])
        XCTAssertTrue(motion.staticTexts["Visible steps: 3"].waitForExistence(timeout: 3))
        capture(motion, "reduced-motion-complete")
    }

    func testScreenshotMatrix() {
        #if os(macOS)
        let widths = ["wide", "narrow"]
        #else
        let widths = ["device"]
        #endif
        for width in widths {
            for appearance in ["light", "dark"] {
                for page in ["Buttons", "Entry", "Values", "Motion"] {
                    let app = launch(page: page, appearance: appearance, width: width)
                    capture(app, "\(width)-\(appearance)-\(page)-top")
                    scrollDown(app)
                    capture(app, "\(width)-\(appearance)-\(page)-lower")
                    app.terminate()
                }
            }
        }
        for appearance in ["light", "dark"] {
            let app = launch(page: "Motion", appearance: appearance, width: "narrow", accessibility: true)
            let replay = app.buttons["replay-sequence"]
            reveal(replay, in: app); activate(replay)
            XCTAssertTrue(app.staticTexts["Visible steps: 3"].waitForExistence(timeout: 3))
            capture(app, "accessibility-\(appearance)-motion-top")
            scrollDown(app)
            capture(app, "accessibility-\(appearance)-motion-lower")
            app.terminate()
        }
        let rtl = launch(page: "Values", appearance: "dark", width: "narrow", rtl: true)
        capture(rtl, "rtl-dark-values")
    }
}
