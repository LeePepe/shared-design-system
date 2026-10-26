import AppKit
import DesignTokens
import Strata
import SwiftUI
import XCTest

final class RenameReviewMacTests: XCTestCase {
    @MainActor
    func testStrataPublicSurface() throws {
        let theme = try StrataTheme(theme: .dark, brand: "strata-purple")
        let surface = VStack(spacing: 16) {
            Text("Strata")
            StrataButton(theme: theme, variant: .secondary, isLoading: false, action: {}) {
                Text("Action")
            } loadingLabel: {
                Text("Loading")
            }
        }
        .frame(width: 320, height: 200)
        .strataSurface(theme: theme, style: .solid, cornerRadius: 16, role: .region)

        let hostingView = NSHostingView(rootView: surface)
        hostingView.frame = NSRect(x: 0, y: 0, width: 320, height: 200)
        let bitmap = try XCTUnwrap(
            hostingView.bitmapImageRepForCachingDisplay(in: hostingView.bounds)
        )
        hostingView.cacheDisplay(in: hostingView.bounds, to: bitmap)
        let pngData = try XCTUnwrap(
            bitmap.representation(using: .png, properties: [:])
        )
        XCTAssertFalse(pngData.isEmpty)

        let firstPixel = try XCTUnwrap(bitmap.colorAt(x: 0, y: 0))
        let hasNonUniformPixels = (0..<bitmap.pixelsWide).contains { x in
            (0..<bitmap.pixelsHigh).contains { y in
                guard let pixel = bitmap.colorAt(x: x, y: y) else { return false }
                return !pixel.isEqual(firstPixel)
            }
        }
        XCTAssertTrue(hasNonUniformPixels)

        let attachment = XCTAttachment(data: pngData, uniformTypeIdentifier: "public.png")
        attachment.name = "strata-surface"
        attachment.lifetime = .keepAlways
        add(attachment)
        XCTAssertEqual(theme.mode, .dark)
    }
}
