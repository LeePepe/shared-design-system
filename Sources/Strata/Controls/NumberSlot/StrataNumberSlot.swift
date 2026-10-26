import SwiftUI

public enum StrataNumberSlotConfigurationError: Error, Equatable, Sendable {
    case emptyLabel
}

public struct StrataNumberSlotConfiguration: Sendable {
    public let label: String
    public let displayValue: String
    public let placeholder: String
    public let prefixBadge: String?
    public let unitLabel: String?
    public let isActive: Bool
    public let isCompleted: Bool
    public let isInvalid: Bool
    public let isDisabled: Bool

    public init(label: String, displayValue: String, placeholder: String = "—",
                prefixBadge: String? = nil, unitLabel: String? = nil,
                isActive: Bool = false, isCompleted: Bool = false,
                isInvalid: Bool = false, isDisabled: Bool = false) throws {
        guard !label.isEmpty else { throw StrataNumberSlotConfigurationError.emptyLabel }
        self.label = label
        self.displayValue = displayValue
        self.placeholder = placeholder
        self.prefixBadge = prefixBadge
        self.unitLabel = unitLabel
        self.isActive = isActive
        self.isCompleted = isCompleted
        self.isInvalid = isInvalid
        self.isDisabled = isDisabled
    }
}

public struct StrataNumberSlot: View {
    private let theme: StrataTheme
    private let configuration: StrataNumberSlotConfiguration
    private let action: () -> Void

    public init(theme: StrataTheme, configuration: StrataNumberSlotConfiguration,
                action: @escaping () -> Void) {
        self.theme = theme
        self.configuration = configuration
        self.action = action
    }

    public var body: some View {
        let appearance = StrataNumberSlotAppearance(theme: theme, configuration: configuration)
        Button(action: activate) {
            HStack(spacing: 8) {
                if let prefixBadge = configuration.prefixBadge {
                    Text(prefixBadge).font(.subheadline.weight(.semibold))
                        .foregroundStyle(theme.secondaryForeground)
                }
                Text(configuration.displayValue.isEmpty ? configuration.placeholder : configuration.displayValue)
                    .font(.body.weight(.medium).monospacedDigit())
                    .foregroundStyle(appearance.foreground)
                if let unitLabel = configuration.unitLabel {
                    Text(unitLabel).font(.subheadline).foregroundStyle(theme.secondaryForeground)
                }
            }
            .frame(minWidth: 44, minHeight: 44)
            .padding(.horizontal, 12)
            .background(appearance.fill, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(appearance.outline, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .disabled(configuration.isDisabled)
        .accessibilityLabel(Text(configuration.label))
        .accessibilityValue(Text(accessibilityValue))
        .accessibilityAddTraits(configuration.isActive ? .isSelected : [])
        .foregroundStyle(configuration.isDisabled ? theme.secondaryForeground : theme.foreground)
        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
    }

    private var accessibilityValue: String {
        StrataNumberSlotAppearance(theme: theme, configuration: configuration).accessibilityValue
    }

    struct StrataNumberSlotAppearance {
        let fill: Color
        let foreground: Color
        let outline: Color
        let accessibilityValue: String

        init(theme: StrataTheme, configuration: StrataNumberSlotConfiguration) {
            fill = configuration.isCompleted ? theme.successSurface : theme.surface(.inset)
            foreground = configuration.isCompleted ? theme.success :
                configuration.displayValue.isEmpty ? theme.secondaryForeground : theme.foreground
            outline = configuration.isInvalid ? theme.critical :
                configuration.isCompleted ? theme.success :
                configuration.isActive ? theme.accent : .clear
            accessibilityValue = ([configuration.prefixBadge,
                                   configuration.displayValue.isEmpty ? configuration.placeholder : configuration.displayValue,
                                   configuration.unitLabel] + (configuration.isCompleted ? ["Completed"] : []))
                .compactMap { $0 }.joined(separator: " ")
        }
    }

    private func activate() {
        guard !configuration.isDisabled else { return }
        action()
    }
}
