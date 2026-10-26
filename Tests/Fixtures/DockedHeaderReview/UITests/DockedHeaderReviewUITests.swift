import XCTest

final class DockedHeaderReviewUITests: XCTestCase {
    func testDockedHeaderBoardAndInteraction() {
        let launches = [
            ("strata-blue", "light", "docked-blue-light"),
            ("strata-blue", "dark", "docked-blue-dark"),
            ("strata-purple", "light", "docked-purple-light"),
            ("strata-purple", "dark", "docked-purple-dark")
        ]

        for (brand, mode, attachmentName) in launches {
            let app = XCUIApplication()
            app.launchEnvironment = ["NDK_BRAND": brand, "NDK_THEME": mode]
            app.launch()
            XCTAssertTrue(app.staticTexts["Docked header components"].waitForExistence(timeout: 10))
            XCTAssertTrue(app.staticTexts["Barbell"].exists)
            XCTAssertTrue(app.staticTexts["Bodyweight"].exists)
            XCTAssertTrue(app.buttons["More"].exists)
            XCTAssertTrue(app.staticTexts["Add exercise"].exists)
            XCTAssertTrue(app.staticTexts["Unavailable"].exists)
            XCTAssertTrue(app.staticTexts["Sync failed"].exists)
            XCTAssertTrue(app.otherElements["index-rail"].exists)
            XCTAssertTrue(app.descendants(matching: .any)["empty-index-rail-host"].exists)
            XCTAssertTrue(app.buttons["Barbell"].exists)
            XCTAssertTrue(app.buttons["Dumbbell"].exists)
            app.buttons["More"].tap()
            XCTAssertTrue(app.staticTexts["Selected: more"].waitForExistence(timeout: 2))
            app.buttons["Dumbbell"].tap()
            XCTAssertTrue(app.staticTexts["Selected: dumbbell"].waitForExistence(timeout: 2))

            let dragStart = app.buttons["Dumbbell"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            let dragEnd = app.buttons["Machine"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            dragStart.press(forDuration: 0.1, thenDragTo: dragEnd, withVelocity: XCUIGestureVelocity.default, thenHoldForDuration: 0)
            XCTAssertTrue(app.staticTexts["Selected: machine"].waitForExistence(timeout: 2))

            app.buttons["Done"].tap()
            XCTAssertTrue(app.staticTexts["Selected: done"].exists)
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
