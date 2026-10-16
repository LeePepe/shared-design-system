import XCTest

/// Real pointer/keyboard events run on macOS or iPad; iPhone rejects pointer events.
@MainActor
final class ButtonPointerReviewUITests: XCTestCase {
    func testPointerHoverForEveryVariant() {
        let app = launch(scenario: "specimen")
        for id in ["save", "secondary", "ghost"] {
            let button = app.buttons["specimen-\(id)"]
            XCTAssertTrue(button.isEnabled)
            button.hover()
            capture("button-macos-hover-\(id)", app: app)
        }
    }

    func testCallerKeyboardShortcutHonorsDisabledAndLoading() {
        let app = launch(scenario: "interaction")
        app.typeKey("s", modifierFlags: .command)
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 1")
        app.typeKey(.tab, modifierFlags: [])
        capture("button-macos-keyboard-navigation", app: app)
        app.buttons["toggle-disabled"].click()
        app.typeKey("s", modifierFlags: .command)
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 1")
        app.buttons["toggle-disabled"].click()
        app.buttons["toggle-loading"].click()
        app.typeKey("s", modifierFlags: .command)
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 1")
        app.buttons["toggle-loading"].click()
        app.typeKey("s", modifierFlags: .command)
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 2")
    }

    private func launch(scenario: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment = ["NDK_SCENARIO": scenario, "NDK_BRAND": "strata-blue", "NDK_THEME": "light",
                                 "NDK_TEXT_SIZE": "large", "NDK_LANGUAGE": "en", "NDK_SURFACE": "glass"]
        app.launch()
        XCTAssertTrue(app.scrollViews["review-scroll"].waitForExistence(timeout: 10), app.debugDescription)
        return app
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
