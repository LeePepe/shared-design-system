import XCTest

/// One bounded positive control, separate from the unchanged acceptance suite.
@MainActor
final class ButtonFlatControlIsolationUITests: XCTestCase {
    func testFlatStandardHoverNativeTabFocusAndSpace() {
        executionTimeAllowance = 180
        let app = XCUIApplication()
        app.launchArguments = ["--button-flat-control-isolation"]
        app.launch()
        let observation = app.staticTexts["flat-observation"]
        let sentinel = app.staticTexts["flat-sentinel"]
        let standard = app.buttons["flat-standard"]
        XCTAssertTrue(observation.waitForExistence(timeout: 5), app.debugDescription)
        XCTAssertEqual(app.scrollViews.count, 0, "The positive control must have no scroll container.")
        XCTAssertEqual(app.buttons.count, 1, "Only the ordinary standard Button may be present.")

        func report(_ step: String, capture: Bool = true) {
            let time = ProcessInfo.processInfo.systemUptime
            var value = "t=\(time);step=\(step);state=\(observation.label);" +
                "sentinel-frame=\(sentinel.frame);sentinel-hittable=\(sentinel.isHittable);" +
                "standard-frame=\(standard.frame);standard-hittable=\(standard.isHittable);" +
                "viewport=\(app.frame);events=\(app.staticTexts["flat-events"].label)"
            #if os(iOS)
            value += ";AX-hasFocus=\(standard.hasFocus)"
            #endif
            print("BUTTON_FLAT_OBSERVATION \(value)")
            let text = XCTAttachment(string: value + "\n" + app.debugDescription)
            text.name = "button-flat-\(step)-state-AX"
            text.lifetime = .keepAlways
            add(text)
            if capture {
                let png = XCTAttachment(screenshot: app.screenshot())
                png.name = "button-flat-\(step)"
                png.lifetime = .keepAlways
                add(png)
            }
        }
        func expect(_ fragment: String, _ reason: String) {
            let predicate = NSPredicate { _, _ in observation.label.contains(fragment) }
            let wait = XCTNSPredicateExpectation(predicate: predicate, object: nil)
            XCTAssertEqual(XCTWaiter.wait(for: [wait], timeout: 2), .completed, reason)
        }
        @discardableResult
        func dispatch(_ name: String, _ event: () -> Void) -> TimeInterval {
            let started = ProcessInfo.processInfo.systemUptime
            print("BUTTON_FLAT_DISPATCH begin t=\(started) \(name)")
            event()
            let elapsed = ProcessInfo.processInfo.systemUptime - started
            print("BUTTON_FLAT_DISPATCH end t=\(ProcessInfo.processInfo.systemUptime) elapsed=\(elapsed) \(name)")
            return elapsed
        }
        func stoppedAfterStalledDispatch(_ step: String) {
            XCTFail("Native \(step) exceeded the 20-second dispatch bound; stop this failed experiment without repeating quiescence waits.")
            let png = XCTAttachment(screenshot: app.screenshot())
            png.name = "button-flat-stalled-\(step)"
            png.lifetime = .keepAlways
            add(png)
        }

        XCTAssertTrue(sentinel.isHittable)
        XCTAssertTrue(standard.isHittable)
        XCTAssertTrue(app.frame.contains(sentinel.frame))
        XCTAssertTrue(app.frame.contains(standard.frame))
        XCTAssertTrue(observation.label.contains("actions=0"))
        report("baseline")
        dispatch("free-hover-sentinel") { sentinel.hover() }
        expect("sentinel-inside=true", "Free pointer movement must enter the Text sentinel.")
        expect("sentinel-enter=1;", "The sentinel needs an actual hover-entry callback.")
        report("sentinel")
        dispatch("free-hover-standard-center") {
            standard.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).hover()
        }
        expect("standard-inside=true", "Free pointer movement must enter the ordinary Button.")
        expect("standard-enter=1;", "The Button needs an actual hover-entry callback.")
        expect("sentinel-exit=1;", "Leaving the sentinel must produce an exit callback.")
        report("standard")
        dispatch("free-hover-back-to-sentinel") { sentinel.hover() }
        expect("standard-inside=false", "The Button must observe pointer exit.")
        expect("standard-exit=1;", "The Button needs an actual hover-exit callback.")
        expect("sentinel-enter=2;", "Returning must re-enter the sentinel.")
        XCTAssertTrue(observation.label.contains("actions=0"), "Hover must not dispatch an action.")
        report("sentinel-return")

        // The expectation is test-side only. No FocusState is assigned, and no
        // mouse click, TextField entry, shortcut or FKA setting substitutes.
        let tabTime = dispatch("native-Tab expected-target=standard request-only") { app.typeKey(.tab, modifierFlags: []) }
        guard tabTime < 20 else { stoppedAfterStalledDispatch("Tab"); return }
        expect("observed-label-focus=true", "Native Tab must produce independently observed view focus.")
        #if os(iOS)
        XCTAssertTrue(standard.hasFocus, "Native focus must also be observed in the actual AX tree.")
        #endif
        XCTAssertTrue(observation.label.contains("actions=0"), "Tab must not activate the Button.")
        report("after-native-tab")
        let spaceTime = dispatch("native-Space once") { app.typeKey(" ", modifierFlags: []) }
        guard spaceTime < 20 else { stoppedAfterStalledDispatch("Space"); return }
        expect("actions=1", "One focused Space press must increment the ordinary Button action exactly once.")
        report("after-native-space")
        XCTAssertTrue(observation.label.contains("actions=1"))
    }
}
