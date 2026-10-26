import SwiftUI

public enum StrataSearchFieldConfigurationError: Error, Equatable, Sendable {
    case emptyLabel
    case emptyClearLabel
}

public struct StrataSearchFieldConfiguration: Sendable {
    public let label: String
    public let placeholder: String?
    public let clearLabel: String
    public let resultSummary: String?
    public let validationMessage: String?
    public let isDisabled: Bool

    public init(label: String, placeholder: String? = nil, clearLabel: String,
                resultSummary: String? = nil, validationMessage: String? = nil,
                isDisabled: Bool = false) throws {
        guard !label.isEmpty else { throw StrataSearchFieldConfigurationError.emptyLabel }
        guard !clearLabel.isEmpty else { throw StrataSearchFieldConfigurationError.emptyClearLabel }
        self.label = label
        self.placeholder = placeholder
        self.clearLabel = clearLabel
        self.resultSummary = resultSummary
        self.validationMessage = validationMessage
        self.isDisabled = isDisabled
    }
}

public struct StrataSearchField: View {
    private let theme: StrataTheme
    @Binding private var text: String
    private let configuration: StrataSearchFieldConfiguration
    private let onSubmit: (() -> Void)?
    private let onClear: (() -> Void)?
    @FocusState private var isFocused: Bool

    public init(theme: StrataTheme, text: Binding<String>,
                configuration: StrataSearchFieldConfiguration,
                onSubmit: (() -> Void)? = nil, onClear: (() -> Void)? = nil) {
        self.theme = theme
        self._text = text
        self.configuration = configuration
        self.onSubmit = onSubmit
        self.onClear = onClear
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(theme.secondaryForeground)
                    .accessibilityHidden(true)
                TextField(configuration.label, text: $text,
                          prompt: configuration.placeholder.map {
                              Text($0).foregroundColor(theme.secondaryForeground)
                          })
                    .textFieldStyle(.plain)
                    .font(.body)
                    .foregroundStyle(theme.foreground)
                    .tint(theme.accent)
                    .focused($isFocused)
                    .onSubmit { onSubmit?() }
                    .accessibilityLabel(configuration.label)
                if !text.isEmpty {
                    Button(action: clear) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(theme.secondaryForeground)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(configuration.clearLabel)
                    .accessibilityIdentifier("strata-search-field-clear-\(configuration.label)")
                    .disabled(configuration.isDisabled)
                }
            }
            .padding(.horizontal, 12)
            .frame(minHeight: 44)
            .background(theme.surface(.card), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(hasValidation ? theme.critical : (isFocused ? theme.accent : .clear),
                                  lineWidth: 1)
            }
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .onTapGesture { if !configuration.isDisabled { isFocused = true } }

            if let resultSummary = configuration.resultSummary {
                Text(resultSummary).font(.footnote).foregroundStyle(theme.secondaryForeground)
            }
            if let validationMessage = configuration.validationMessage, !validationMessage.isEmpty {
                Text(validationMessage).font(.footnote).foregroundStyle(theme.critical)
                    .accessibilityIdentifier("search-field-validation")
            }
        }
        .foregroundStyle(configuration.isDisabled ? theme.secondaryForeground : theme.foreground)
        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
        .disabled(configuration.isDisabled)
    }

    private var hasValidation: Bool {
        guard let validationMessage = configuration.validationMessage else { return false }
        return !validationMessage.isEmpty
    }

    private func clear() {
        guard !configuration.isDisabled else { return }
        text = ""
        onClear?()
    }
}
