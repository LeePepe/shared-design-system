import XCTest

@MainActor
final class AvatarReviewUITests: XCTestCase {
    private let sizes: [(String, CGFloat)] = [("small", 32), ("medium", 44), ("large", 64)]

    func testVisualMatrixOceanLight() { matrix(brand: "ocean", mode: "light") }
    func testVisualMatrixOceanDark() { matrix(brand: "ocean", mode: "dark") }
    func testVisualMatrixGraphiteLight() { matrix(brand: "graphite", mode: "light") }
    func testVisualMatrixGraphiteDark() { matrix(brand: "graphite", mode: "dark") }

    func testCallerLabelIsOneImageAndDecorativeDescendantsAreHidden() {
        let app = launch(scenario: "matrix")
        for kind in ["initials", "symbol", "fill", "fit", "empty", "disabled"] {
            for (size, _) in sizes {
                let identifier = "avatar-\(kind)-\(size)"
                XCTAssertEqual(app.images.matching(identifier: identifier).count, 1)
                let image = app.images[identifier]
                XCTAssertEqual(image.elementType, .image)
                XCTAssertEqual(image.descendants(matching: .any).count, 0, image.debugDescription)
                XCTAssertEqual(app.buttons.matching(identifier: identifier).count, 0)
                XCTAssertEqual(image.label, "\(rowTitle(kind)), \(size) example visual")
            }
        }
        for label in ["Redundant initials glyph", "Redundant symbol glyph", "Redundant image glyph", "AB"] {
            XCTAssertFalse(app.descendants(matching: .any).matching(NSPredicate(format: "label == %@", label)).firstMatch.exists)
        }
    }

    func testClippingMatchesCircularReferenceIncludingOutsideBounds() {
        let app = launch(scenario: "clipping")
        let actual = app.otherElements["clipping-actual"]
        let reference = app.otherElements["clipping-reference"]
        XCTAssertTrue(actual.exists, app.debugDescription)
        XCTAssertTrue(reference.exists, app.debugDescription)
        for target in [actual, reference] {
            assertSize(target, diameter: 88)
            XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(target.frame))
        }
        // Actual runtime crops include the circle, corners and exterior canvas.
        XCTAssertEqual(actual.screenshot().pngRepresentation, reference.screenshot().pngRepresentation)
        capture("avatar-clipping", app: app)
    }

    func testNarrowTextGrowsWhileAllAvatarVisualBoundsStayFixed() {
        var app = launch(scenario: "narrow")
        let standard = app.staticTexts["long-label"].frame
        assertScalableSizes(app)
        app.terminate()
        app = launch(scenario: "narrow", mode: "dark", size: "accessibility2")
        let label = app.staticTexts["long-label"]
        let avatar = app.images["narrow-avatar"]
        XCTAssertEqual(label.label, "Example member with a long display name that wraps naturally beside a small avatar.")
        XCTAssertGreaterThan(label.frame.height, standard.height + 20)
        XCTAssertLessThanOrEqual(label.frame.width, 236.5)
        XCTAssertGreaterThanOrEqual(label.frame.minX, avatar.frame.maxX + 11.5)
        XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(label.frame))
        XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(app.staticTexts["narrow-end"].frame))
        assertScalableSizes(app)
        capture("avatar-accessibility-narrow", app: app)
        print("Avatar narrow text: standard=\(standard); accessibility2=\(label.frame)")
        app.terminate()
        app = launch(scenario: "narrow", size: "accessibility5")
        assertScalableSizes(app, requireOnscreen: false)
    }

    func testCallerContentUpdatesAndButtonOwnsActionAndDisabledState() {
        let app = launch(scenario: "composition")
        let avatar = app.images["caller-owned-avatar"]
        let original = avatar.frame
        XCTAssertEqual(avatar.label, "Original example visual")
        avatar.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 0")
        app.buttons["change-content"].tap()
        XCTAssertEqual(avatar.label, "Changed example visual")
        XCTAssertEqual(avatar.frame.width, original.width, accuracy: 0.5)
        XCTAssertEqual(avatar.frame.height, original.height, accuracy: 0.5)
        let button = app.buttons["composed-action"]
        XCTAssertEqual(button.label, "Open example member")
        assertMinimumTarget(button, app: app)
        button.tap()
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 1")
        app.buttons["toggle-disabled"].tap()
        XCTAssertFalse(button.isEnabled)
        for _ in 0..<3 { button.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 1")
        app.buttons["toggle-disabled"].tap()
        button.tap()
        XCTAssertEqual(app.staticTexts["action-count"].label, "Actions: 2")
    }

    private func matrix(brand: String, mode: String) {
        let app = launch(scenario: "matrix", brand: brand, mode: mode)
        for kind in ["initials", "symbol", "fill", "fit", "empty", "disabled"] {
            for (size, diameter) in sizes {
                let avatar = app.images["avatar-\(kind)-\(size)"]
                XCTAssertTrue(avatar.exists, app.debugDescription)
                assertSize(avatar, diameter: diameter)
                XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(avatar.frame))
            }
        }
        XCTAssertTrue(app.frame.contains(app.staticTexts["matrix-end"].frame))
        capture("avatar-\(brand)-\(mode)", app: app)
    }

    private func assertScalableSizes(_ app: XCUIApplication, requireOnscreen: Bool = true) {
        assertSize(app.images["narrow-avatar"], diameter: 32)
        for (size, diameter) in sizes {
            let avatar = app.images["scalable-\(size)"]
            XCTAssertTrue(avatar.exists)
            assertSize(avatar, diameter: diameter)
            XCTAssertEqual(avatar.label, "\(size) scalable visual")
            if requireOnscreen { XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(avatar.frame)) }
        }
    }

    private func assertSize(_ target: XCUIElement, diameter: CGFloat) {
        XCTAssertEqual(target.frame.width, diameter, accuracy: 0.5)
        XCTAssertEqual(target.frame.height, diameter, accuracy: 0.5)
    }

    private func assertMinimumTarget(_ target: XCUIElement, app: XCUIApplication) {
        // Physical pixel edges avoid AX subtraction noise at exactly 44 pt.
        let png = [UInt8](app.screenshot().pngRepresentation)
        let pixels = png[16..<20].reduce(0) { ($0 << 8) | Int($1) }
        let scale = CGFloat(pixels) / app.frame.width
        let frame = target.frame
        let width = (frame.maxX * scale).rounded() - (frame.minX * scale).rounded()
        let height = (frame.maxY * scale).rounded() - (frame.minY * scale).rounded()
        XCTAssertGreaterThanOrEqual(width, (44 * scale).rounded(.up))
        XCTAssertGreaterThanOrEqual(height, (44 * scale).rounded(.up))
    }

    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func launch(scenario: String, brand: String = "ocean", mode: String = "light", size: String = "large") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment = ["NDK_SCENARIO": scenario, "NDK_BRAND": brand,
                                 "NDK_THEME": mode, "NDK_TEXT_SIZE": size]
        app.launch()
        XCTAssertTrue(app.scrollViews["review-scroll"].waitForExistence(timeout: 10), app.debugDescription)
        return app
    }

    private func rowTitle(_ kind: String) -> String {
        switch kind {
        case "initials": "Initials"
        case "symbol": "SF Symbol"
        case "fill": "Local image fill"
        case "fit": "Local image fit"
        case "empty": "Empty visual"
        default: "Disabled env."
        }
    }
}
