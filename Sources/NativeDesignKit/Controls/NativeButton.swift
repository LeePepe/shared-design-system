import SwiftUI

public enum NativeButtonVariant: Equatable, Sendable {
    case primary
    case secondary
    case ghost
}

/// A native action with explicit style, caller-owned labels and loading state.
public struct NativeButton<Label: View, LoadingLabel: View>: View {
    private let theme: NativeDesignTheme
    private let variant: NativeButtonVariant
    private let isLoading: Bool
    private let action: () -> Void
    private let label: Label
    private let loadingLabel: LoadingLabel
    @FocusState private var isFocused: Bool
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        theme: NativeDesignTheme,
        variant: NativeButtonVariant,
        isLoading: Bool,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label,
        @ViewBuilder loadingLabel: () -> LoadingLabel
    ) {
        self.theme = theme
        self.variant = variant
        self.isLoading = isLoading
        self.action = action
        self.label = label()
        self.loadingLabel = loadingLabel()
    }

    public var body: some View {
        Button(action: activate) {
            ZStack {
                label
                    .opacity(isLoading ? 0 : 1)
                    .accessibilityHidden(isLoading)
                HStack(spacing: 8) {
                    Image(systemName: "hourglass")
                        .accessibilityHidden(true)
                    loadingLabel
                }
                .opacity(isLoading ? 1 : 0)
                .accessibilityHidden(!isLoading)
            }
            .font(.body.weight(.semibold))
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Capsule())
        }
        .buttonStyle(NativeActionButtonStyle(theme: theme, variant: variant, isLoading: isLoading, reduceMotion: reduceMotion))
        .focused($isFocused)
        .overlay {
            if isFocused {
                Capsule().strokeBorder(theme.accent, lineWidth: 3).padding(-4)
                    .allowsHitTesting(false)
            }
        }
        .disabled(isLoading)
    }

    private func activate() {
        NativeButtonActivation.perform(isEnabled: isEnabled, isLoading: isLoading, action: action)
    }
}

/// Also guards programmatic activation: loading cannot dispatch a second action.
enum NativeButtonActivation {
    static func perform(isEnabled: Bool, isLoading: Bool, action: () -> Void) {
        guard isEnabled && !isLoading else { return }
        action()
    }
}

private struct NativeActionButtonStyle: ButtonStyle {
    let theme: NativeDesignTheme
    let variant: NativeButtonVariant
    let isLoading: Bool
    let reduceMotion: Bool
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foreground)
            .background {
                switch variant {
                case .primary:
                    Capsule().fill(isEnabled || isLoading ? theme.accent : theme.surface)
                case .secondary:
                    Capsule().fill(theme.surface)
                case .ghost:
                    Capsule().strokeBorder(theme.secondaryForeground, lineWidth: configuration.isPressed ? 2 : 0)
                }
            }
            .overlay {
                if configuration.isPressed && variant != .ghost {
                    Capsule().strokeBorder(foreground, lineWidth: 2)
                }
            }
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.14), value: configuration.isPressed)
    }

    private var foreground: Color {
        if !isEnabled && !isLoading { return theme.secondaryForeground }
        return variant == .primary ? theme.onAccent : theme.foreground
    }
}
