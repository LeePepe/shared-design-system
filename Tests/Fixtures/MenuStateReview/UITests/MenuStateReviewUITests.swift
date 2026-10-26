import XCTest

@MainActor
final class MenuStateReviewUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testThemeMatrixUsesOneLaunchAndCapturesFourScreens() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Menu and state components"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["More actions"].exists)
        XCTAssertTrue(app.buttons["segmented-horizontal-all"].exists)
        XCTAssertTrue(app.buttons["segmented-horizontal-chest"].exists)
        XCTAssertTrue(app.buttons["segmented-horizontal-legs"].exists)
        XCTAssertTrue(app.buttons["segmented-vertical-all"].exists)
        XCTAssertTrue(app.buttons["segmented-vertical-chest"].exists)
        XCTAssertTrue(app.buttons["segmented-vertical-legs"].exists)
        XCTAssertTrue(app.otherElements["empty-state"].exists)
        XCTAssertTrue(app.otherElements["loading-state"].exists)
        XCTAssertTrue(app.staticTexts["Could not load history"].exists)

        app.buttons["More actions"].tap()
        XCTAssertTrue(app.buttons["Copy set"].waitForExistence(timeout: 2))
        app.buttons["Copy set"].tap()
        XCTAssertEqual(app.staticTexts["menu-result"].label, "Menu result: Copied")
        let legs = app.buttons["segmented-horizontal-legs"]
        legs.tap()
        XCTAssertTrue(legs.isSelected)
        app.buttons["Retry"].tap()
        XCTAssertEqual(app.staticTexts["state-result"].label, "State: retried")
        app.buttons["theme-blue-light"].tap()
        XCTAssertEqual(app.staticTexts["theme-status"].label, "Theme: strata-blue · light")

        capture("menu-state-blue-light", app: app)
        app.buttons["theme-blue-dark"].tap()
        capture("menu-state-blue-dark", app: app)
        app.buttons["theme-purple-light"].tap()
        capture("menu-state-purple-light", app: app)
        app.buttons["theme-purple-dark"].tap()
        capture("menu-state-purple-dark", app: app)
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
