import Strata
import SwiftUI

public enum SnackbarSample {
    @MainActor
    public static func view(theme: StrataTheme, item: Binding<StrataSnackbarItem?>) throws -> some View {
        let configuration = try StrataSnackbar<AnyView, AnyView>.Configuration(
            theme: theme,
            item: item,
            onDismiss: { _, _ in },
            content: {
                AnyView(Text("Workout")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                )
            },
            bottomBar: {
                AnyView(EmptyView())
            }
        )
        return StrataSnackbar<AnyView, AnyView>(configuration: configuration)
    }
}
