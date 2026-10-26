import Strata
import SwiftUI

public enum SnackbarSample {
    @MainActor
    public static func view(theme: StrataTheme, item: Binding<StrataSnackbarItem?>) throws -> some View {
        let configuration = try StrataSnackbar<Text, EmptyView>.Configuration(
            theme: theme,
            item: item,
            onDismiss: { _, _ in },
            content: {
                Text("Workout")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            },
            bottomBar: {
                EmptyView()
            }
        )
        return StrataSnackbar(configuration: configuration)
    }
}
