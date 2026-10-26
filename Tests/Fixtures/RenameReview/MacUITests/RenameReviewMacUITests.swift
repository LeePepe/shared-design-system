import XCTest

final class RenameReviewMacUITests: XCTestCase {
    func testStrataSurfaceRendersOnMac() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["strata-title"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["strata-button"].exists)
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "strata-surface-mac"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
