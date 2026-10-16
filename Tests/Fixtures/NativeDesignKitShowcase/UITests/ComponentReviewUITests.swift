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
            capture(app, "review-\(page)-large-lower")
            app.terminate()
        }
    }
}
