import XCTest

final class SearchFieldReviewUITests: XCTestCase {
    func testMatrixAndClearInteraction() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Search and number slots"].waitForExistence(timeout: 10))
        for (brand, mode) in [("ocean", "light"), ("ocean", "dark"),
                              ("graphite", "light"), ("graphite", "dark")] {
            let name = "search-\(brand)-\(mode)"
            let header = app.staticTexts["\(brand.capitalized) \(mode.capitalized)"]
            XCTAssertTrue(header.waitForExistence(timeout: 5), "\(brand)/\(mode) board")
            XCTAssertTrue(app.textFields["Search exercises \(brand) \(mode)"].exists)
            XCTAssertTrue(app.textFields["Empty search \(brand) \(mode)"].exists)
            XCTAssertTrue(app.textFields["Disabled search \(brand) \(mode)"].exists)
            XCTAssertTrue(app.buttons["Completed weight"].exists)
            let board = app.otherElements["review-\(brand)-\(mode)"].firstMatch
            XCTAssertTrue(board.waitForExistence(timeout: 5), "\(brand)/\(mode) control board")
            let attachment = XCTAttachment(screenshot: board.screenshot())
            attachment.name = name
            attachment.lifetime = .keepAlways
            add(attachment)
        }
        let oceanLightBoard = app.otherElements["review-ocean-light"].firstMatch
        let clear = oceanLightBoard.descendants(matching: .button)
            .matching(NSPredicate(format: "label == %@", "Clear search")).firstMatch
        XCTAssertTrue(clear.waitForExistence(timeout: 5))
        clear.tap()
        XCTAssertTrue(app.staticTexts["Clears: Ocean Light: 1"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Clears: Ocean Dark: 0"].exists)
    }
}
