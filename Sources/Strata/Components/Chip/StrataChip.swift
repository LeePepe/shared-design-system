import SwiftUI

/// Presentation vocabulary only; the caller supplies any meaning in the label.
public enum StrataChipTone: Equatable, Sendable {
    case neutral
    case accent
    case critical
}

/// A solid label with an optional, separately accessible native removal button.
public struct StrataChip<Label: View>: View {
    private let theme: StrataTheme
    private let tone: StrataChipTone
    private let label: Label
    private let removal: Removal?
    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var removalIsFocused: Bool

    /// Creates a static chip with no action or selection semantics.
    public init(theme: StrataTheme, tone: StrataChipTone, @ViewBuilder label: () -> Label) {
        self.theme = theme
        self.tone = tone
        self.label = label()
        removal = nil
    }

    /// Creates a removable chip. The caller localizes the removal label and owns removal state.
    public init(
        theme: StrataTheme,
        tone: StrataChipTone,
        removalAccessibilityLabel: Text,
        onRemove: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.theme = theme
        self.tone = tone
        self.label = label()
        removal = Removal(accessibilityLabel: removalAccessibilityLabel, action: onRemove)
    }

    public var body: some View {
        HStack(spacing: 4) {
            HStack(spacing: 6) {
                if tone == .critical {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .accessibilityHidden(true)
                }
                label.fixedSize(horizontal: false, vertical: true)
            }
            .padding(.leading, 12)
            .padding(.trailing, removal == nil ? 12 : 0)
            .padding(.vertical, 8)
            .layoutPriority(1)

            if let removal {
                Button {
                    StrataChipActivation.perform(isEnabled: isEnabled, action: removal.action)
                } label: {
                    Image(systemName: "xmark")
                        .font(.body.weight(.semibold))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel(removal.accessibilityLabel)
                .buttonStyle(StrataChipRemovalStyle(foreground: foreground))
                .focused($removalIsFocused)
                .overlay {
                    if removalIsFocused {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(foreground, lineWidth: 2)
                            .allowsHitTesting(false)
                    }
                }
            }
        }
        .font(.subheadline.weight(.medium))
        .foregroundStyle(foreground)
        .background(StrataChipShape().fill(background))
    }

    private var foreground: Color {
        switch tone {
        case .neutral: theme.foreground
        case .accent: theme.onAccent
        case .critical: theme.onCritical
        }
    }

    private var background: Color {
        switch tone {
        case .neutral: theme.surface
        case .accent: theme.accent
        case .critical: theme.critical
        }
    }

    private struct Removal {
        let accessibilityLabel: Text
        let action: () -> Void
    }
}

/// Compact chips are capsules; growing text keeps bounded, continuous corners.
/// This shape is deliberately independent of any other component's shape.
struct StrataChipShape: Shape {
    func path(in rect: CGRect) -> Path {
        RoundedRectangle(cornerRadius: min(22, rect.height / 2), style: .continuous)
            .path(in: rect)
    }
}

enum StrataChipActivation {
    static func perform(isEnabled: Bool, action: () -> Void) {
        guard isEnabled else { return }
        action()
    }
}

private struct StrataChipRemovalStyle: ButtonStyle {
    let foreground: Color
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foreground)
            .overlay {
                if configuration.isPressed || !isEnabled {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(foreground, style: StrokeStyle(
                            lineWidth: 1, dash: isEnabled ? [] : [3, 3]
                        ))
                        .padding(4)
                        .allowsHitTesting(false)
                }
            }
    }
}
