import NativeDesignKit
import SwiftUI

@main
struct CheckboxReviewApp: App {
    private let configuration = Result { try CheckboxReviewConfiguration() }

    var body: some Scene {
        WindowGroup {
            switch configuration {
            case .success(let configuration):
                CheckboxReviewContent(configuration: configuration)
            case .failure(let error):
                Text("Fixture configuration failed: \(String(describing: error))")
                    .accessibilityIdentifier("checkbox.error")
                    .padding()
            }
        }
    }
}

private enum CheckboxReviewError: Error { case missingExplicitConfiguration }

private struct CheckboxReviewConfiguration {
    let theme: NativeDesignTheme
    let brand: String
    let mode: String
    let narrow: Bool
    let accessibilitySize: Bool
    let disabled: Bool
    let initiallyOn: Bool

    init() throws {
        let environment = ProcessInfo.processInfo.environment
        guard let brand = environment["NDK_BRAND"],
              let mode = environment["NDK_THEME"], ["light", "dark"].contains(mode),
              let scenario = environment["NDK_SCENARIO"], ["matrix", "narrow"].contains(scenario),
              let textSize = environment["NDK_TEXT_SIZE"], ["large", "accessibility2"].contains(textSize)
        else { throw CheckboxReviewError.missingExplicitConfiguration }
        self.brand = brand
        self.mode = mode
        theme = try NativeDesignTheme(theme: mode == "light" ? .light : .dark, brand: brand)
        narrow = scenario == "narrow"
        accessibilitySize = textSize == "accessibility2"
        disabled = environment["NDK_DISABLED"] == "1"
        initiallyOn = environment["NDK_INITIAL_ON"] == "1"
    }
}

private struct CheckboxReviewContent: View {
    let configuration: CheckboxReviewConfiguration
    @State private var isOn: Bool
    @State private var bindingWrites = 0

    init(configuration: CheckboxReviewConfiguration) {
        self.configuration = configuration
        _isOn = State(initialValue: configuration.initiallyOn)
    }

    private var theme: NativeDesignTheme { configuration.theme }
    private var label: String {
        configuration.narrow
            ? "Auswahl und Benachrichtigungen für wichtige Änderungen bestätigen"
            : "Include attachments"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(configuration.narrow ? "Long labels" : "Native Checkbox")
                    .font(configuration.narrow ? .headline : .largeTitle.bold())
                Text("\(configuration.brand.capitalized) · \(configuration.mode.capitalized) · Strata")
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryForeground)

                NativeCheckbox(theme: theme, isOn: Binding(
                    get: { isOn },
                    set: { isOn = $0; bindingWrites += 1 }
                )) { Text(verbatim: label) }
                    .disabled(configuration.disabled)
                    .accessibilityIdentifier("checkbox.primary")

                Text(isOn ? "Checked" : "Unchecked")
                    .font(.caption)
                    .accessibilityIdentifier("checkbox.state")
                Text("Binding writes: \(bindingWrites)")
                    .font(.caption)
                    .accessibilityIdentifier("checkbox.writes")

                if !configuration.narrow {
                    Button("Set from caller") { isOn.toggle() }
                        .tint(theme.accent)
                        .accessibilityIdentifier("checkbox.caller")
                    NativeCheckbox(theme: theme, isOn: .constant(true)) { Text("Checked") }
                        .accessibilityIdentifier("checkbox.selected")
                    NativeCheckbox(theme: theme, isOn: .constant(false)) { Text("Disabled · unchecked") }
                        .disabled(true)
                        .accessibilityIdentifier("checkbox.disabledOff")
                    NativeCheckbox(theme: theme, isOn: .constant(true)) { Text("Disabled · checked") }
                        .disabled(true)
                        .accessibilityIdentifier("checkbox.disabledOn")
                    Text("Synthetic fixture · caller-owned state")
                        .font(.caption)
                        .foregroundStyle(theme.secondaryForeground)
                        .accessibilityIdentifier("checkbox.footer")
                }
            }
            .frame(width: configuration.narrow ? 272 : nil, alignment: .leading)
            .padding(24)
        }
        .accessibilityIdentifier("checkbox.scroll")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(theme.foreground)
        .background(theme.canvas)
        .environment(\.dynamicTypeSize, configuration.accessibilitySize ? .accessibility2 : .large)
        .preferredColorScheme(configuration.mode == "light" ? .light : .dark)
    }
}
