import SwiftUI

/// A labeled native text input with a readable Strata surface.
/// The caller owns the text, input configuration, submission and validation.
public struct NativeTextField<Label: View>: View {
    private let theme: NativeDesignTheme
    @Binding private var text: String
    private let prompt: Text?
    private let label: Label
    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isFocused: Bool

    public init(
        theme: NativeDesignTheme,
        text: Binding<String>,
        prompt: Text? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self.theme = theme
        _text = text
        self.prompt = prompt
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
                label
            }
            .labelsHidden()
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
                    // Only the background handles padding taps. The native editor
                    // keeps its own caret, selection and contextual-menu gestures.
                    .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .onTapGesture {
                        if isEnabled { isFocused = true }
                    }
            }
            .overlay {
                if isFocused {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(theme.accent, lineWidth: 2)
                        .allowsHitTesting(false)
                }
            }
        }
    }
}
