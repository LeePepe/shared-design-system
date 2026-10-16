import XCTest

@MainActor
final class CardReviewUITests: XCTestCase {
    func testCallerActionsAndDisabledDescendantRemainIndependent() {
        let app = launch()
        let action = app.buttons["card-action"]
        let disabled = app.buttons["card-disabled-action"]
        XCTAssertTrue(action.isEnabled)
        XCTAssertFalse(disabled.isEnabled)
        // XCTest can report an exact 44pt SwiftUI frame as 43.999969pt.
        XCTAssertGreaterThanOrEqual(action.frame.height, 44 - 0.001)
        XCTAssertGreaterThanOrEqual(disabled.frame.height, 44 - 0.001)
        action.tap()
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 1")
        for _ in 0..<3 {
            disabled.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 1")
        // The card background must not acquire an implicit activation action.
        card(app).coordinate(withNormalizedOffset: CGVector(dx: 0.97, dy: 0.5)).tap()
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 1")
    }

    func testLongTextAndAccessibilityDynamicTypeGrowWithoutHorizontalOverflow() {
        var app = launch()
        let short = card(app).frame
        app.terminate()
        app = launch(scenario: "long")
        let long = card(app).frame
        XCTAssertGreaterThan(long.height, short.height + 40)
        assertSlotOrderAndHorizontalBounds(app)
        capture("card-narrow-long", app: app)
        app.terminate()
        app = launch(scenario: "long", size: "accessibility3")
        let accessible = card(app).frame
        XCTAssertGreaterThan(accessible.height, long.height + 40)
        assertSlotOrderAndHorizontalBounds(app)
        capture("card-accessibility3-top", app: app)
        reveal(app.staticTexts["fixture-note"], in: app)
        let viewport = app.scrollViews["review-scroll"].frame
        XCTAssertTrue(viewport.contains(app.buttons["card-action"].frame))
        XCTAssertTrue(viewport.contains(app.buttons["card-disabled-action"].frame))
        capture("card-accessibility3-bottom", app: app)
        print("CARD_UI_GROWTH short=\(short) long=\(long) accessibility3=\(accessible)")
    }

    func testContentOnlyAndEmptySlotsHaveTheSameCompactLayout() {
        var app = launch(scenario: "content-only")
        let compact = card(app).frame
        XCTAssertTrue(app.staticTexts["card-body"].exists)
        XCTAssertFalse(app.buttons["card-action"].exists)
        XCTAssertLessThan(compact.height, 80)
        app.terminate()
        app = launch(scenario: "empty-slots")
        XCTAssertEqual(card(app).frame.height, compact.height, accuracy: 0.5)
        XCTAssertEqual(card(app).frame.width, compact.width, accuracy: 0.5)
    }

    func testThemeMaterialAndTransparencyKeepStableLayout() {
        var reference: CGRect?
        for brand in ["ocean", "graphite"] {
            for mode in ["light", "dark"] {
                for surface in ["solid", "glass"] {
                    for preference in ["off", "on"] {
                        let app = launch(scenario: "long", brand: brand, mode: mode,
                                         surface: surface, preference: preference)
                        let measured = card(app).frame
                        if let reference {
                            XCTAssertEqual(measured.height, reference.height, accuracy: 0.5)
                            XCTAssertEqual(measured.width, reference.width, accuracy: 0.5)
                        } else { reference = measured }
                        assertSlotOrderAndHorizontalBounds(app)
                        app.terminate()
                    }
                }
            }
        }
        print("CARD_UI_STABILITY variants=16 frame=\(String(describing: reference))")
    }

    func testVisualOceanLight() { visualMatrix(brand: "ocean", mode: "light") }
    func testVisualOceanDark() { visualMatrix(brand: "ocean", mode: "dark") }
    func testVisualGraphiteLight() { visualMatrix(brand: "graphite", mode: "light") }
    func testVisualGraphiteDark() { visualMatrix(brand: "graphite", mode: "dark") }

    private func visualMatrix(brand: String, mode: String) {
        for specimen in ["solid", "glass", "fallback"] {
            let app = launch(brand: brand, mode: mode,
                             surface: specimen == "solid" ? "solid" : "glass",
                             preference: specimen == "fallback" ? "on" : "off")
            let frame = card(app).frame
            XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(frame),
                          "The whole card must be onscreen before capture.")
            assertSlotOrderAndHorizontalBounds(app)
            XCTAssertTrue(app.buttons["card-action"].isEnabled)
            XCTAssertFalse(app.buttons["card-disabled-action"].isEnabled)
            let name = "card-\(brand)-\(mode)-\(specimen)"
            print("CARD_UI_PIXEL \(name) x=\(frame.maxX - 8) y=\(frame.midY) width=\(app.frame.width) height=\(app.frame.height)")
            capture(name, app: app)
            app.terminate()
        }
    }

    private func assertSlotOrderAndHorizontalBounds(_ app: XCUIApplication) {
        let bounds = card(app).frame
        let title = app.staticTexts["card-title"].frame
        let body = app.staticTexts["card-body"].frame
        let supporting = app.staticTexts["card-supporting"].frame
        let action = app.buttons["card-action"].frame
        XCTAssertLessThanOrEqual(title.maxY, body.minY)
        XCTAssertLessThanOrEqual(body.maxY, supporting.minY)
        XCTAssertLessThanOrEqual(supporting.maxY, action.minY)
        for frame in [title, body, supporting, action, app.buttons["card-disabled-action"].frame] {
            XCTAssertGreaterThanOrEqual(frame.minX, bounds.minX)
            XCTAssertLessThanOrEqual(frame.maxX, bounds.maxX + 0.5)
        }
        XCTAssertLessThanOrEqual(bounds.width, 320.5)
    }

    private func card(_ app: XCUIApplication) -> XCUIElement {
        app.otherElements["review-card"]
    }

    private func reveal(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<5 where !element.isHittable { app.scrollViews["review-scroll"].swipeUp() }
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func launch(scenario: String = "four-slot", brand: String = "ocean", mode: String = "light",
                        surface: String = "solid", preference: String = "off", size: String = "large") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment = ["NDK_SCENARIO": scenario, "NDK_BRAND": brand, "NDK_THEME": mode,
                                 "NDK_SURFACE": surface, "NDK_REDUCE_TRANSPARENCY": preference,
                                 "NDK_TEXT_SIZE": size]
        app.launch()
        XCTAssertTrue(app.scrollViews["review-scroll"].waitForExistence(timeout: 10), app.debugDescription)
        XCTAssertTrue(card(app).waitForExistence(timeout: 10), app.debugDescription)
        return app
    }
}
