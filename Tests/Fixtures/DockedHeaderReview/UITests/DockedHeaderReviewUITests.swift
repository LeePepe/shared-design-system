import XCTest

final class DockedHeaderReviewUITests: XCTestCase {
    func testDockedHeaderBoardAndInteraction() {
        let app = XCUIApplication()
        app.launchEnvironment = [
            "NDK_BRAND": ProcessInfo.processInfo.environment["NDK_BRAND"] ?? "strata-blue",
            "NDK_THEME": ProcessInfo.processInfo.environment["NDK_THEME"] ?? "light"
        ]
        app.launch()
        XCTAssertTrue(app.staticTexts["Docked header components"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Barbell"].exists)
        XCTAssertTrue(app.staticTexts["Add exercise"].exists)
        XCTAssertTrue(app.otherElements["index-rail"].exists)
        XCTAssertTrue(app.buttons["Barbell"].exists)
        XCTAssertTrue(app.buttons["Dumbbell"].exists)
        app.buttons["Dumbbell"].tap()
        XCTAssertTrue(app.staticTexts["Selected: dumbbell"].waitForExistence(timeout: 2))
        app.buttons["Done"].tap()
        XCTAssertTrue(app.staticTexts["Selected: done"].exists)
        capture("docked-header")
        capture("section-header")
        capture("index-rail")
        capture("combined")
    }

    private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: XCUIApplication().screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
