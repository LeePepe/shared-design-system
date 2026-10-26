import Strata
import SwiftUI

public struct SnackbarSampleView: View {
    private let configuration: StrataSnackbar<AnyView, AnyView>.Configuration

    @MainActor
    public init(theme: StrataTheme, item: Binding<StrataSnackbarItem?>) throws {
        configuration = try StrataSnackbar<AnyView, AnyView>.Configuration(
            theme: theme,
            item: item,
            content: {
                AnyView(Text("Workout")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                )
            },
            bottomBar: {
                AnyView(EmptyView())
            }
        )
    }

    public var body: some View {
        StrataSnackbar(configuration: configuration)
    }
}

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
