import SwiftUI

/// A caller-owned Boolean selection with native toggle semantics.
public struct NativeCheckbox<Label: View>: View {
    private let theme: NativeDesignTheme
    @Binding private var isOn: Bool
    private let label: Label

    public init(
        theme: NativeDesignTheme,
        isOn: Binding<Bool>,
        @ViewBuilder label: () -> Label
    ) {
        self.theme = theme
        _isOn = isOn
        self.label = label()
    }

    public var body: some View {
        Toggle(isOn: $isOn) {
            label
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        #if os(macOS)
        .toggleStyle(.checkbox)
        .tint(theme.accent)
        .foregroundStyle(theme.foreground)
        .frame(minWidth: 44, minHeight: 44, alignment: .leading)
        #else
        .toggleStyle(NativeCheckboxStyle(theme: theme))
        #endif
        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
    }
}

#if !os(macOS)
private struct NativeCheckboxStyle: ToggleStyle {
    let theme: NativeDesignTheme
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let colors = NativeCheckboxColors(theme: theme, isOn: configuration.isOn, isEnabled: isEnabled)
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(colors.fill)
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .strokeBorder(colors.outline, lineWidth: 2)
                    if configuration.isOn {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(colors.mark)
                    }
                }
                .frame(width: 22, height: 22)
                .accessibilityHidden(true)
                configuration.label
                    .foregroundStyle(colors.label)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 8)
            .frame(minWidth: 44, minHeight: 44, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(NativeCheckboxButtonStyle(theme: theme))
        .accessibilityRepresentation {
            Toggle(isOn: configuration.$isOn) { configuration.label }
                .toggleStyle(.switch)
        }
    }
}

private struct NativeCheckboxButtonStyle: ButtonStyle {
    let theme: NativeDesignTheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                if configuration.isPressed {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .strokeBorder(theme.secondaryForeground, lineWidth: 2)
                        .allowsHitTesting(false)
                }
            }
    }
}
#endif

// Color routing is pure; all opaque colors are the caller's resolved token values.
struct NativeCheckboxColors {
    let fill: Color
    let outline: Color
    let mark: Color
    let label: Color

    init(theme: NativeDesignTheme, isOn: Bool, isEnabled: Bool) {
        fill = isOn ? (isEnabled ? theme.accent : theme.surface) : .clear
        outline = isOn && isEnabled ? theme.accent : theme.secondaryForeground
        mark = isEnabled ? theme.onAccent : theme.secondaryForeground
        label = isEnabled ? theme.foreground : theme.secondaryForeground
    }
}
