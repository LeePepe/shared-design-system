import XCTest

final class DialogReviewUITests: XCTestCase {
    func testDialogVisibleBeforeDismissalAndAlertConfirmation() {
        let launches = [
            ("strata-blue", "light", "dialog-blue-light"),
            ("strata-blue", "dark", "dialog-blue-dark"),
            ("strata-purple", "light", "dialog-purple-light"),
            ("strata-purple", "dark", "dialog-purple-dark")
        ]

        for (brand, mode, attachmentName) in launches {
            let app = XCUIApplication()
            app.launchEnvironment = ["NDK_BRAND": brand, "NDK_THEME": mode]
            app.launch()
            XCTAssertTrue(app.staticTexts["Dialog review"].waitForExistence(timeout: 10))
            XCTAssertTrue(app.staticTexts["Choose perceived exertion from RPE 6.0–10.0"].exists)
            XCTAssertTrue(app.staticTexts["Finish the current set before closing."].exists)
            XCTAssertTrue(app.buttons["Save RPE"].exists)
            XCTAssertTrue(app.buttons["Cancel"].exists)
            capture(attachmentName, app: app)
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: 0.05)).tap()
            XCTAssertTrue(app.staticTexts["Finish the current set before closing."].exists)
            app.buttons["Allow outside"].tap()
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: 0.05)).tap()
            XCTAssertFalse(app.staticTexts["Choose perceived exertion from RPE 6.0–10.0"].exists)
            app.launch()
            XCTAssertTrue(app.staticTexts["Choose perceived exertion from RPE 6.0–10.0"].waitForExistence(timeout: 10))
            app.buttons["Close"].tap()
            XCTAssertTrue(app.staticTexts["Finish the current set before closing."].exists)
            app.buttons["Save RPE"].tap()
            XCTAssertFalse(app.staticTexts["Choose perceived exertion from RPE 6.0–10.0"].exists)
            app.buttons["Open finish confirmation"].tap()
            XCTAssertTrue(app.alerts["Finish workout?"].waitForExistence(timeout: 2))
            app.alerts["Finish workout?"].buttons["Finish"].tap()
            app.terminate()
        }
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
