import XCTest

final class SearchFieldReviewUITests: XCTestCase {
    func testMatrixAndClearInteraction() {
        for (brand, mode) in [("ocean", "light"), ("ocean", "dark"),
                              ("graphite", "light"), ("graphite", "dark")] {
            let app = XCUIApplication()
            app.launchEnvironment = ["NDK_BRAND": brand, "NDK_THEME": mode]
            app.launch()
            XCTAssertTrue(app.staticTexts["Search and number slots"].waitForExistence(timeout: 10))
            let header = app.staticTexts["\(brand.capitalized) \(mode.capitalized)"]
            XCTAssertTrue(header.waitForExistence(timeout: 5), "\(brand)/\(mode) board")
            XCTAssertTrue(app.textFields["Search exercises"].exists)
            XCTAssertTrue(app.textFields["Empty search"].exists)
            XCTAssertTrue(app.textFields["Disabled search"].exists)
            XCTAssertTrue(app.staticTexts["Enter at least 2 characters"].exists)
            XCTAssertTrue(app.buttons["Completed weight"].exists)
            XCTAssertTrue(app.buttons["Left weight"].exists)
            XCTAssertTrue(app.buttons["Right weight"].exists)
            XCTAssertTrue(app.buttons["Disabled weight"].exists)
            XCTAssertFalse(app.buttons.matching(NSPredicate(format: "identifier == %@",
                                                            "strata-search-field-clear-Disabled search"))
                .firstMatch.exists)
            let board = app.otherElements["review-\(brand)-\(mode)"].firstMatch
            XCTAssertTrue(board.waitForExistence(timeout: 5), "\(brand)/\(mode) control board")
            XCTAssertTrue(app.scrollViews.firstMatch.frame.contains(board.frame))
            let clear = app.buttons["Clear search"].firstMatch
            XCTAssertTrue(clear.waitForExistence(timeout: 5))
            clear.tap()
            XCTAssertTrue(app.staticTexts["Clears: 1"].waitForExistence(timeout: 2))
            let attachment = XCTAttachment(screenshot: board.screenshot())
            attachment.name = "search-\(brand)-\(mode)"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
    }
}
