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

    func testClippingMatchesCircularReferenceIncludingOutsideBounds() throws {
        let app = launch(scenario: "clipping")
        let actual = app.otherElements["clipping-actual"]
        let reference = app.otherElements["clipping-reference"]
        XCTAssertTrue(actual.exists, app.debugDescription)
        XCTAssertTrue(reference.exists, app.debugDescription)
        for target in [actual, reference] {
            assertSize(target, diameter: 88)
            XCTAssertTrue(app.scrollViews["review-scroll"].frame.contains(target.frame))
        }
        // Compare decoded runtime pixels, including corners and exterior canvas.
        let actualShot = actual.screenshot()
        let referenceShot = reference.screenshot()
        let rendered = try ReviewRaster(png: actualShot.pngRepresentation)
        let expected = try ReviewRaster(png: referenceShot.pngRepresentation)
        XCTAssertEqual(rendered.width, expected.width)
        XCTAssertEqual(rendered.height, expected.height)
        guard rendered.width == expected.width, rendered.height == expected.height else { return }
        let scale = CGFloat(rendered.width) / 88
        let radius = 32 * scale
        var unexpectedPixels = 0
        var differentPixels = 0
        var maximumDelta = 0
        for y in 0..<rendered.height {
            for x in 0..<rendered.width {
                let offset = 4 * (y * rendered.width + x)
                let delta = (0..<4).map { abs(Int(rendered.rgba[offset + $0]) - Int(expected.rgba[offset + $0])) }.max()!
                maximumDelta = max(maximumDelta, delta)
                if delta > 0 { differentPixels += 1 }
                let dx = CGFloat(x) + 0.5 - CGFloat(rendered.width) / 2
                let dy = CGFloat(y) + 0.5 - CGFloat(rendered.height) / 2
                let edge = abs((dx * dx + dy * dy).squareRoot() - radius) <= 2
                // Solid interior/exterior must match exactly. Only the two-pixel
                // antialias rim permits a <=3/255 channel difference.
                if delta > (edge ? 3 : 0) { unexpectedPixels += 1 }
            }
        }
        XCTAssertEqual(unexpectedPixels, 0, "Unexpected clipping pixels; max channel delta=\(maximumDelta)")
        let center = 4 * ((rendered.height / 2) * rendered.width + rendered.width / 2)
        XCTAssertNotEqual(Array(rendered.rgba[center..<(center + 4)]), Array(rendered.rgba[0..<4]),
                          "The fixture must exercise a filled circle against a different canvas.")
        print("Avatar clipping raster: \(rendered.width)×\(rendered.height), differing=\(differentPixels), maxDelta=\(maximumDelta), unexpected=\(unexpectedPixels)")
        for (name, shot) in [("actual", actualShot), ("reference", referenceShot)] {
            let attachment = XCTAttachment(screenshot: shot)
            attachment.name = "avatar-clipping-\(name)-crop"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
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

/// XCTest PNG bytes decoded with Foundation only; no native UI/image framework.
private struct ReviewRaster {
    enum DecodeError: Error { case unsupportedPNG, malformedPNG }
    let width: Int
    let height: Int
    let rgba: [UInt8]

    init(png: Data) throws {
        let bytes = [UInt8](png)
        guard bytes.count >= 33, Array(bytes[0..<8]) == [137, 80, 78, 71, 13, 10, 26, 10] else {
            throw DecodeError.malformedPNG
        }
        func word(_ offset: Int) -> Int {
            bytes[offset..<(offset + 4)].reduce(0) { ($0 << 8) | Int($1) }
        }
        width = word(16)
        height = word(20)
        let channels: Int
        switch bytes[25] {
        case 2: channels = 3
        case 6: channels = 4
        default: throw DecodeError.unsupportedPNG
        }
        guard width > 0, height > 0, bytes[24] == 8,
              bytes[26] == 0, bytes[27] == 0, bytes[28] == 0 else {
            throw DecodeError.unsupportedPNG
        }
        var compressed = Data()
        var offset = 8
        while offset + 12 <= bytes.count {
            let length = word(offset)
            guard length <= bytes.count - offset - 12 else { throw DecodeError.malformedPNG }
            let type = String(bytes: bytes[(offset + 4)..<(offset + 8)], encoding: .ascii)
            if type == "IDAT" { compressed.append(contentsOf: bytes[(offset + 8)..<(offset + 8 + length)]) }
            offset += 12 + length
            if type == "IEND" { break }
        }
        let zlib = [UInt8](compressed)
        guard zlib.count >= 6, zlib[0] & 15 == 8, zlib[1] & 32 == 0,
              (Int(zlib[0]) * 256 + Int(zlib[1])) % 31 == 0 else { throw DecodeError.malformedPNG }
        // Foundation's zlib algorithm consumes raw DEFLATE, without PNG's
        // two-byte zlib header and four-byte Adler trailer.
        let data = try (Data(zlib.dropFirst(2).dropLast(4)) as NSData).decompressed(using: .zlib)
        let filtered = [UInt8](data as Data)
        let stride = width * channels
        guard filtered.count == (stride + 1) * height else { throw DecodeError.malformedPNG }
        var decoded = [UInt8](repeating: 0, count: stride * height)
        for y in 0..<height {
            let filter = filtered[y * (stride + 1)]
            guard filter <= 4 else { throw DecodeError.unsupportedPNG }
            for x in 0..<stride {
                let index = y * stride + x
                let left = x >= channels ? decoded[index - channels] : 0
                let up = y > 0 ? decoded[index - stride] : 0
                let corner = y > 0 && x >= channels ? decoded[index - stride - channels] : 0
                let predictor: UInt8
                switch filter {
                case 0: predictor = 0
                case 1: predictor = left
                case 2: predictor = up
                case 3: predictor = UInt8((Int(left) + Int(up)) / 2)
                default:
                    let estimate = Int(left) + Int(up) - Int(corner)
                    let distances = [abs(estimate - Int(left)), abs(estimate - Int(up)), abs(estimate - Int(corner))]
                    predictor = distances[0] <= distances[1] && distances[0] <= distances[2]
                        ? left : (distances[1] <= distances[2] ? up : corner)
                }
                decoded[index] = filtered[y * (stride + 1) + x + 1] &+ predictor
            }
        }
        var pixels = [UInt8]()
        pixels.reserveCapacity(width * height * 4)
        for index in Swift.stride(from: 0, to: decoded.count, by: channels) {
            pixels.append(contentsOf: decoded[index..<(index + 3)])
            pixels.append(channels == 4 ? decoded[index + 3] : 255)
        }
        rgba = pixels
    }
}
