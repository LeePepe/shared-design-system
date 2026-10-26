import DesignTokens
import Strata
import SwiftUI

@main
struct RenameReviewApp: App {
    private let theme: StrataTheme

    init() {
        theme = try! StrataTheme(theme: .light, brand: "strata-blue")
    }

    var body: some Scene {
        WindowGroup {
            VStack(spacing: 20) {
                Text("Strata rename review")
                    .accessibilityIdentifier("strata-title")
                StrataButton(theme: theme, variant: .primary, isLoading: false, action: {}) {
                    Text("Continue")
                } loadingLabel: {
                    Text("Loading")
                }
                .accessibilityIdentifier("strata-button")
            }
            .padding(32)
            .strataSurface(theme: theme, style: .solid, cornerRadius: 16, role: .region)
        }
    }
}
