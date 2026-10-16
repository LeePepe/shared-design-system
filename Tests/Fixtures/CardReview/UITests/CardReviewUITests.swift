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

    func testStrataBlueLight() { strataMatrix(brand: "strata-blue", mode: "light") }
    func testStrataBlueDark() { strataMatrix(brand: "strata-blue", mode: "dark") }
    func testStrataGreenLight() { strataMatrix(brand: "strata-green", mode: "light") }
    func testStrataGreenDark() { strataMatrix(brand: "strata-green", mode: "dark") }
    func testStrataPinkLight() { strataMatrix(brand: "strata-pink", mode: "light") }
    func testStrataPinkDark() { strataMatrix(brand: "strata-pink", mode: "dark") }
    func testStrataYellowLight() { strataMatrix(brand: "strata-yellow", mode: "light") }
    func testStrataYellowDark() { strataMatrix(brand: "strata-yellow", mode: "dark") }
    func testStrataPurpleLight() { strataMatrix(brand: "strata-purple", mode: "light") }
    func testStrataPurpleDark() { strataMatrix(brand: "strata-purple", mode: "dark") }

    func testSpecimenCallerActionAndNarrowAccessibilityLayout() {
        var app = launchSpecimen()
        let action = app.buttons["specimen-detail-action"]
        XCTAssertGreaterThanOrEqual(action.frame.height, 44 - 0.001)
        XCTAssertGreaterThanOrEqual(action.frame.width, 44 - 0.001)
        action.tap()
        XCTAssertEqual(app.staticTexts["specimen-feedback"].label, "Details viewed: 1 · caller-owned action")
        capture("card-specimen-action", app: app)
        app.terminate()
        app = launchSpecimen(scenario: "specimen-long")
        let long = app.otherElements["specimen-content-card"].frame
        assertSpecimenHorizontalBounds(app)
        capture("card-specimen-narrow", app: app)
        app.terminate()
        app = launchSpecimen(scenario: "specimen-long", size: "accessibility3")
        let accessible = app.otherElements["specimen-content-card"].frame
        XCTAssertGreaterThan(accessible.height, long.height + 40)
        assertSpecimenHorizontalBounds(app)
        capture("card-specimen-accessibility3-top", app: app)
        for _ in 0..<8 where !app.buttons["specimen-detail-action"].isHittable {
            app.scrollViews["specimen-scroll"].swipeUp()
        }
        XCTAssertTrue(app.buttons["specimen-detail-action"].isHittable)
        capture("card-specimen-accessibility3-action", app: app)
        for _ in 0..<8 where !app.staticTexts["specimen-feedback"].isHittable {
            app.scrollViews["specimen-scroll"].swipeUp()
        }
        XCTAssertTrue(app.staticTexts["specimen-feedback"].isHittable)
        XCTAssertLessThanOrEqual(app.staticTexts["specimen-stat-title"].frame.maxY,
                                 app.staticTexts["specimen-data-context"].frame.minY + 0.5)
        capture("card-specimen-accessibility3-bottom", app: app)
    }

    func testSystemReduceTransparencyUsesTheSameSolidCardRole() {
        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        // Scope language to this Settings process; never change the simulator locale.
        settings.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        settings.launch()
        let root = settings.navigationBars.matching(NSPredicate(format: "identifier IN %@", ["Settings", "设置"])).firstMatch
        for _ in 0..<4 where !root.exists {
            let back = settings.navigationBars.buttons.firstMatch
            if !back.exists { break }
            back.tap()
        }
        let accessibility = settings.staticTexts.matching(
            NSPredicate(format: "label IN %@", ["Accessibility", "辅助功能"])).firstMatch
        // Settings may remember a scroll position below the desired row.
        for _ in 0..<8 where !accessibility.isHittable { settings.swipeDown() }
        for _ in 0..<8 where !accessibility.isHittable { settings.swipeUp() }
        guard accessibility.waitForExistence(timeout: 5) else {
            XCTFail("Accessibility settings not found: \(settings.debugDescription)")
            settings.terminate()
            return
        }
        accessibility.tap()
        settings.staticTexts.matching(NSPredicate(format: "label IN %@", ["Display & Text Size", "显示与文字大小"])).firstMatch.tap()
        let preference = settings.switches.matching(
            NSPredicate(format: "identifier == %@ OR label IN %@", "REDUCE_TRANSPARENCY",
                        ["Reduce Transparency", "降低透明度"])).firstMatch
        for _ in 0..<4 where !preference.isHittable { settings.swipeUp() }
        XCTAssertTrue(preference.waitForExistence(timeout: 5))
        guard let original = preference.value as? String, ["0", "1"].contains(original) else {
            XCTFail("Reduce Transparency did not expose a readable system preference")
            settings.terminate()
            return
        }
        func setPreference(_ value: String) {
            if (preference.value as? String) != value {
                // The accessibility switch includes the row; hit its trailing
                // native toggle rather than the middle of the label area.
                preference.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
            }
            let changed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", value),
                                                    object: preference)
            XCTAssertEqual(XCTWaiter.wait(for: [changed], timeout: 5), .completed)
            XCTAssertEqual(preference.value as? String, value)
        }
        defer {
            settings.activate()
            setPreference(original)
            print("CARD_SYSTEM_TRANSPARENCY original=\(original) restored=\(preference.value ?? "unreadable")")
            settings.terminate()
        }
        // Exercise a real change even when the original setting was already on.
        if original == "1" { setPreference("0") }
        setPreference("1")
        XCTAssertEqual(preference.value as? String, "1")
        let app = launchSpecimen(preference: "system")
        XCTAssertEqual(app.staticTexts["system-transparency"].label, "System Reduce Transparency: on")
        recordSpecimenGeometry(app, name: "card-strata-blue-light-system-fallback")
        capture("card-strata-blue-light-system-fallback", app: app)
        app.terminate()
    }

    private func strataMatrix(brand: String, mode: String) {
        var reference: CGRect?
        for material in ["solid", "glass", "fallback"] {
            let app = launchSpecimen(brand: brand, mode: mode,
                                     surface: material == "solid" ? "solid" : "glass",
                                     preference: material == "fallback" ? "on" : "off")
            let frame = app.otherElements["specimen-content-card"].frame
            XCTAssertTrue(app.scrollViews["specimen-scroll"].frame.contains(frame))
            XCTAssertTrue(app.scrollViews["specimen-scroll"].frame.contains(app.otherElements["specimen-stat-card"].frame))
            if let reference {
                XCTAssertEqual(frame.height, reference.height, accuracy: 0.5)
                XCTAssertEqual(frame.width, reference.width, accuracy: 0.5)
                XCTAssertEqual(frame.minY, reference.minY, accuracy: 0.5)
            } else { reference = frame }
            assertSpecimenHorizontalBounds(app)
            let name = "card-\(brand)-\(mode)-\(material)"
            recordSpecimenGeometry(app, name: name)
            capture(name, app: app)
            app.terminate()
        }
    }

    private func assertSpecimenHorizontalBounds(_ app: XCUIApplication) {
        let bounds = app.otherElements["specimen-content-card"].frame
        for element in [app.staticTexts["specimen-title"], app.staticTexts["specimen-body"],
                        app.staticTexts["specimen-footer"], app.buttons["specimen-detail-action"]] {
            let frame = element.frame
            XCTAssertGreaterThanOrEqual(frame.minX, bounds.minX)
            XCTAssertLessThanOrEqual(frame.maxX, bounds.maxX + 0.5)
        }
        XCTAssertLessThanOrEqual(bounds.maxX, app.frame.maxX)
        XCTAssertGreaterThanOrEqual(bounds.minX, app.frame.minX)
    }

    private func recordSpecimenGeometry(_ app: XCUIApplication, name: String) {
        let frame = app.otherElements["specimen-content-card"].frame
        let stat = app.otherElements["specimen-stat-card"].frame
        print("CARD_STRATA_GEOMETRY \(name) width=\(app.frame.width) height=\(app.frame.height) card=\(frame) stat=\(stat)")
        for id in ["specimen-title", "specimen-body", "specimen-footer", "specimen-status", "specimen-item-count",
                   "specimen-context", "specimen-stat-title", "specimen-data-context", "specimen-metric", "specimen-percent",
                   "specimen-stat-kind", "specimen-stat-note", "specimen-feedback"] {
            print("CARD_STRATA_TEXT \(name) \(id) frame=\(app.staticTexts[id].frame)")
        }
        print("CARD_STRATA_TEXT \(name) specimen-detail-action frame=\(app.buttons["specimen-detail-action"].frame)")
    }

    private func launchSpecimen(scenario: String = "specimen", brand: String = "strata-blue", mode: String = "light",
                                surface: String = "glass", preference: String = "off", size: String = "large") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment = ["NDK_SCENARIO": scenario, "NDK_BRAND": brand, "NDK_THEME": mode,
                                 "NDK_SURFACE": surface, "NDK_REDUCE_TRANSPARENCY": preference,
                                 "NDK_TEXT_SIZE": size]
        app.launch()
        XCTAssertTrue(app.scrollViews["specimen-scroll"].waitForExistence(timeout: 10), app.debugDescription)
        XCTAssertTrue(app.otherElements["specimen-content-card"].waitForExistence(timeout: 10), app.debugDescription)
        return app
    }

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
            let region = app.otherElements["review-region"].frame
            XCTAssertTrue(region.contains(frame))
            print("CARD_UI_OUTER_PIXEL \(name) x=\(region.maxX - 8) y=\(region.midY) width=\(app.frame.width) height=\(app.frame.height)")
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
