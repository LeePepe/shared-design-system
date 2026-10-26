import DesignTokens
import Strata
import SwiftUI

@main
struct DialogReviewApp: App {
    var body: some Scene {
        WindowGroup {
            DialogReviewBoard()
        }
    }
}

private struct DialogReviewBoard: View {
    private let brand: String
    private let mode: Theme
    @State private var presentation: StrataDialogPresentation?
    @State private var alertPresented = false
    @State private var result = "Ready"

    init() {
        let environment = ProcessInfo.processInfo.environment
        brand = environment["NDK_BRAND"] ?? "strata-blue"
        mode = environment["NDK_THEME"] == "dark" ? .dark : .light
    }

    private var theme: StrataTheme {
        try! StrataTheme(theme: mode, brand: brand)
    }

    var body: some View {
        Self.build(
            theme: theme,
            presentation: $presentation,
            alertPresented: $alertPresented,
            result: $result
        )
    }

    @MainActor
    private static func build(
        theme: StrataTheme,
        presentation: Binding<StrataDialogPresentation?>,
        alertPresented: Binding<Bool>,
        result: Binding<String>
    ) -> some View {
        let configuration = try! StrataDialog<AnyView, AnyView>.Configuration(
            theme: theme,
            presentation: presentation,
            onDismiss: { _, dismissal in result.wrappedValue = String(describing: dismissal) },
            base: {
                AnyView(VStack(alignment: .leading, spacing: 16) {
                    Text("Dialog review").font(.title.bold())
                    Text("Result: \(result.wrappedValue)").accessibilityIdentifier("result")
                    Button("Open finish confirmation") { alertPresented.wrappedValue = true }
                        .accessibilityIdentifier("open-alert")
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).padding(24))
            },
            content: { _ in
                AnyView(Text("Choose perceived exertion from RPE 6.0–10.0")
                    .accessibilityIdentifier("rpe-content"))
            }
        )
        return StrataDialog(configuration: configuration)
            .overlay {
                StrataAlertDialog<AnyView>.build(
                    theme: theme,
                    isPresented: alertPresented,
                    confirm: { result.wrappedValue = "confirmed" }
                )
            }
            .onAppear {
                if presentation.wrappedValue == nil {
                    presentation.wrappedValue = try! StrataDialogPresentation(
                        title: "Perceived exertion",
                        closeLabel: "Close",
                        state: .error(message: "Review your effort before finishing."),
                        dismissalPolicy: .guarded(reason: "Finish the current set before closing."),
                        actions: [
                            try! StrataDialogAction(id: "save", label: "Save RPE", role: .primary) {
                                result.wrappedValue = "saved"
                                return .dismiss
                            },
                            try! StrataDialogAction(id: "allow-outside", label: "Allow outside", role: .secondary) {
                                guard let current = presentation.wrappedValue else { return .stayPresented }
                                presentation.wrappedValue = try! StrataDialogPresentation(
                                    id: current.id,
                                    title: current.title,
                                    closeLabel: current.closeLabel,
                                    dismissalPolicy: .dismissible,
                                    allowsOutsideDismiss: true,
                                    actions: current.actions
                                )
                                return .stayPresented
                            },
                            try! StrataDialogAction(id: "cancel", label: "Cancel", role: .cancel) { .stayPresented }
                        ]
                    )
                }
            }
    }
}

private extension StrataAlertDialog where Base == AnyView {
    @MainActor
    static func build(
        theme: StrataTheme,
        isPresented: Binding<Bool>,
        confirm: @escaping @MainActor () -> Void
    ) -> some View {
        try! StrataAlertDialog(configuration: .init(
            theme: theme,
            isPresented: isPresented,
            title: "Finish workout?",
            message: "This ends the current workout.",
            confirmLabel: "Finish",
            cancelLabel: "Keep going",
            isDestructive: true,
            confirm: confirm,
            base: { AnyView(EmptyView()) }
        ))
    }
}
