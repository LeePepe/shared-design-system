import XCTest

@MainActor
final class ListReviewUITests: XCTestCase {
    private let titles = ["表面与层次", "色彩与语义", "文字与节奏"]

    func testSingleSelectionDisabledRowsExternalStateAndStableIdentity() {
        let app = launch(scenario: "interaction")
        let surface = row(titles[0], in: app)
        let color = row(titles[1], in: app)
        let type = row(titles[2], in: app)
        for button in [surface, color, type] { minimumTarget(button) }
        XCTAssertTrue(surface.isSelected)
        XCTAssertFalse(color.isSelected)
        surface.tap()
        XCTAssertEqual(app.staticTexts["selection-writes"].label, "Writes: 0")
        color.tap()
        XCTAssertFalse(surface.isSelected)
        XCTAssertTrue(color.isSelected)
        XCTAssertEqual(app.staticTexts["selection-context"].label, "当前：色彩与语义")
        XCTAssertEqual(app.staticTexts["selection-writes"].label, "Writes: 1")
        XCTAssertFalse(type.isEnabled)
        type.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        XCTAssertTrue(color.isSelected)
        XCTAssertEqual(app.staticTexts["selection-writes"].label, "Writes: 1")
        app.buttons["reverse-items"].tap()
        XCTAssertTrue(color.isSelected)
        XCTAssertLessThan(type.frame.minY, color.frame.minY)
        surface.tap()
        app.buttons["external-selection"].tap()
        XCTAssertTrue(color.isSelected)
        XCTAssertEqual(app.staticTexts["selection-writes"].label, "Writes: 2")
        let enabledFrame = color.frame
        app.buttons["toggle-disabled"].tap()
        XCTAssertFalse(color.isEnabled)
        color.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        surface.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        XCTAssertEqual(app.staticTexts["selection-writes"].label, "Writes: 2")
        XCTAssertEqual(color.frame, enabledFrame)
        capture("list-disabled-selection", app)
        app.buttons["toggle-disabled"].tap()
        surface.tap()
        XCTAssertTrue(surface.isSelected)
        XCTAssertEqual(app.staticTexts["selection-writes"].label, "Writes: 3")
        capture("list-interaction-selection", app)
    }

    func testMultipleSelectionAndReadOnlyPresentation() {
        var app = launch(scenario: "multiple")
        row(titles[1], in: app).tap()
        XCTAssertTrue(row(titles[0], in: app).isSelected)
        XCTAssertTrue(row(titles[1], in: app).isSelected)
        XCTAssertEqual(app.staticTexts["selected-count"].label, "2 项已选")
        row(titles[0], in: app).tap()
        XCTAssertFalse(row(titles[0], in: app).isSelected)
        XCTAssertEqual(app.staticTexts["selected-count"].label, "1 项已选")
        app.terminate()
        app = launch(scenario: "read-only")
        for title in titles { XCTAssertFalse(row(title, in: app).exists) }
        let staticRow = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", titles[0])).firstMatch
        XCTAssertTrue(staticRow.exists)
        staticRow.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        XCTAssertEqual(app.staticTexts["selection-writes"].label, "Writes: 0")
        capture("list-read-only", app)
    }

