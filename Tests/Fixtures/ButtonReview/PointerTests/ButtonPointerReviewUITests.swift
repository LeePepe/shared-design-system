import XCTest

/// Real pointer/keyboard events run on macOS or iPad; iPhone rejects pointer events.
@MainActor
final class ButtonPointerReviewUITests: XCTestCase {
    func testStandardControlsDiagnoseNativeInputDelivery() {
        let app = launch(scenario: "input-diagnostics")
        let observation = app.staticTexts["input-observation"]
        func report(_ step: String) {
            print("BUTTON_INPUT \(step) \(observation.label)")
        }
        app.staticTexts["input-sentinel"].hover()
        report("sentinel-element-hover")
        app.buttons["input-standard"].coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).hover()
        report("standard-coordinate-hover")
        app.buttons["input-native"].hover()
        report("native-element-hover")
        capture("button-input-pointer-diagnostic", app: app)
        app.buttons["input-standard"].click()
        XCTAssertTrue(observation.label.contains("standard=1"), "The standard mouse click must dispatch once.")
        app.staticTexts["input-sentinel"].hover()
        report("sentinel-after-mouse-click")
        if app.buttons["input-focus-probe"].exists {
            app.buttons["input-focus-probe"].click()
            app.typeKey("k", modifierFlags: [])
            report("probe-before-text-field")
            XCTAssertTrue(observation.label.contains("keys=[k]"), "The standard focusable view must receive the key independently of text input.")
        }
        for id in ["standard", "native"] {
            app.buttons["input-focus-\(id)"].click()
            report("requested-\(id)-focus")
            #if os(iOS)
            print("BUTTON_INPUT \(id) hasFocus=\(app.buttons["input-\(id)"].hasFocus)")
            XCTAssertTrue(app.buttons["input-\(id)"].hasFocus, "Observe native focus on the \(id) control, not just a requested binding.")
            #endif
            app.typeKey(" ", modifierFlags: [])
            report("\(id)-space")
            XCTAssertTrue(observation.label.contains(id == "standard" ? "standard=2" : "native=1"), "Space must activate the focused \(id) control.")
        }
        app.textFields["input-field"].click()
        app.typeKey("k", modifierFlags: [])
        XCTAssertEqual(app.textFields["input-field"].value as? String, "k", "A standard field must receive the synthesized key.")
        report("text-field-key")
        app.typeKey(.tab, modifierFlags: [])
        report("tab-from-text-field")
        if app.buttons["input-focus-probe"].exists {
            app.buttons["input-focus-probe"].click()
            report("requested-probe-focus")
            app.typeKey("k", modifierFlags: [])
            app.typeKey(" ", modifierFlags: [])
            report("probe-keys")
        }
        capture("button-input-keyboard-diagnostic", app: app)
        XCTAssertTrue(observation.label.contains("visited=native,sentinel,standard"), "Standard controls and NativeButton must receive actual hover callbacks.")
    }

    func testPointerHoverForEveryVariant() {
        let app = launch(scenario: "specimen")
        capture("button-pointer-idle", app: app)
        app.staticTexts["specimen-caption"].hover()
        print("BUTTON_POINTER_SENTINEL \(String(describing: app.scrollViews["review-scroll"].value))")
        for id in ["save", "secondary", "ghost"] {
            let button = app.buttons["specimen-\(id)"]
            XCTAssertTrue(button.isEnabled)
            print("BUTTON_POINTER_READY \(id)")
            button.hover()
            let observed = String(describing: app.scrollViews["review-scroll"].value)
            print("BUTTON_POINTER_OBSERVED \(observed)")
            XCTAssertTrue(observed.contains("specimen-\(id)"), "The real pointer must reach SwiftUI, not merely accept an XCTest event.")
            let frame = button.frame
            print("BUTTON_POINTER \(id) control=\(frame) viewport=\(app.frame)")
            capture("button-pointer-hover-\(id)", app: app)
        }
    }

    func testCallerKeyboardShortcutHonorsDisabledAndLoading() {
        let app = launch(scenario: "interaction")
        app.typeKey("s", modifierFlags: .command)
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 1")
        app.typeKey(.tab, modifierFlags: [])
        capture("button-keyboard-navigation", app: app)
        app.buttons["toggle-disabled"].click()
        app.typeKey("s", modifierFlags: .command)
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 1")
        app.buttons["toggle-disabled"].click()
        app.buttons["toggle-loading"].click()
        app.typeKey("s", modifierFlags: .command)
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 1")
        app.buttons["toggle-loading"].click()
        app.typeKey("s", modifierFlags: .command)
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 2")
    }

    #if os(iOS)
    func testFullKeyboardAccessFocusAndSpaceActivation() {
        let settings = XCUIApplication(bundleIdentifier: "com.apple.Preferences")
        settings.launch()
        for _ in 0..<6 {
            let bar = settings.navigationBars.firstMatch
            if ["Settings", "设置"].contains(bar.identifier) { break }
            guard bar.buttons.firstMatch.exists else { break }
            bar.buttons.firstMatch.tap()
        }
        func open(_ labels: [String]) -> Bool {
            let entry = settings.staticTexts.matching(NSPredicate(format: "label IN %@", labels)).firstMatch
            for _ in 0..<8 {
                if entry.isHittable { break }
                settings.swipeUp()
            }
            guard entry.isHittable else { XCTFail(settings.debugDescription); return false }
            entry.tap()
            return true
        }
        guard open(["Accessibility", "辅助功能", "无障碍"]),
              open(["Keyboards & Typing", "Keyboards", "键盘与键入", "键盘"]),
              open(["Full Keyboard Access", "全键盘控制"]) else { return }
        let toggle = settings.switches.matching(NSPredicate(format: "label IN %@", ["Full Keyboard Access", "全键盘控制"])).firstMatch
        guard toggle.waitForExistence(timeout: 5), let original = toggle.value as? String else {
            XCTFail(settings.debugDescription)
            return
        }
        XCTAssertEqual(original, "1", "This input lane requires Full Keyboard Access to be enabled before the run; tests never change Settings.")
        defer {
            settings.activate()
            XCTAssertEqual(toggle.value as? String, original, "The native keyboard preference must remain unchanged.")
            settings.terminate()
        }
        let app = launch(scenario: "interaction")
        let button = app.buttons["action-target"]
        for _ in 0..<8 {
            if button.hasFocus { break }
            app.typeKey(.tab, modifierFlags: [])
        }
        capture("button-full-keyboard-focus", app: app)
        XCTAssertTrue(button.hasFocus, "A real keyboard focus target must be observed.")
        app.typeKey(" ", modifierFlags: [])
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 1")
    }

    #endif

    private func launch(scenario: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment = ["NDK_SCENARIO": scenario, "NDK_BRAND": "strata-blue", "NDK_THEME": "light",
                                 "NDK_TEXT_SIZE": "large", "NDK_LANGUAGE": "en", "NDK_SURFACE": "glass"]
        app.launch()
        XCTAssertTrue(app.scrollViews["review-scroll"].waitForExistence(timeout: 10), app.debugDescription)
        return app
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
