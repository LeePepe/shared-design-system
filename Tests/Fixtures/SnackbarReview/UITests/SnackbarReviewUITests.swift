import XCTest

final class SnackbarReviewUITests: XCTestCase {
    func testSnackbarBoardAndInteraction() {
        let launches = [
            ("strata-blue", "light", "snackbar-blue-light"),
            ("strata-blue", "dark", "snackbar-blue-dark"),
            ("strata-purple", "light", "snackbar-purple-light"),
            ("strata-purple", "dark", "snackbar-purple-dark")
        ]

        for (brand, mode, attachmentName) in launches {
            let app = XCUIApplication()
            app.launchEnvironment = ["NDK_BRAND": brand, "NDK_THEME": mode]
            app.launch()
            XCTAssertTrue(app.staticTexts["Snackbar review"].waitForExistence(timeout: 10))
            XCTAssertTrue(app.staticTexts["Set deleted"].exists)
            XCTAssertTrue(app.buttons["Undo"].exists)
            XCTAssertTrue(app.buttons["Close"].exists)
            XCTAssertTrue(app.staticTexts["Bottom bar coordination"].exists)
            app.buttons["Undo"].tap()
            XCTAssertTrue(app.staticTexts["Result: action"].waitForExistence(timeout: 2))
            app.buttons["Close"].tap()
            XCTAssertTrue(app.staticTexts["Result: close"].waitForExistence(timeout: 2))
            capture(attachmentName, app: app)
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
