import Strata
import SwiftUI
import XCTest

final class StrataAvatarTests: XCTestCase {
    /// Public consumer forms compile; runtime assertions live in AvatarReviewUITests.
    @MainActor
    func testPublicContentFormsConstructForEverySupportedThemeAndSize() throws {
        for brand in ["ocean", "graphite"] {
            for dark in [false, true] {
                let theme = try StrataTheme(theme: dark ? .dark : .light, brand: brand)
                for size in [StrataAvatarSize.small, .medium, .large] {
                    let initials = StrataAvatar(theme: theme, size: size, accessibilityLabel: Text("Example member")) {
                        Text("AB")
                    }
                    let symbol = StrataAvatar(theme: theme, size: size, accessibilityLabel: Text("Example group")) {
                        Image(systemName: "person.2.fill")
                    }
                    let image = picture(Image(systemName: "circle.grid.2x2.fill"), theme: theme, size: size)
                    let empty = StrataAvatar(theme: theme, size: size, accessibilityLabel: Text("Empty example visual")) {
                        EmptyView()
                    }
                    _ = (initials.body, symbol.body, image, empty.body)
                }
            }
        }
    }

    @MainActor
    private func picture(_ image: Image, theme: StrataTheme, size: StrataAvatarSize) -> some View {
        StrataAvatar(theme: theme, size: size, accessibilityLabel: Text("Example member")) {
            image.resizable().scaledToFill()
        }
    }
}
