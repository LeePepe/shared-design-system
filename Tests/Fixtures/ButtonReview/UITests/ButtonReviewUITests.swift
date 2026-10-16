import XCTest

@MainActor
final class ButtonReviewUITests: XCTestCase {
    func testActionDispatchAndDisabledLoadingCoordinateTaps() {
        let app = launch(scenario: "interaction")
        let target = app.buttons["action-target"]
        XCTAssertTrue(target.isEnabled)
        target.tap()
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 1")

        app.buttons["toggle-disabled"].tap()
        XCTAssertFalse(target.isEnabled)
        for _ in 0..<3 { target.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 1")

        app.buttons["toggle-disabled"].tap()
        app.buttons["toggle-loading"].tap()
        XCTAssertFalse(target.isEnabled)
        for _ in 0..<3 { target.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 1")
        app.buttons["toggle-loading"].tap()
        target.tap()
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 2")
    }

    func testLoadingPreservesFootprintAndMinimumTarget() {
        let app = launch(scenario: "interaction")
        let target = app.buttons["action-target"]
        let idle = target.frame
        XCTAssertGreaterThanOrEqual(idle.width, 44)
        XCTAssertGreaterThanOrEqual(idle.height, 44)
        app.buttons["toggle-loading"].tap()
        XCTAssertEqual(app.staticTexts["loading-state"].label, "Loading")
        XCTAssertEqual(target.frame.width, idle.width, accuracy: 0.5)
        XCTAssertEqual(target.frame.height, idle.height, accuracy: 0.5)
        XCTAssertTrue(app.frame.contains(target.frame))
        print("Button footprint: idle=\(idle), loading=\(target.frame)")
    }

    func testLongLocalizedAccessibilityGrowthWithinNarrowBoard() {
        var app = launch(scenario: "long-label", language: "de")
        let standard = app.buttons["long-target"].frame
        XCTAssertGreaterThanOrEqual(standard.height, 44)
        app.terminate()
        app = launch(scenario: "long-label", size: "accessibility2", language: "de")
        let target = app.buttons["long-target"]
        let accessible = target.frame
        XCTAssertGreaterThan(accessible.height, standard.height + 20)
        XCTAssertGreaterThanOrEqual(accessible.width, 44)
        XCTAssertLessThanOrEqual(accessible.width, 272.5)
        assertFullLabel("Auswahl bestätigen und alle Änderungen speichern", inside: target, app: app)
        XCTAssertTrue(String(describing: app.staticTexts["shape-safety"].value).contains("capsule-control=outside"),
                      "The regression fixture must exercise text bounds that the former capsule could not contain.")
        print("Idle shape geometry: \(app.staticTexts["shape-safety"].value ?? "missing")")
        capture("button-accessibility-narrow", app: app)
        app.buttons["toggle-loading"].tap()
        XCTAssertEqual(target.frame.width, accessible.width, accuracy: 0.5)
        XCTAssertEqual(target.frame.height, accessible.height, accuracy: 0.5)
        assertFullLabel("Auswahl vorbereiten und alle Änderungen speichern…", inside: target, app: app)
        print("Loading shape geometry: \(app.staticTexts["shape-safety"].value ?? "missing")")
        print("iOS localized layout: standard=\(standard), accessibility2=\(accessible), loading=\(target.frame)")
    }

    func testVisualMatrixOceanLight() { matrix(brand: "ocean", mode: "light") }
    func testVisualMatrixOceanDark() { matrix(brand: "ocean", mode: "dark") }
    func testVisualMatrixGraphiteLight() { matrix(brand: "graphite", mode: "light") }
    func testVisualMatrixGraphiteDark() { matrix(brand: "graphite", mode: "dark") }

    func testSpecimenBlueLightGlass() { specimen(brand: "strata-blue", mode: "light", surface: "glass") }
    func testSpecimenBlueLightSolid() { specimen(brand: "strata-blue", mode: "light", surface: "solid") }
    func testSpecimenBlueDarkGlass() { specimen(brand: "strata-blue", mode: "dark", surface: "glass") }
    func testSpecimenBlueDarkSolid() { specimen(brand: "strata-blue", mode: "dark", surface: "solid") }
    func testSpecimenGreenLightGlass() { specimen(brand: "strata-green", mode: "light", surface: "glass") }
    func testSpecimenGreenLightSolid() { specimen(brand: "strata-green", mode: "light", surface: "solid") }
    func testSpecimenGreenDarkGlass() { specimen(brand: "strata-green", mode: "dark", surface: "glass") }
    func testSpecimenGreenDarkSolid() { specimen(brand: "strata-green", mode: "dark", surface: "solid") }
    func testSpecimenPinkLightGlass() { specimen(brand: "strata-pink", mode: "light", surface: "glass") }
    func testSpecimenPinkLightSolid() { specimen(brand: "strata-pink", mode: "light", surface: "solid") }
    func testSpecimenPinkDarkGlass() { specimen(brand: "strata-pink", mode: "dark", surface: "glass") }
    func testSpecimenPinkDarkSolid() { specimen(brand: "strata-pink", mode: "dark", surface: "solid") }
    func testSpecimenYellowLightGlass() { specimen(brand: "strata-yellow", mode: "light", surface: "glass") }
    func testSpecimenYellowLightSolid() { specimen(brand: "strata-yellow", mode: "light", surface: "solid") }
    func testSpecimenYellowDarkGlass() { specimen(brand: "strata-yellow", mode: "dark", surface: "glass") }
    func testSpecimenYellowDarkSolid() { specimen(brand: "strata-yellow", mode: "dark", surface: "solid") }
    func testSpecimenPurpleLightGlass() { specimen(brand: "strata-purple", mode: "light", surface: "glass") }
    func testSpecimenPurpleLightSolid() { specimen(brand: "strata-purple", mode: "light", surface: "solid") }
    func testSpecimenPurpleDarkGlass() { specimen(brand: "strata-purple", mode: "dark", surface: "glass") }
    func testSpecimenPurpleDarkSolid() { specimen(brand: "strata-purple", mode: "dark", surface: "solid") }

    func testReduceMotionLoadingRetainsReadableStateAndFootprint() {
        withSystemPreference(section: "Motion", name: "Reduce Motion") {
            let app = launch(scenario: "interaction")
            XCTAssertEqual(app.staticTexts["motion-preference"].label, "Motion: reduced")
            let target = app.buttons["action-target"]
            let idle = target.frame
            app.buttons["toggle-loading"].tap()
            XCTAssertTrue(target.label.contains("Saving all your changes…"))
            XCTAssertFalse(target.isEnabled)
            XCTAssertEqual(target.frame.width, idle.width, accuracy: 0.5)
            XCTAssertEqual(target.frame.height, idle.height, accuracy: 0.5)
            capture("button-reduce-motion-loading", app: app)
            app.terminate()
        }
    }

    func testRealReduceTransparencyFallbackRetainsThemeAndGeometry() {
        var frames: [String: CGRect] = [:]
        let baseline = launch(scenario: "specimen", brand: "strata-purple", mode: "dark")
        for id in ["save", "secondary", "ghost", "disabled", "loading"] {
            frames[id] = baseline.buttons["specimen-\(id)"].frame
        }
        baseline.terminate()
        withSystemPreference(section: "Display & Text Size", name: "Reduce Transparency") {
            let app = launch(scenario: "specimen", brand: "strata-purple", mode: "dark")
            XCTAssertTrue(String(describing: app.scrollViews["review-scroll"].value).contains("reduce-transparency=true"))
            for (id, frame) in frames {
                let actual = app.buttons["specimen-\(id)"].frame
                XCTAssertEqual(actual.minX, frame.minX, accuracy: 0.5)
                XCTAssertEqual(actual.minY, frame.minY, accuracy: 0.5)
                XCTAssertEqual(actual.width, frame.width, accuracy: 0.5)
                XCTAssertEqual(actual.height, frame.height, accuracy: 0.5)
            }
            capture("button-strata-purple-dark-reduced-transparency", app: app)
            app.terminate()
        }
    }

    func testInvalidBrandShowsErrorWithoutFallback() {
        let app = launch(scenario: "matrix", brand: "__unknown_brand__", expectsError: true)
        XCTAssertTrue(app.staticTexts["fixture-error"].label.contains("__unknown_brand__"))
        XCTAssertFalse(app.buttons["matrix-primary-normal"].exists)
    }

    private func specimen(brand: String, mode: String, surface: String) {
        let app = launch(scenario: "specimen", brand: brand, mode: mode, surface: surface)
        let scale = screenshotScale(app)
        for id in ["save", "secondary", "ghost", "disabled", "loading"] {
            let target = app.buttons["specimen-\(id)"]
            XCTAssertTrue(target.exists)
            XCTAssertEqual(target.isEnabled, id != "disabled" && id != "loading")
            assertMinimumTarget(target, scale: scale)
            XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(target.frame), id)
            let expected = ["save": "Save", "secondary": "Secondary", "ghost": "Ghost",
                            "disabled": "Disabled", "loading": "Loading"][id]!
            XCTAssertEqual(target.label, expected)
            let label = target.staticTexts[expected]
            XCTAssertTrue(label.exists)
            XCTAssertTrue(target.frame.insetBy(dx: -0.5, dy: -0.5).contains(label.frame))
        }
        let name = "button-\(brand)-\(mode)-\(surface)"
        recordCompositeGeometry(name: name, brand: brand, mode: mode, app: app)
        capture(name, app: app)
        app.buttons["specimen-save"].tap()
        XCTAssertTrue(app.staticTexts["specimen-feedback"].label.contains("Example saved · 1"))
        for id in ["disabled", "loading"] {
            app.buttons["specimen-\(id)"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
        XCTAssertTrue(app.staticTexts["specimen-feedback"].label.contains("Example saved · 1"))
    }

    private func recordCompositeGeometry(name: String, brand: String, mode: String, app: XCUIApplication) {
        func rectangle(_ frame: CGRect) -> [Double] {
            [Double(frame.minX), Double(frame.minY), Double(frame.width), Double(frame.height)]
        }
        var samples: [[String: Any]] = []
        for (id, label, token) in [
            ("save", "Save", "brand.\(brand).on-accent"),
            ("secondary", "Secondary", "product.strata.text.primary"),
            ("ghost", "Ghost", "brand.\(brand).text"),
            ("disabled", "Disabled", "product.strata.text.secondary"),
            ("loading", "Loading", "brand.\(brand).on-accent")
        ] {
            let control = app.buttons["specimen-\(id)"]
            samples.append(["role": id, "token": token, "text": rectangle(control.staticTexts[label].frame),
                            "control": rectangle(control.frame)])
        }
        for (id, token) in [("specimen-state-label", "product.strata.text.secondary"),
                            ("specimen-caption", "product.strata.text.secondary"),
                            ("specimen-feedback", "product.strata.text.secondary")] {
            samples.append(["role": id, "token": token, "text": rectangle(app.staticTexts[id].frame)])
        }
        for title in ["Strata · 岩层", "01  Button"] {
            samples.append(["role": title, "token": "product.strata.text.primary",
                            "text": rectangle(app.staticTexts[title].frame)])
        }
        let receipt: [String: Any] = ["name": name, "mode": mode, "viewport": rectangle(app.frame), "samples": samples]
        do {
            let data = try JSONSerialization.data(withJSONObject: receipt, options: [.sortedKeys])
            print("BUTTON_COMPOSITE " + String(decoding: data, as: UTF8.self))
        } catch { XCTFail("Could not serialize observed runtime text bounds: \(error)") }
    }

    private func matrix(brand: String, mode: String) {
        let app = launch(scenario: "matrix", brand: brand, mode: mode)
        let scale = screenshotScale(app)
        for variant in ["primary", "secondary", "ghost"] {
            for state in ["normal", "loading", "disabled"] {
                let button = app.buttons["matrix-\(variant)-\(state)"]
                XCTAssertTrue(button.exists)
                XCTAssertEqual(button.isEnabled, state == "normal")
                assertMinimumTarget(button, scale: scale)
                XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(button.frame),
                              "Every matrix button must be fully onscreen before capture: \(variant)/\(state)")
            }
        }
        XCTAssertTrue(app.frame.contains(app.staticTexts["matrix-end"].frame))
        capture("button-\(brand)-\(mode)", app: app)
    }

    private func screenshotScale(_ app: XCUIApplication) -> CGFloat {
        // PNG IHDR width gives physical pixels without importing a UI framework.
        let png = [UInt8](app.screenshot().pngRepresentation)
        let pixels = png[16..<20].reduce(0) { ($0 << 8) | Int($1) }
        return CGFloat(pixels) / app.frame.width
    }

    private func assertMinimumTarget(_ button: XCUIElement, scale: CGFloat) {
        // AX uses floating point edges (e.g. a 44 pt height can be 43.999969).
        // Measure the rendered pixel edges; the minimum remains exactly 44 pt.
        let frame = button.frame
        let width = (frame.maxX * scale).rounded() - (frame.minX * scale).rounded()
        let height = (frame.maxY * scale).rounded() - (frame.minY * scale).rounded()
        XCTAssertGreaterThanOrEqual(width, (44 * scale).rounded(.up))
        XCTAssertGreaterThanOrEqual(height, (44 * scale).rounded(.up))
    }

    private func assertFullLabel(_ text: String, inside button: XCUIElement, app: XCUIApplication) {
        XCTAssertEqual(button.label, text)
        let label = button.staticTexts[text]
        XCTAssertTrue(label.exists, "The active localized text must be accessible.")
        XCTAssertTrue(button.frame.insetBy(dx: -0.5, dy: -0.5).contains(label.frame),
                      "The full text frame must stay within the button.")
        XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(button.frame))
        XCTAssertTrue(button.isHittable)
        XCTAssertEqual(app.staticTexts["shape-safety"].label, "Text bounds: inside",
                       "Measured Text corners must be inside the production fill path, not only its rectangle. " +
                       String(describing: app.staticTexts["shape-safety"].value))
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    /// Changes and restores the simulator's actual setting through its native UI.
    private func withSystemPreference(section: String, name: String, body: () -> Void) {
        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        settings.launch()
        let accessibility = settings.staticTexts["Accessibility"]
        for _ in 0..<8 {
            if accessibility.isHittable { break }
            settings.swipeUp()
        }
        guard accessibility.isHittable else { XCTFail("Settings Accessibility entry unavailable"); return }
        accessibility.tap()
        let sectionEntry = settings.staticTexts[section]
        for _ in 0..<5 {
            if sectionEntry.isHittable { break }
            settings.swipeUp()
        }
        guard sectionEntry.isHittable else { XCTFail("Settings section unavailable: \(section)"); return }
        sectionEntry.tap()
        let toggle = settings.switches[name]
        guard toggle.waitForExistence(timeout: 5) else { XCTFail("System setting unavailable: \(name)"); return }
        let original = String(describing: toggle.value)
        if (toggle.value as? String) != "1" { toggle.tap() }
        XCTAssertEqual(toggle.value as? String, "1")
        defer {
            settings.activate()
            if String(describing: toggle.value) != original { toggle.tap() }
            XCTAssertEqual(String(describing: toggle.value), original, "Restore the prior simulator preference.")
            settings.terminate()
        }
        body()
    }

    private func launch(scenario: String, brand: String = "strata-blue", mode: String = "light", surface: String = "glass",
                        size: String = "large", language: String = "en", expectsError: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment = ["NDK_SCENARIO": scenario, "NDK_BRAND": brand, "NDK_THEME": mode,
                                 "NDK_TEXT_SIZE": size, "NDK_LANGUAGE": language, "NDK_SURFACE": surface]
        app.launch()
        let ready = expectsError ? app.staticTexts["fixture-error"] : app.scrollViews["review-scroll"]
        XCTAssertTrue(ready.waitForExistence(timeout: 10), app.debugDescription)
        return app
    }
}
