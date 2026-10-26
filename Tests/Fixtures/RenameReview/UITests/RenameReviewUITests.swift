import XCTest

final class RenameReviewUITests: XCTestCase {
    func testStrataPublicSurfaceRenders() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["strata-title"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["strata-button"].exists)
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "strata-surface"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
