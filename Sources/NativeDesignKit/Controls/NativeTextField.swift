import SwiftUI

/// A labeled native text input with a readable Strata surface.
/// The caller owns the text, input configuration, submission and validation.
public struct NativeTextField<Label: View>: View {
    private let theme: NativeDesignTheme
    @Binding private var text: String
    private let prompt: Text?
    private let inputAccessibilityLabel: Text
    private let label: Label
    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isFocused: Bool

    /// Supplies a caller-localized editor name alongside arbitrary visible content.
    public init(
        theme: NativeDesignTheme,
        text: Binding<String>,
        prompt: Text? = nil,
        accessibilityLabel: Text,
        @ViewBuilder label: () -> Label
    ) {
        self.theme = theme
        _text = text
        self.prompt = prompt
        inputAccessibilityLabel = accessibilityLabel
        self.label = label()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            label
                .font(.subheadline.weight(.medium))
                .foregroundStyle(theme.foreground)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)

            TextField(
                text: $text,
                prompt: prompt?.foregroundColor(theme.secondaryForeground)
            ) {
                inputAccessibilityLabel
            }
            .accessibilityLabel(inputAccessibilityLabel)
            .textFieldStyle(.plain)
            .font(.body)
            .foregroundStyle(theme.foreground)
            .tint(theme.accent)
            .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
            .focused($isFocused)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(minHeight: 44)
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(theme.surface)
            }
            .overlay {
                if isFocused {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(theme.accent, lineWidth: 2)
                        .allowsHitTesting(false)
                }
            }
            // A simultaneous tap expands activation to the padded surface without
            // replacing the editor's caret, selection or contextual-menu gestures.
            .simultaneousGesture(TapGesture().onEnded {
                if isEnabled { isFocused = true }
            })
        }
        .accessibilityElement(children: .contain)
    }
}

public extension NativeTextField where Label == Text {
    /// Uses the caller's localized text for both the visible label and editor name.
    init(
        theme: NativeDesignTheme,
        text: Binding<String>,
        prompt: Text? = nil,
        @ViewBuilder label: () -> Text
    ) {
        let label = label()
        self.init(theme: theme, text: text, prompt: prompt, accessibilityLabel: label) {
            label
        }
    }
}
