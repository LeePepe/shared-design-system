import XCTest

final class SnackbarReviewUITests: XCTestCase {
    private var measured: [String: [String: [String: CGFloat]]] = [:]

    func testSnackbarBoardAndInteraction() throws {
        let launches = [
            ("strata-blue", "light", "snackbar-blue-light"),
            ("strata-blue", "dark", "snackbar-blue-dark"),
            ("strata-purple", "light", "snackbar-purple-light"),
            ("strata-purple", "dark", "snackbar-purple-dark")
        ]
        for (brand, mode, name) in launches {
            let app = launch(brand: brand, mode: mode)
            XCTAssertTrue(app.staticTexts["Snackbar review"].waitForExistence(timeout: 10))
            XCTAssertTrue(app.staticTexts["Set deleted"].exists)
            XCTAssertTrue(app.buttons["Undo"].exists)
            XCTAssertTrue(app.buttons["Close"].exists)
            XCTAssertTrue(app.staticTexts["Bottom bar coordination"].exists)
            assertMinimumTargets(app)
            assertNoBottomBarOverlap(app)
            try record(name, app: app, screenshot: capture(name, app: app), actionLabel: "Undo", closeLabel: "Close")
            app.buttons["Undo"].tap()
            XCTAssertTrue(app.staticTexts["Result: action"].waitForExistence(timeout: 2))
            XCTAssertTrue(app.staticTexts["Undo available"].exists)
            assertMinimumTarget(app.buttons["Close"])
            try record(name + "-message-only", app: app,
                       screenshot: capture(name + "-message-only", app: app), actionLabel: nil, closeLabel: "Close")
            app.buttons["Close"].tap()
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
            try record(name, app: app, screenshot: capture(name, app: app), actionLabel: "撤销删除", closeLabel: "关闭")
            app.terminate()
        }

        let reduced = launch(brand: "strata-blue", mode: "light", scenario: "reduce_motion")
        XCTAssertTrue(reduced.staticTexts["Set deleted"].waitForExistence(timeout: 10))
        assertMinimumTargets(reduced)
        try record("snackbar-blue-light-reduce-motion", app: reduced,
                   screenshot: capture("snackbar-blue-light-reduce-motion", app: reduced),
                   actionLabel: "Undo", closeLabel: "Close")
        reduced.buttons["Close"].tap()
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

    private func assertMinimumTargets(_ app: XCUIApplication, actionLabel: String = "Undo", closeLabel: String = "Close") {
        assertMinimumTarget(app.buttons[actionLabel])
        assertMinimumTarget(app.buttons[closeLabel])
        XCTAssertGreaterThanOrEqual(app.otherElements["strata-snackbar"].frame.height, 44)
    }

    private func assertMinimumTarget(_ element: XCUIElement) {
        XCTAssertTrue(element.exists)
        XCTAssertGreaterThanOrEqual(element.frame.width, 44)
        XCTAssertGreaterThanOrEqual(element.frame.height, 44)
    }

    private func assertNoBottomBarOverlap(_ app: XCUIApplication) {
        let snackbar = app.otherElements["strata-snackbar"].frame
        let bottomBar = app.staticTexts["Bottom bar coordination"].frame
        XCTAssertLessThanOrEqual(snackbar.maxY, bottomBar.minY)
    }

    private func measureVisiblePillFrame(
        for effectiveFrame: CGRect,
        snackbarFrame: CGRect,
        messageFrame: CGRect,
        in screenshot: XCUIScreenshot,
        appFrame: CGRect
    ) throws -> CGRect {
        let cgImage = try XCTUnwrap(screenshot.image.cgImage)
        let data = try XCTUnwrap(cgImage.dataProvider?.data)
        let ptr = try XCTUnwrap(CFDataGetBytePtr(data))
        XCTAssertEqual(cgImage.bitsPerComponent, 8)
        XCTAssertEqual(cgImage.bitsPerPixel, 32)
        guard cgImage.bitsPerComponent == 8, cgImage.bitsPerPixel == 32 else {
            throw MeasurementError.unsupportedPixelFormat
        }
        let scaleX = CGFloat(cgImage.width) / appFrame.width
        let scaleY = CGFloat(cgImage.height) / appFrame.height
        let alphaFirst = [.first, .premultipliedFirst, .noneSkipFirst].contains(cgImage.alphaInfo)
        let littleEndian = cgImage.bitmapInfo.intersection(.byteOrderMask) == .byteOrder32Little
        let colorOffset = alphaFirst == littleEndian ? 0 : 1
        func pixel(_ x: Int, _ y: Int) throws -> [Int] {
            guard (0..<cgImage.width).contains(x), (0..<cgImage.height).contains(y) else {
                XCTFail("Pixel measurement is outside the screenshot: \(x), \(y)")
                throw MeasurementError.outOfBounds
            }
            let offset = y * cgImage.bytesPerRow + x * 4 + colorOffset
            return (0..<3).map { Int(ptr[offset + $0]) }
        }
        let background = try pixel(
            Int((messageFrame.maxX + 8 - appFrame.minX) * scaleX),
            Int((snackbarFrame.minY + 6 - appFrame.minY) * scaleY)
        )
        func differsFromBackground(_ x: Int, _ y: Int) throws -> Bool {
            let value = try pixel(x, y)
            return zip(value, background).map { abs($0 - $1) }.max()! >= 2
        }
        let midX = Int((effectiveFrame.midX - appFrame.minX) * scaleX)
        let midY = Int((effectiveFrame.midY - appFrame.minY) * scaleY)
        let minX = Int(round((effectiveFrame.minX - appFrame.minX) * scaleX)) - 1
        let maxX = Int(round((effectiveFrame.maxX - appFrame.minX) * scaleX))
        let minY = Int(round((effectiveFrame.minY - appFrame.minY) * scaleY)) - 1
        let maxY = Int(round((effectiveFrame.maxY - appFrame.minY) * scaleY))
        let searchX = minX...maxX
        let searchY = minY...maxY
        let horizontal = try searchX.filter { try differsFromBackground($0, midY) }
        let vertical = try searchY.filter { try differsFromBackground(midX, $0) }
        let vx0 = try XCTUnwrap(horizontal.first, "No visible pill on the horizontal scan")
        let vx1 = try XCTUnwrap(horizontal.last)
        let vy0 = try XCTUnwrap(vertical.first, "No visible pill on the vertical scan")
        let vy1 = try XCTUnwrap(vertical.last)
        return CGRect(
            x: CGFloat(vx0) / scaleX + appFrame.minX,
            y: CGFloat(vy0) / scaleY + appFrame.minY,
            width: CGFloat(vx1 - vx0 + 1) / scaleX,
            height: CGFloat(vy1 - vy0 + 1) / scaleY
        )
    }

    private enum MeasurementError: Error {
        case unsupportedPixelFormat
        case outOfBounds
    }

    private func record(
        _ name: String,
        app: XCUIApplication,
        screenshot: XCUIScreenshot,
        actionLabel: String?,
        closeLabel: String
    ) throws {
        func rect(_ frame: CGRect) -> [String: CGFloat] {
            return ["x": frame.origin.x, "y": frame.origin.y, "width": frame.width, "height": frame.height]
        }
        let snackbar = app.otherElements["strata-snackbar"].frame
        let message = app.staticTexts["strata-snackbar-message"].frame
        let bottomBar = app.staticTexts["Bottom bar coordination"].frame
        func control(_ label: String) throws -> [String: CGFloat] {
            let button = app.buttons[label]
            assertMinimumTarget(button)
            let effectiveFrame = button.frame
            let visibleFrame = try measureVisiblePillFrame(
                for: effectiveFrame, snackbarFrame: snackbar, messageFrame: message,
                in: screenshot, appFrame: app.frame
            )
            let deltaX = abs(effectiveFrame.minX - visibleFrame.minX)
            let deltaY = abs(effectiveFrame.minY - visibleFrame.minY)
            let deltaWidth = abs(effectiveFrame.width - visibleFrame.width)
            let deltaHeight = abs(effectiveFrame.height - visibleFrame.height)
            XCTAssertLessThanOrEqual(deltaX, 1.0)
            XCTAssertLessThanOrEqual(deltaY, 1.0)
            XCTAssertLessThanOrEqual(deltaWidth, 1.0)
            XCTAssertLessThanOrEqual(deltaHeight, 1.0)
            var result = rect(effectiveFrame)
            result.merge([
                "visibleX": visibleFrame.minX, "visibleY": visibleFrame.minY,
                "visibleWidth": visibleFrame.width, "visibleHeight": visibleFrame.height,
                "deltaX": deltaX, "deltaY": deltaY, "deltaWidth": deltaWidth, "deltaHeight": deltaHeight,
                "maxParityDelta": max(max(deltaX, deltaY), max(deltaWidth, deltaHeight))
            ]) { _, new in new }
            return result
        }
        measured[name] = [
            "snackbar": rect(snackbar),
            "message": rect(message),
            "action": try actionLabel.map { try control($0) } ?? rect(.zero),
            "close": try control(closeLabel),
            "bottomBar": rect(bottomBar)
        ]
    }

    private func capture(_ name: String, app: XCUIApplication) -> XCUIScreenshot {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        return screenshot
    }
}
