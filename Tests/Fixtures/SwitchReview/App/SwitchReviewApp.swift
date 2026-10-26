import Strata
import SwiftUI

@main
struct SwitchReviewApp: App {
    private let configuration = Result { try SwitchReviewConfiguration() }

    var body: some Scene {
        WindowGroup {
            switch configuration {
            case .success(let configuration):
                SwitchReviewContent(configuration: configuration)
            case .failure(let error):
                Text("Fixture configuration failed: \(String(describing: error))")
                    .accessibilityIdentifier("switch.configurationError")
                    .padding()
            }
        }
    }
}

private enum SwitchReviewConfigurationError: Error {
    case missingExplicitSupportedBrandOrMode
}

private struct SwitchReviewConfiguration {
    let theme: StrataTheme
    let brand: String
    let mode: String
    let narrow: Bool
    let accessibilitySize: Bool
    let disabled: Bool
    let initiallyOn: Bool

    init() throws {
        let environment = ProcessInfo.processInfo.environment
        guard let brand = environment["NDK_SWITCH_BRAND"], ["ocean", "graphite"].contains(brand),
              let mode = environment["NDK_SWITCH_MODE"], ["light", "dark"].contains(mode)
        else { throw SwitchReviewConfigurationError.missingExplicitSupportedBrandOrMode }
        self.brand = brand
        self.mode = mode
        theme = try StrataTheme(theme: mode == "light" ? .light : .dark, brand: brand)
        narrow = environment["NDK_SWITCH_NARROW"] == "1"
        accessibilitySize = environment["NDK_SWITCH_ACCESSIBILITY"] == "1"
        disabled = environment["NDK_SWITCH_DISABLED"] == "1"
        initiallyOn = environment["NDK_SWITCH_INITIAL_ON"] == "1"
    }
}

private struct SwitchReviewContent: View {
    let configuration: SwitchReviewConfiguration
    @State private var isOn: Bool
    @State private var bindingWrites = 0

    init(configuration: SwitchReviewConfiguration) {
        self.configuration = configuration
        _isOn = State(initialValue: configuration.initiallyOn)
    }

    private var theme: StrataTheme { configuration.theme }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(configuration.narrow ? "Long labels" : "Strata Switch")
                    .font(configuration.narrow ? .headline : .largeTitle.bold())
                Text("\(configuration.brand.capitalized) · \(configuration.mode.capitalized) · Strata")
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryForeground)

                StrataSwitch(theme: theme, isOn: Binding(
                    get: { isOn },
                    set: { isOn = $0; bindingWrites += 1 }
                )) {
                    Text(configuration.narrow
                         ? "Allow notifications about important updates and changes to your preferences"
                         : "Enable notifications")
                }
                .disabled(configuration.disabled)
                .accessibilityLabel(configuration.narrow
                                    ? "Allow notifications about important updates and changes to your preferences"
                                    : "Allow notifications")
                .accessibilityIdentifier("switch.primary")
                // The component must use its explicit theme even when its caller differs.
                .environment(\.colorScheme, configuration.mode == "light" ? .dark : .light)

                Text(isOn ? "On" : "Off")
                    .accessibilityIdentifier("switch.state")
                Text("Binding writes: \(bindingWrites)")
                    .font(.caption)
                    .accessibilityIdentifier("switch.writes")

                if !configuration.narrow {
                    Button("Set from caller") { isOn.toggle() }
                        .accessibilityIdentifier("switch.callerUpdate")
                        .tint(theme.accent)
                    StrataSwitch(theme: theme, isOn: .constant(true)) { Text("On") }
                        .accessibilityIdentifier("switch.selected")
                    StrataSwitch(theme: theme, isOn: .constant(false)) { Text("Disabled · off") }
                        .disabled(true)
                        .accessibilityIdentifier("switch.disabledOff")
                    StrataSwitch(theme: theme, isOn: .constant(true)) { Text("Disabled · on") }
                        .disabled(true)
                        .accessibilityIdentifier("switch.disabledOn")
                }

                if !configuration.narrow {
                    Text("Strata SwiftUI · caller-owned state")
                        .font(.caption)
                        .foregroundStyle(theme.secondaryForeground)
                        .accessibilityIdentifier("switch.footer")
                }
            }
            .frame(width: configuration.narrow ? 280 : nil, alignment: .leading)
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(theme.foreground)
        .background(theme.canvas)
        .environment(\.dynamicTypeSize, configuration.accessibilitySize ? .accessibility3 : .large)
        .preferredColorScheme(configuration.mode == "light" ? .light : .dark)
    }
}
