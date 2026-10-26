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
        let horizontalSegments = app.buttons.matching(identifier: "horizontal-segmented-bar")
        XCTAssertEqual(horizontalSegments.count, 3)
        XCTAssertTrue(app.staticTexts["Could not load history"].exists)

        app.buttons["More actions"].tap()
        XCTAssertTrue(app.buttons["Copy set"].waitForExistence(timeout: 2))
        app.buttons["Copy set"].tap()
        XCTAssertEqual(app.staticTexts["menu-result"].label, "Menu result: Copied")
        let legs = horizontalSegments.element(boundBy: 2)
        legs.tap()
        XCTAssertTrue(legs.isSelected)

        capture("menu-state-blue-light", app: app)
        app.buttons["theme-strata-blue-dark"].tap()
        capture("menu-state-blue-dark", app: app)
        app.buttons["theme-strata-purple-light"].tap()
        capture("menu-state-purple-light", app: app)
        app.buttons["theme-strata-purple-dark"].tap()
        capture("menu-state-purple-dark", app: app)
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
