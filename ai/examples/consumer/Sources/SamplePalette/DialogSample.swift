import Strata
import SwiftUI

public struct DialogSampleView: View {
    private let dialog: StrataDialog<AnyView, AnyView>.Configuration
    private let alert: StrataAlertDialog<AnyView>.Configuration

    @MainActor
    public init(
        theme: StrataTheme,
        presentation: Binding<StrataDialogPresentation?>,
        isAlertPresented: Binding<Bool>,
        confirm: @escaping @MainActor () -> Void
    ) throws {
        dialog = try StrataDialog<AnyView, AnyView>.Configuration(
            theme: theme,
            presentation: presentation,
            base: { AnyView(Text("Workout")) },
            content: { _ in AnyView(Text("RPE 6.0–10.0")) }
        )
        alert = try StrataAlertDialog<AnyView>.Configuration(
            theme: theme,
            isPresented: isAlertPresented,
            title: "Finish workout?",
            message: "Your current set will be ended.",
            confirmLabel: "Finish",
            cancelLabel: "Keep going",
            isDestructive: true,
            confirm: confirm,
            base: { AnyView(Text("Workout")) }
        )
    }

    public var body: some View {
        StrataDialog(configuration: dialog)
            .overlay {
                StrataAlertDialog(configuration: alert)
            }
    }
}