    func testLongLabelsGrowInsideNarrowAccessibilityLayout() {
        var app = launch(scenario: "long-label")
        let title = "Surface hierarchy with a complete, caller-owned descriptive title"
        let standard = row(title, in: app).frame
        app.terminate()
        app = launch(scenario: "long-label", mode: "dark", size: "accessibility2")
        let button = row(title, in: app)
        minimumTarget(button)
        XCTAssertTrue(button.label.contains(title))
        XCTAssertTrue(button.label.contains("Supporting information wraps naturally and remains readable at accessibility sizes."))
        XCTAssertGreaterThan(button.frame.height, standard.height + 40)
        XCTAssertLessThanOrEqual(button.frame.width, 264)
        XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(button.frame))
        XCTAssertTrue(app.frame.contains(app.staticTexts["selected-count"].frame))
        capture("list-accessibility-narrow", app)
    }

    func testVisualBlueLight() { matrix("blue", "light") }
    func testVisualBlueDark() { matrix("blue", "dark") }
    func testVisualGreenLight() { matrix("green", "light") }
    func testVisualGreenDark() { matrix("green", "dark") }
    func testVisualPinkLight() { matrix("pink", "light") }
    func testVisualPinkDark() { matrix("pink", "dark") }
    func testVisualYellowLight() { matrix("yellow", "light") }
    func testVisualYellowDark() { matrix("yellow", "dark") }
    func testVisualPurpleLight() { matrix("purple", "light") }
    func testVisualPurpleDark() { matrix("purple", "dark") }

    func testActualSystemReduceTransparencyAndRestorePreference() throws {
        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        settings.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        settings.launch()
        for _ in 0..<6 {
            if settings.navigationBars["Settings"].exists { break }
            let back = settings.navigationBars.buttons.firstMatch
            guard back.exists else { break }
            back.tap()
        }
        let accessibility = settings.staticTexts["Accessibility"]
        for _ in 0..<8 where !accessibility.isHittable { settings.swipeUp() }
        XCTAssertTrue(accessibility.waitForExistence(timeout: 5))
        accessibility.tap()
        settings.staticTexts["Display & Text Size"].tap()
        let toggle = settings.switches["Reduce Transparency"]
        for _ in 0..<5 where !toggle.isHittable { settings.swipeUp() }
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        let original = try XCTUnwrap(toggle.value as? String)
        XCTAssertTrue(["0", "1"].contains(original))
        let originalEvidence = XCTAttachment(string: "Original Reduce Transparency: \(original); frame: \(toggle.frame)")
        originalEvidence.name = "system-transparency-original"
        originalEvidence.lifetime = .keepAlways
        add(originalEvidence)
        defer {
            settings.activate()
            setSwitch(toggle, to: original)
            XCTAssertEqual(toggle.value as? String, original, "Restore the original simulator preference.")
            let restored = XCTAttachment(string: "Restored Reduce Transparency: \(toggle.value as? String ?? "missing")")
            restored.name = "system-transparency-restored"
            restored.lifetime = .keepAlways
            add(restored)
            settings.terminate()
        }
        setSwitch(toggle, to: "1")
        XCTAssertEqual(toggle.value as? String, "1")
        let app = launch(scenario: "system-fallback")
        XCTAssertEqual(app.staticTexts["system-transparency"].label, "System transparency: reduced")
        for title in titles { minimumTarget(row(title, in: app)) }
        capture("list-system-reduced-transparency", app)
        row(titles[1], in: app).tap()
        XCTAssertTrue(row(titles[1], in: app).isSelected)
        app.terminate()
    }

    private func setSwitch(_ toggle: XCUIElement, to value: String) {
        if toggle.value as? String != value {
            toggle.coordinate(withNormalizedOffset: CGVector(dx: 0.94, dy: 0.5)).tap()
        }
        let changed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", value), object: toggle)
        XCTAssertEqual(XCTWaiter.wait(for: [changed], timeout: 5), .completed,
                       "The actual Settings switch must reach \(value).")
    }

    func testInvalidBrandDoesNotRenderFallbackList() {
        let app = launch(brand: "__invalid_list_brand__", expectsError: true)
        XCTAssertTrue(app.staticTexts["fixture-error"].label.contains("__invalid_list_brand__"))
        XCTAssertFalse(row(titles[0], in: app).exists)
    }

    private func matrix(_ palette: String, _ mode: String) {
        for surface in ["glass", "solid"] {
            let app = launch(brand: "strata-\(palette)", mode: mode, surface: surface)
            assertSpecimen(app)
            capture("list-\(palette)-\(mode)-\(surface)", app)
            app.terminate()
        }
        let app = launch(brand: "strata-\(palette)", mode: mode, reduceTransparency: true)
        assertSpecimen(app)
        capture("list-\(palette)-\(mode)-forced-reduced", app)
        app.terminate()
    }

    private func assertSpecimen(_ app: XCUIApplication) {
        let viewport = app.scrollViews["review-scroll"].frame
        for title in titles {
            let button = row(title, in: app)
            minimumTarget(button)
            XCTAssertTrue(viewport.contains(button.frame), "Entire row must be visible: \(button.frame)")
        }
        XCTAssertTrue(row(titles[0], in: app).isSelected)
        XCTAssertTrue(app.frame.contains(app.staticTexts["list-heading"].frame))
        XCTAssertTrue(app.frame.contains(app.staticTexts["selected-count"].frame))
        XCTAssertTrue(app.frame.contains(app.staticTexts["specimen-note"].frame))
    }

    private func row(_ title: String, in app: XCUIApplication) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label CONTAINS %@", title)).firstMatch
    }

    private func minimumTarget(_ element: XCUIElement) {
        XCTAssertTrue(element.exists)
        XCTAssertGreaterThanOrEqual((element.frame.width * 1000).rounded() / 1000, 44)
        XCTAssertGreaterThanOrEqual((element.frame.height * 1000).rounded() / 1000, 44)
    }

    private func capture(_ name: String, _ app: XCUIApplication) {
        if let raw = app.staticTexts["specimen-note"].value as? String,
           let data = raw.data(using: .utf8),
           var frames = (try? JSONSerialization.jsonObject(with: data)) as? [String: [Double]] {
            XCTAssertFalse(frames.isEmpty, "Runtime text frames must accompany actual PNG contrast inspection.")
            XCTAssertEqual(frames["_systemReduced"], [name == "list-system-reduced-transparency" ? 1 : 0],
                           "Capture labels must agree with the observed system transparency setting.")
            let heading = app.staticTexts["list-heading"].frame
            frames["_headingAX"] = [heading.minX, heading.minY, heading.width, heading.height]
            frames["_screen"] = [0, 0, app.frame.width, app.frame.height]
            for (name, label) in [("_section", "03  List 列表"), ("_masthead", "Strata · 岩层")] {
                let frame = app.staticTexts[label].frame
                frames[name] = [frame.minX, frame.minY, frame.width, frame.height]
            }
            for (index, title) in titles.enumerated() {
                let button = row(title, in: app)
                if button.exists {
                    let frame = button.frame
                    frames["_row-\(index)"] = [frame.minX, frame.minY, frame.width, frame.height]
                }
            }
            let telemetry = try! JSONSerialization.data(withJSONObject: frames, options: [.sortedKeys])
            let geometry = XCTAttachment(data: telemetry, uniformTypeIdentifier: "public.json")
            geometry.name = name + "-geometry"
            geometry.lifetime = .keepAlways
            add(geometry)
        } else {
            XCTFail("Missing runtime text geometry for " + name)
        }
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func launch(scenario: String = "specimen", brand: String = "strata-blue", mode: String = "light",
                        surface: String = "glass", size: String = "large", reduceTransparency: Bool = false,
                        expectsError: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment = ["NDK_SCENARIO": scenario, "NDK_BRAND": brand, "NDK_THEME": mode,
                                 "NDK_SURFACE": surface, "NDK_TEXT_SIZE": size,
                                 "NDK_REDUCE_TRANSPARENCY": reduceTransparency ? "1" : "0"]
        app.launch()
        XCTAssertTrue((expectsError ? app.staticTexts["fixture-error"] : app.scrollViews["review-scroll"])
            .waitForExistence(timeout: 10), app.debugDescription)
        return app
    }
}
