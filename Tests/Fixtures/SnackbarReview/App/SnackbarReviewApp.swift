import Strata
import SwiftUI

@main
struct SnackbarReviewApp: App {
    var body: some Scene {
        WindowGroup {
            SnackbarReviewBoard(configuration: .init())
        }
    }
}

private struct ReviewConfiguration {
    let brand: String
    let mode: String

    init() {
        let environment = ProcessInfo.processInfo.environment
        brand = environment["NDK_BRAND"] ?? "strata-blue"
        mode = environment["NDK_THEME"] ?? "light"
    }
}

private struct SnackbarReviewBoard: View {
    let configuration: ReviewConfiguration
    @State private var item: StrataSnackbarItem?
    @State private var result = "Ready"

    private var theme: StrataTheme {
        try! StrataTheme(
            theme: configuration.mode == "dark" ? .dark : .light,
            brand: configuration.brand
        )
    }

    var body: some View {
        StrataSnackbar<AnyView, AnyView>.build(
            theme: theme,
            item: $item,
            result: $result
        )
        .onAppear {
            guard item == nil else { return }
            item = try! StrataSnackbarItem(
                message: "Set deleted",
                closeLabel: "Close",
                action: try! StrataSnackbarAction(label: "Undo") {
                    result = "Action"
                }
            )
        }
    }
}

private extension StrataSnackbar where Content == AnyView, BottomBar == AnyView {
    @MainActor
    static func build(
        theme: StrataTheme,
        item: Binding<StrataSnackbarItem?>,
        result: Binding<String>
    ) -> some View {
        try! StrataSnackbar(
            configuration: .init(
                theme: theme,
                item: item,
                onDismiss: { _, dismissal in result.wrappedValue = String(describing: dismissal) },
                content: {
                    AnyView(VStack(alignment: .leading, spacing: 16) {
                        Text("Snackbar review")
                            .font(.title.bold())
                            .accessibilityIdentifier("board-title")
                        Text("\(theme.mode == .dark ? "dark" : "light")")
                        Text("Result: \(result.wrappedValue)")
                            .accessibilityIdentifier("result")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(24))
                },
                bottomBar: {
                    AnyView(Text("Bottom bar coordination")
                        .accessibilityIdentifier("bottom-bar")
                    )
                }
            )
        )
    }
}
