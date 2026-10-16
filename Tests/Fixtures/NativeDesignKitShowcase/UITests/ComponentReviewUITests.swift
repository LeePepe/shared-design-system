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
        let copy = app.buttons["review-start-loading"]
        reveal(copy, in: app)
        let idleFrame = copy.frame
        activate(copy)
        XCTAssertFalse(copy.isEnabled)
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
            capture(app, "review-\(page)-large-lower")
            app.terminate()
        }
    }
}
