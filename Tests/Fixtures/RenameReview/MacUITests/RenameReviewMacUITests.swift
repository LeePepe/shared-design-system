import XCTest

final class RenameReviewMacUITests: XCTestCase {
    func testStrataSurfaceRendersOnMac() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.waitForExistence(timeout: 10))
        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Strata"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["Action"].waitForExistence(timeout: 10))
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "strata-surface"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
