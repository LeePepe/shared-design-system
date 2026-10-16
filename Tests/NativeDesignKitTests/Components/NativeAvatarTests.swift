import NativeDesignKit
import SwiftUI
import XCTest

final class NativeAvatarTests: XCTestCase {
    /// Public consumer forms compile; runtime assertions live in AvatarReviewUITests.
    @MainActor
    func testPublicContentFormsConstructForEverySupportedThemeAndSize() throws {
        for brand in ["ocean", "graphite"] {
            for dark in [false, true] {
                let theme = try NativeDesignTheme(theme: dark ? .dark : .light, brand: brand)
                for size in [NativeAvatarSize.small, .medium, .large] {
                    let initials = NativeAvatar(theme: theme, size: size, accessibilityLabel: Text("Example member")) {
                        Text("AB")
                    }
                    let symbol = NativeAvatar(theme: theme, size: size, accessibilityLabel: Text("Example group")) {
                        Image(systemName: "person.2.fill")
                    }
                    let image = picture(Image(systemName: "circle.grid.2x2.fill"), theme: theme, size: size)
                    let empty = NativeAvatar(theme: theme, size: size, accessibilityLabel: Text("Empty example visual")) {
                        EmptyView()
                    }
                    _ = (initials.body, symbol.body, image, empty.body)
                }
            }
        }
    }

    @MainActor
    private func picture(_ image: Image, theme: NativeDesignTheme, size: NativeAvatarSize) -> some View {
        NativeAvatar(theme: theme, size: size, accessibilityLabel: Text("Example member")) {
            image.resizable().scaledToFill()
        }
    }
}
