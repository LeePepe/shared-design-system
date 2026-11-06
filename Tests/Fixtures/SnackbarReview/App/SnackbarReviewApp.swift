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
    let scenario: String

    init() {
        let environment = ProcessInfo.processInfo.environment
        brand = environment["NDK_BRAND"] ?? "strata-blue"
        mode = environment["NDK_THEME"] ?? "light"
        scenario = environment["NDK_SCENARIO"] ?? "default"
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
        try! StrataSnackbar(
            configuration: .init(
                theme: theme,
                item: $item,
                onDismiss: { _, dismissal in result = String(describing: dismissal).lowercased() },
                content: {
                    AnyView(VStack(alignment: .leading, spacing: 16) {
                        Text("Snackbar review")
                            .font(.title.bold())
                            .accessibilityIdentifier("board-title")
                        Text("\(theme.mode == .dark ? "dark" : "light")")
                        Text("Result: \(result)")
                            .accessibilityIdentifier("result")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(24))
                },
                bottomBar: {
                    AnyView(Text("Bottom bar coordination")
                        .accessibilityIdentifier("bottom-bar"))
                }
            )
        )
        .transaction { transaction in
            if configuration.scenario == "reduce_motion" {
                transaction.animation = nil
            }
        }
        .onAppear {
            guard item == nil else { return }
            let isLong = configuration.scenario == "long"
            let actionLabel = isLong ? "撤销删除" : "Undo"
            let closeLabel = isLong ? "关闭" : "Dismiss"
            let message = isLong
                ? "已删除 16.81 / 24.00 GB：可在 5 秒内撤销 (Deleted 16.81 / 24.00 GB)"
                : "Set deleted"
            item = try! StrataSnackbarItem(
                message: message,
                closeLabel: closeLabel,
                action: try! StrataSnackbarAction(label: actionLabel) {
                    result = "action"
                    item = try! StrataSnackbarItem(message: "Undo available", closeLabel: "Dismiss")
                }
            )
        }
    }
}
