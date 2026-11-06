import XCTest

final class SnackbarReviewUITests: XCTestCase {
    private var measured: [String: [String: [String: CGFloat]]] = [:]

    func testSnackbarStateMatrixAndGeometry() throws {
        let launches = [
            ("strata-blue", "light", "snackbar-blue-light"),
            ("strata-blue", "dark", "snackbar-blue-dark"),
            ("strata-purple", "light", "snackbar-purple-light"),
            ("strata-purple", "dark", "snackbar-purple-dark")
        ]
        for (brand, mode, name) in launches {
            let app = launch(brand: brand, mode: mode)
            XCTAssertTrue(app.staticTexts["Set deleted"].waitForExistence(timeout: 10))
            assertMinimumTargets(app)
            assertNoBottomBarOverlap(app)
            capture(name, app: app)
            record(name, app: app)
            app.buttons.element(boundBy: 0).tap()
            XCTAssertTrue(app.staticTexts["Result: action"].waitForExistence(timeout: 2))
            XCTAssertTrue(app.staticTexts["Undo available"].exists)
            assertMinimumTarget(app.buttons.element(boundBy: 0))
            capture(name + "-message-only", app: app)
            record(name + "-message-only", app: app)
            app.buttons.element(boundBy: 0).tap()
            XCTAssertTrue(app.staticTexts["Result: close"].waitForExistence(timeout: 2))
            app.terminate()
        }

        for mode in ["light", "dark"] {
            let app = launch(brand: "strata-blue", mode: mode, scenario: "long")
            let message = app.staticTexts["已删除 16.81 / 24.00 GB：可在 5 秒内撤销 (Deleted 16.81 / 24.00 GB)"]
            XCTAssertTrue(message.waitForExistence(timeout: 10))
            XCTAssertFalse(message.label.contains("…"))
            assertMinimumTargets(app, actionLabel: "撤销删除", closeLabel: "关闭")
            XCTAssertGreaterThan(message.frame.height, 24)
            let name = "snackbar-blue-\(mode)-long"
            capture(name, app: app)
            record(name, app: app)
            app.terminate()
        }

        let reduced = launch(brand: "strata-blue", mode: "light", scenario: "reduce_motion")
        XCTAssertTrue(reduced.staticTexts["Set deleted"].waitForExistence(timeout: 10))
        assertMinimumTargets(reduced)
        capture("snackbar-blue-light-reduce-motion", app: reduced)
        record("snackbar-blue-light-reduce-motion", app: reduced)
        button(reduced, label: "Dismiss").tap()
        XCTAssertTrue(reduced.staticTexts["Result: close"].waitForExistence(timeout: 2))
        reduced.terminate()

        let data = try JSONSerialization.data(withJSONObject: measured, options: [.prettyPrinted, .sortedKeys])
        let attachment = XCTAttachment(data: data, uniformTypeIdentifier: "public.json")
        attachment.name = "geometry.json"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func launch(brand: String, mode: String, scenario: String = "default") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment = ["NDK_BRAND": brand, "NDK_THEME": mode, "NDK_SCENARIO": scenario]
        if scenario == "reduce_motion" {
            app.launchEnvironment["UIAccessibilityReduceMotionEnabled"] = "1"
        }
        app.launch()
        XCTAssertTrue(app.staticTexts["Snackbar review"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.staticTexts["Bottom bar coordination"].exists)
        return app
    }

    private func assertMinimumTargets(_ app: XCUIApplication, actionLabel: String = "Undo", closeLabel: String = "Dismiss") {
        assertMinimumTarget(app.buttons.element(boundBy: 0))
        assertMinimumTarget(app.buttons.element(boundBy: 1))
        XCTAssertGreaterThanOrEqual(app.otherElements["strata-snackbar"].frame.height, 44)
    }

    private func assertMinimumTarget(_ element: XCUIElement) {
        XCTAssertGreaterThanOrEqual(element.frame.width, 44)
        XCTAssertGreaterThanOrEqual(element.frame.height, 44)
    }

    private func button(_ app: XCUIApplication, label: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label == %@", label)).firstMatch
    }

    private func assertNoBottomBarOverlap(_ app: XCUIApplication) {
        let snackbar = app.otherElements["strata-snackbar"].frame
        let bottomBar = app.staticTexts["Bottom bar coordination"].frame
        XCTAssertLessThanOrEqual(snackbar.maxY, bottomBar.minY)
    }

    private func record(_ name: String, app: XCUIApplication) {
        func rect(_ element: XCUIElement) -> [String: CGFloat] {
            let frame = element.frame
            return ["x": frame.origin.x, "y": frame.origin.y, "width": frame.width, "height": frame.height]
        }
        let snackbar = app.otherElements["strata-snackbar"].frame
        let message = app.staticTexts["strata-snackbar-message"].frame
        let bottomBar = app.staticTexts["Bottom bar coordination"].frame
        let hasAction = app.buttons.count > 1
        let zero = ["x": 0, "y": 0, "width": 0, "height": 0] as [String: CGFloat]
        measured[name] = [
            "snackbar": ["x": snackbar.minX, "y": snackbar.minY, "width": snackbar.width, "height": snackbar.height],
            "message": ["x": message.minX, "y": message.minY, "width": message.width, "height": message.height],
            "action": hasAction ? rect(app.buttons.element(boundBy: 0)) : zero,
            "close": rect(app.buttons.element(boundBy: hasAction ? 1 : 0)),
            "bottomBar": ["x": bottomBar.minX, "y": bottomBar.minY, "width": bottomBar.width, "height": bottomBar.height]
        ]
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
