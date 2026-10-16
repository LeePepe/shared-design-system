import XCTest

/// Real pointer/keyboard events run on macOS or iPad; iPhone rejects pointer events.
@MainActor
final class ButtonPointerReviewUITests: XCTestCase {
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
        setSwitch(toggle, value: "1")
        defer {
            settings.activate()
            setSwitch(toggle, value: original)
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

    private func setSwitch(_ toggle: XCUIElement, value: String) {
        for _ in 0..<3 {
            if (toggle.value as? String) == value { return }
            // iPad exposes the whole labelled row as a Switch. Its actual knob
            // occupies the trailing 63 pt, so a percentage can miss it.
            toggle.coordinate(withNormalizedOffset: CGVector(dx: 1, dy: 0.5))
                .withOffset(CGVector(dx: -20, dy: 0)).tap()
            let changed = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", value), object: toggle)
            if XCTWaiter.wait(for: [changed], timeout: 3) == .completed { return }
        }
        XCTAssertEqual(toggle.value as? String, value, "Restore the actual simulator keyboard preference.")
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
