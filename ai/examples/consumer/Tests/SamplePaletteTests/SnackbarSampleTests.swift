import DesignTokens
import SwiftUI
import XCTest
import SamplePalette
import Strata

final class SnackbarSampleTests: XCTestCase {
    @MainActor
    func testSnackbarSampleBuildsWithPublicImports() throws {
        let theme = try StrataTheme(theme: .light, brand: "strata-blue")
        var item: StrataSnackbarItem? = try StrataSnackbarItem(message: "Saved", closeLabel: "Close")
        _ = try SnackbarSample.view(
            theme: theme,
            item: Binding<StrataSnackbarItem?>(
                get: { item },
                set: { item = $0 }
            )
        )
    }
}
