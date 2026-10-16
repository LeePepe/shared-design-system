import XCTest

@MainActor
final class ComponentReviewUITests: XCTestCase {
    func launch(_ page: String, dark: Bool = false, large: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment = ["FIXTURE_PAGE": page, "FIXTURE_APPEARANCE": dark ? "dark" : "light",
            "FIXTURE_WIDTH": "narrow", "FIXTURE_ACCESSIBILITY": large ? "1" : "0", "TZ": "UTC"]
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        XCTAssertTrue(app.staticTexts[page].firstMatch.waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["fixture-error"].exists)
        return app
    }

    func capture(_ app: XCUIApplication, _ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name; attachment.lifetime = .keepAlways; add(attachment)
    }

    func activate(_ element: XCUIElement) {
        #if os(macOS)
        element.click()
        #else
        element.tap()
        #endif
    }

    func reveal(_ element: XCUIElement, in app: XCUIApplication) {
        let viewport = app.scrollViews["component-review"]
        for _ in 0..<8 {
            if element.isHittable { return }
            #if os(macOS)
            viewport.scroll(byDeltaX: 0, deltaY: -350)
            #else
            viewport.swipeUp()
            #endif
        }
        XCTAssertTrue(element.isHittable)
    }

    func testButtonInteraction() {
        let app = launch("Button")
        let save = app.buttons["review-save"]
        #if os(iOS)
        save.press(forDuration: 0.5)
        #else
        save.click()
        #endif
        XCTAssertEqual(app.staticTexts["review-count"].label, "Actions: 1")
        XCTAssertFalse(app.buttons["review-disabled"].isEnabled)
        XCTAssertFalse(app.buttons["review-loading"].isEnabled)
        #if os(iOS)
        app.buttons["review-disabled"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        XCTAssertEqual(app.staticTexts["review-count"].label, "Actions: 1")
        #endif
        let copy = app.buttons["review-start-loading"]
        reveal(copy, in: app)
        let idleFrame = copy.frame
        activate(copy)
        XCTAssertFalse(copy.isEnabled)
        #if os(iOS)
        copy.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        #endif
        XCTAssertEqual(copy.frame.size.width, idleFrame.size.width, accuracy: 0.5)
        XCTAssertEqual(copy.frame.size.height, idleFrame.size.height, accuracy: 0.5)
        capture(app, "interaction-Button-loading")
        XCTAssertEqual(app.staticTexts["review-count"].label, "Actions: 2")
        XCTAssertTrue(app.staticTexts["Copy saved"].waitForExistence(timeout: 6))
        XCTAssertEqual(app.staticTexts["review-count"].label, "Actions: 2")
        XCTAssertEqual(copy.frame.size.width, idleFrame.size.width, accuracy: 0.5)
        XCTAssertEqual(copy.frame.size.height, idleFrame.size.height, accuracy: 0.5)
        capture(app, "interaction-Button-saved")
        let cancel = app.buttons["review-cancel"]
        reveal(cancel, in: app); activate(cancel)
        XCTAssertEqual(app.staticTexts["review-result"].label, "Changes cancelled")
        let delete = app.buttons["review-delete"]
        reveal(delete, in: app); activate(delete)
        XCTAssertEqual(app.staticTexts["review-result"].label, "Sample copy deleted")
        let glass = app.buttons["review-glass"]
        reveal(glass, in: app)
        capture(app, "interaction-Button-floating")
    }

    func testToggleInteraction() {
        let app = launch("Toggle")
        let on = app.switches["review-toggle-on"]
        XCTAssertTrue(on.waitForExistence(timeout: 5))
        XCTAssertEqual(on.value as? String, "1")
        activate(on)
        XCTAssertEqual(on.value as? String, "0")
        let off = app.switches["review-toggle-off"]
        XCTAssertEqual(off.value as? String, "0")
        activate(off)
        XCTAssertEqual(off.value as? String, "1")
        for id in ["review-toggle-disabled-on", "review-toggle-disabled-off"] {
            let disabled = app.switches[id]
            reveal(disabled, in: app)
            XCTAssertFalse(disabled.isEnabled)
            let value = disabled.value as? String
            #if os(iOS)
            disabled.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            #endif
            XCTAssertEqual(disabled.value as? String, value)
        }
        let context = app.switches["review-toggle-context"]
        reveal(context, in: app)
        XCTAssertEqual(app.staticTexts["review-toggle-result"].label, "Details excluded")
        activate(context)
        XCTAssertEqual(context.value as? String, "1")
        XCTAssertEqual(app.staticTexts["review-toggle-result"].label, "Details included")
        capture(app, "interaction-Toggle-on")
        activate(context)
        XCTAssertEqual(context.value as? String, "0")
        XCTAssertEqual(app.staticTexts["review-toggle-result"].label, "Details excluded")
        capture(app, "interaction-Toggle-off")
    }

    func testTextFieldInteraction() {
        let app = launch("TextField")
        XCTAssertFalse(app.textFields["review-field-disabled"].isEnabled)
        let context = app.textFields["review-field-context"]
        reveal(context, in: app)
        #if os(iOS)
        // Hit within the caller's 44-point target, near its lower edge, including
        // the padding outside a smaller native bezel. Center taps cannot prove this.
        context.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            .withOffset(CGVector(dx: 0, dy: 21)).tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        #else
        activate(context)
        #endif
        capture(app, "interaction-TextField-focused")
        let statusOffset = app.staticTexts["review-field-result"].frame.minY - context.frame.maxY
        context.typeText("\n")
        XCTAssertTrue(app.staticTexts["review-field-context-error"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.staticTexts["review-field-result"].label, "Not submitted")
        XCTAssertEqual(app.staticTexts["review-field-result"].frame.minY - context.frame.maxY,
                       statusOffset, accuracy: 1,
                       "The actual helper/error messages must reserve stable space")
        let error = app.staticTexts["review-field-context-error"]
        XCTAssertTrue(error.isHittable, "Validation must be visible while editing")
        #if os(iOS)
        XCTAssertLessThan(error.frame.maxY, app.keyboards.firstMatch.frame.minY,
                          "The keyboard must not cover the cause and correction")
        #endif
        capture(app, "interaction-TextField-error")
        context.typeText("Draft")
        XCTAssertEqual(context.value as? String, "Draft")
        capture(app, "interaction-TextField-filled")
        context.typeText("\n")
        XCTAssertTrue(app.staticTexts["Submitted: Draft"].waitForExistence(timeout: 5))
        capture(app, "interaction-TextField-submitted")
    }

    func testComponentBoards() {
        for page in ["Button", "Toggle", "TextField"] {
            for dark in [false, true] {
                let app = launch(page, dark: dark)
                capture(app, "review-\(page)-\(dark ? "dark" : "light")-top")
                #if os(iOS)
                app.scrollViews["component-review"].swipeUp()
                #else
                app.scrollViews["component-review"].scroll(byDeltaX: 0, deltaY: -500)
                #endif
                capture(app, "review-\(page)-\(dark ? "dark" : "light")-lower")
                app.terminate()
            }
        }
    }

    func testLargeTypeBoards() {
        for page in ["Button", "Toggle", "TextField"] {
            let app = launch(page, dark: true, large: true)
            capture(app, "review-\(page)-large-top")
            #if os(iOS)
            app.scrollViews["component-review"].swipeUp()
            #else
            app.scrollViews["component-review"].scroll(byDeltaX: 0, deltaY: -500)
            #endif
            if page == "Button" { reveal(app.buttons["review-localized"], in: app) }
            if page == "Toggle" { reveal(app.switches["review-toggle-long"], in: app) }
            if page == "TextField" { reveal(app.textFields["review-field-long"], in: app) }
            capture(app, "review-\(page)-large-lower")
            app.terminate()
        }
    }
}
