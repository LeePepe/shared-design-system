import XCTest

@MainActor
final class TextFieldReviewUITests: XCTestCase {
    func testPaddedEdgesFocusTheRealEditor() throws {
        // These points are in the visible padding, outside native text glyphs.
        for edge in ["leading", "trailing", "top", "bottom"] {
            let app = launch(scenario: "interaction")
            let geometry = try geometry("active", app: app)
            assertMinimumTarget(geometry.surface)
            XCTAssertFalse(app.keyboards.firstMatch.exists)
            let point: CGPoint
            switch edge {
            case "leading": point = CGPoint(x: geometry.surface.minX + 2, y: geometry.surface.midY)
            case "trailing": point = CGPoint(x: geometry.surface.maxX - 2, y: geometry.surface.midY)
            case "top": point = CGPoint(x: geometry.surface.midX, y: geometry.surface.minY + 2)
            default: point = CGPoint(x: geometry.surface.midX, y: geometry.surface.maxY - 2)
            }
            tap(point, app: app)
            XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5), "Padding edge: \(edge)")
            app.typeText("X")
            XCTAssertTrue(app.staticTexts["caller-value"].label.contains("X"),
                          "A padding tap must focus the actual bound native editor: \(edge)")
            app.terminate()
        }
    }

    func testStrataEditingPreservesCallerBindingAndSubmits() throws {
        let app = launch(scenario: "interaction")
        let field = input("active-input", app: app)
        XCTAssertEqual(field.value as? String, "Initial value")
        XCTAssertEqual(field.label, "Display name")
        let surface = try geometry("active", app: app).surface
        tap(CGPoint(x: surface.maxX - 2, y: surface.midY), app: app)
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        field.typeText("  Caller text  ")
        XCTAssertEqual(app.staticTexts["caller-value"].label, "Initial value  Caller text  ")
        XCTAssertEqual(field.value as? String, "Initial value  Caller text  ")
        XCTAssertNotEqual(app.staticTexts["edit-count"].label, "Edits: 0")
        XCTAssertEqual(app.staticTexts["submit-count"].label, "Submissions: 0")
        capture("textfield-focused", app: app)
        app.keyboards.buttons["Done"].tap()
        XCTAssertEqual(app.staticTexts["submit-count"].label, "Submissions: 1")
        XCTAssertEqual(app.staticTexts["caller-value"].label, "Initial value  Caller text  ")
    }

    func testStrataSelectionCanReplaceInputWithoutPaddingGestureInterference() throws {
        let app = launch(scenario: "interaction")
        let field = input("active-input", app: app)
        let surface = try geometry("active", app: app).surface
        // Hit the text's own line, not an AX container that may include its label.
        let editorPoint = app.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: surface.minX + 35, dy: surface.midY))
        editorPoint.tap()
        editorPoint.press(forDuration: 1.2)
        let selectAll = app.menuItems["Select All"].firstMatch
        let selectAllButton = app.buttons["Select All"].firstMatch
        XCTAssertTrue(selectAll.waitForExistence(timeout: 3) || selectAllButton.waitForExistence(timeout: 3),
                      "The real editor must retain its native selection menu. \(app.debugDescription)")
        if selectAll.exists { selectAll.tap() } else { selectAllButton.tap() }
        field.typeText("  Replaced by caller  ")
        XCTAssertEqual(app.staticTexts["caller-value"].label, "  Replaced by caller  ")
        XCTAssertEqual(field.value as? String, "  Replaced by caller  ")
    }

    func testDisabledCoordinateTapsCannotFocusOrEdit() throws {
        let app = launch(scenario: "interaction")
        let field = input("disabled-input", app: app)
        XCTAssertFalse(field.isEnabled)
        let surface = try geometry("disabled", app: app).surface
        assertMinimumTarget(surface)
        for point in [CGPoint(x: surface.minX + 2, y: surface.midY),
                      CGPoint(x: surface.maxX - 2, y: surface.midY),
                      CGPoint(x: surface.midX, y: surface.minY + 2),
                      CGPoint(x: surface.midX, y: surface.maxY - 2),
                      CGPoint(x: surface.midX, y: surface.midY)] {
            tap(point, app: app)
            XCTAssertFalse(app.keyboards.firstMatch.exists)
        }
        XCTAssertEqual(field.value as? String, "Unavailable")
        XCTAssertEqual(app.staticTexts["disabled-value"].label, "Unavailable")
        // A disabled coordinate tap must not steal focus from a live editor.
        input("active-input", app: app).tap()
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5))
        tap(CGPoint(x: surface.midX, y: surface.midY), app: app)
        app.typeText("X")
        XCTAssertTrue(app.staticTexts["caller-value"].label.contains("X"))
        XCTAssertEqual(app.staticTexts["disabled-value"].label, "Unavailable")
        XCTAssertEqual(field.value as? String, "Unavailable")
    }

    func testLongNarrowAccessibleLabelAndEditorGrowWithoutClipping() throws {
        var app = launch(scenario: "long-label")
        let standard = try geometry("long", app: app)
        let standardEditorHeight = input("long-input", app: app).frame.height
        app.terminate()
        app = launch(scenario: "long-label", size: "accessibility2")
        let measured = try geometry("long", app: app)
        let field = input("long-input", app: app)
        XCTAssertEqual(field.label, "Vollständiger Anzeigename für die gemeinsame Zusammenarbeit")
        XCTAssertEqual(field.value as? String, "Notiz")
        XCTAssertTrue(field.isHittable)
        XCTAssertGreaterThan(measured.label.height, standard.label.height + 20)
        XCTAssertGreaterThan(measured.surface.height, standard.surface.height + 10)
        XCTAssertGreaterThan(field.frame.height, standardEditorHeight + 10)
        assertMinimumTarget(measured.surface)
        XCTAssertEqual(measured.board.width, 320, accuracy: 0.001)
        XCTAssertLessThanOrEqual(measured.component.width, 288.001)
        XCTAssertTrue(measured.component.insetBy(dx: -0.001, dy: -0.001).contains(measured.label))
        XCTAssertTrue(measured.board.insetBy(dx: -0.001, dy: -0.001).contains(measured.component))
        XCTAssertEqual(measured.surface.minY - measured.label.maxY, 8, accuracy: 0.001)
        XCTAssertTrue(measured.surface.insetBy(dx: -0.5, dy: -0.5).contains(field.frame))
        XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(measured.component))
        XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(app.staticTexts["long-end"].frame))
        print("TextField narrow geometry: standard=\(standard), accessibility2=\(measured); native editor=\(field.frame)")
        capture("textfield-accessibility-narrow", app: app)
    }

    func testVisualMatrixOceanLight() { matrix(brand: "ocean", mode: "light") }
    func testVisualMatrixOceanDark() { matrix(brand: "ocean", mode: "dark") }
    func testVisualMatrixGraphiteLight() { matrix(brand: "graphite", mode: "light") }
    func testVisualMatrixGraphiteDark() { matrix(brand: "graphite", mode: "dark") }

    private func matrix(brand: String, mode: String) {
        let app = launch(scenario: "matrix", brand: brand, mode: mode)
        let viewport = app.scrollViews["review-scroll"].frame
        for state in ["populated", "empty", "disabled", "validation"] {
            let field = input("matrix-\(state)", app: app)
            XCTAssertTrue(field.exists)
            XCTAssertEqual(field.isEnabled, state != "disabled")
            assertMinimumTarget(field.frame)
            XCTAssertTrue(viewport.contains(field.frame), "Entire \(state) input must be visible.")
        }
        XCTAssertEqual(input("matrix-populated", app: app).label, "Display name")
        XCTAssertEqual(input("matrix-empty", app: app).label, "A longer label that can wrap at narrow widths")
        XCTAssertEqual(input("matrix-disabled", app: app).label, "Unavailable field")
        XCTAssertEqual(input("matrix-validation", app: app).label, "Email address")
        XCTAssertEqual(input("matrix-empty", app: app).value as? String, "Enter a short note")
        XCTAssertTrue(viewport.contains(app.staticTexts["caller-validation"].frame))
        XCTAssertTrue(viewport.contains(app.staticTexts["matrix-end"].frame))
        capture("textfield-\(brand)-\(mode)", app: app)
    }

    private struct Geometry {
        let label: CGRect
        let surface: CGRect
        let component: CGRect
        let board: CGRect
    }

    private func input(_ identifier: String, app: XCUIApplication) -> XCUIElement {
        // A containing accessibility group can own the fixture identifier;
        // assertions still target its real TextField descendant.
        let field = app.textFields[identifier]
        if field.exists { return field }
        return app.otherElements[identifier].textFields.firstMatch
    }

    private func geometry(_ prefix: String, app: XCUIApplication) throws -> Geometry {
        let element = app.staticTexts["\(prefix)-geometry"]
        XCTAssertTrue(NSPredicate(format: "value != %@", "pending").evaluate(with: element))
        let string = try XCTUnwrap(element.value as? String)
        let rectangles = string.split(separator: "|").compactMap { rectangle -> CGRect? in
            let numbers = rectangle.split(separator: ",").compactMap { Double($0) }
            guard numbers.count == 4 else { return nil }
            return CGRect(x: numbers[0], y: numbers[1], width: numbers[2], height: numbers[3])
        }
        XCTAssertEqual(rectangles.count, 4, string)
        guard rectangles.count == 4 else { throw NSError(domain: "Invalid SwiftUI geometry", code: 1) }
        return Geometry(label: rectangles[0], surface: rectangles[1], component: rectangles[2], board: rectangles[3])
    }

    private func assertMinimumTarget(_ rect: CGRect, file: StaticString = #filePath, line: UInt = #line) {
        // Round only subpixel AX arithmetic noise; 43.999969 pt is 44 pt.
        XCTAssertGreaterThanOrEqual((rect.width * 1000).rounded() / 1000, 44, file: file, line: line)
        XCTAssertGreaterThanOrEqual((rect.height * 1000).rounded() / 1000, 44, file: file, line: line)
    }

    private func tap(_ point: CGPoint, app: XCUIApplication) {
        app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: point.x, dy: point.y)).tap()
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func launch(scenario: String, brand: String = "ocean", mode: String = "light",
                        size: String = "large") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launchEnvironment = ["NDK_SCENARIO": scenario, "NDK_BRAND": brand,
                                 "NDK_THEME": mode, "NDK_TEXT_SIZE": size]
        app.launch()
        XCTAssertTrue(app.scrollViews["review-scroll"].waitForExistence(timeout: 10), app.debugDescription)
        return app
    }
}
