import SwiftUI

public enum StrataButtonVariant: Equatable, Sendable {
    case primary
    case secondary
    case ghost
    case toolbar
}

/// A native action with explicit style, caller-owned labels and loading state.
public struct StrataButton<Label: View, LoadingLabel: View>: View {
    private let theme: StrataTheme
    private let variant: StrataButtonVariant
    private let surface: StrataSurfaceStyle
    private let isLoading: Bool
    private let action: () -> Void
    private let label: Label
    private let loadingLabel: LoadingLabel
    @FocusState private var isFocused: Bool
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        theme: StrataTheme,
        variant: StrataButtonVariant,
        isLoading: Bool,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label,
        @ViewBuilder loadingLabel: () -> LoadingLabel
    ) {
        self.init(theme: theme, variant: variant, surface: .solid, isLoading: isLoading,
                  action: action, label: label, loadingLabel: loadingLabel)
    }

    /// Material is explicit for new compositions; primary actions always stay solid.
    public init(
        theme: StrataTheme,
        variant: StrataButtonVariant,
        surface: StrataSurfaceStyle,
        isLoading: Bool,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label,
        @ViewBuilder loadingLabel: () -> LoadingLabel
    ) {
        self.theme = theme
        self.variant = variant
        self.surface = surface
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
                    StrataButtonSpinner(isActive: isLoading, reduceMotion: reduceMotion)
                        .accessibilityHidden(true)
                    loadingLabel
                }
                .opacity(isLoading ? 1 : 0)
                .accessibilityHidden(!isLoading)
            }
            .font(.callout.weight(.semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(minWidth: 44, minHeight: 44)
            .alignmentGuide(.strataControlCenter) { $0[VerticalAlignment.center] }
            .alignmentGuide(.strataInputBaseline) { $0[.firstTextBaseline] }
            .contentShape(StrataButtonShape())
        }
        .buttonStyle(StrataActionButtonStyle(theme: theme, variant: variant, surface: surface,
                                            isLoading: isLoading, reduceMotion: reduceMotion))
        .focused($isFocused)
        .overlay {
            if isFocused && variant != .toolbar {
                StrataButtonShape().strokeBorder(theme.accent, lineWidth: 3).padding(-4)
                    .allowsHitTesting(false)
            }
        }
        .disabled(isLoading)
    }

    private func activate() {
        StrataButtonActivation.perform(isEnabled: isEnabled, isLoading: isLoading, action: action)
    }
}

/// A circular activity cue that remains recognizable when Reduce Motion stops rotation.
private struct StrataButtonSpinner: View {
    let isActive: Bool
    let reduceMotion: Bool
    @ScaledMetric(relativeTo: .body) private var size: CGFloat = 16
    @State private var rotating = false

    var body: some View {
        Circle()
            .trim(from: 0.08, to: 0.82)
            .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotating && !reduceMotion ? 360 : 0))
            .animation(reduceMotion || !isActive ? nil : .linear(duration: 0.9).repeatForever(autoreverses: false),
                       value: rotating)
            .onAppear { rotating = isActive && !reduceMotion }
            .onChange(of: isActive) { rotating = $0 && !reduceMotion }
            .onChange(of: reduceMotion) { rotating = isActive && !$0 }
    }
}

/// Capsule-like at normal target height, with bounded corners as text grows.
/// Keeping the radius bounded leaves multiline labels on their opaque fill.
struct StrataButtonShape: InsettableShape {
    private var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        RoundedRectangle(cornerRadius: max(0, 22 - insetAmount), style: .continuous)
            .path(in: rect.insetBy(dx: insetAmount, dy: insetAmount))
    }

    func inset(by amount: CGFloat) -> StrataButtonShape {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
}

/// Also guards programmatic activation: loading cannot dispatch a second action.
enum StrataButtonActivation {
    static func perform(isEnabled: Bool, isLoading: Bool, action: () -> Void) {
        guard isEnabled && !isLoading else { return }
        action()
    }
}

private struct StrataActionButtonStyle: ButtonStyle {
    let theme: StrataTheme
    let variant: StrataButtonVariant
    let surface: StrataSurfaceStyle
    let isLoading: Bool
    let reduceMotion: Bool

    func makeBody(configuration: Configuration) -> some View {
        StrataActionButtonBody(configuration: configuration, theme: theme, variant: variant,
                               surface: surface, isLoading: isLoading, reduceMotion: reduceMotion)
    }
}

/// The rendered view owns interaction state so pointer changes invalidate its body.
private struct StrataActionButtonBody: View {
    let configuration: ButtonStyleConfiguration
    let theme: StrataTheme
    let variant: StrataButtonVariant
    let surface: StrataSurfaceStyle
    let isLoading: Bool
    let reduceMotion: Bool
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceTransparency) private var systemReduceTransparency
    @Environment(\.nativeReduceTransparencyOverride) private var reduceTransparencyOverride
    @State private var isHovered = false

    var body: some View {
        let responds = isEnabled && !isLoading
        let pressed = responds && configuration.isPressed
        let hovered = responds && isHovered
        let paint = StrataButtonPaint(theme: theme, variant: variant, isEnabled: isEnabled,
                                      isLoading: isLoading, isPressed: pressed, isHovered: hovered)
        configuration.label
            .background {
                switch variant {
                case .primary:
                    if let fill = paint.fill { StrataButtonShape().fill(fill) }
                case .secondary:
                    // The shared dense role supplies a restrained edge without another blur.
                    Group {
                        if surface == .solid || (reduceTransparencyOverride ?? systemReduceTransparency) {
                            StrataButtonShape().fill(theme.surface(.inset))
                        } else {
                            Color.clear
                                .strataSurface(theme: theme, style: surface, cornerRadius: 22, role: .card)
                        }
                    }
                        .overlay {
                            if let fill = paint.fill { StrataButtonShape().fill(fill) }
                        }
                case .ghost:
                    if let fill = paint.fill { StrataButtonShape().fill(fill) }
                case .toolbar:
                    EmptyView()
                }
            }
            .foregroundStyle(paint.foreground)
            .overlay {
                if pressed && variant != .toolbar {
                    StrataButtonShape().strokeBorder(paint.foreground, lineWidth: 2)
                }
            }
            .onHover { isHovered = $0 }
            .scaleEffect(pressed && !reduceMotion ? 0.98 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.14), value: pressed)
    }
}

/// Shared by rendering and numeric contrast checks; no opacity is applied to content.
struct StrataButtonPaint {
    let foreground: Color
    let fill: Color?

    init(theme: StrataTheme, variant: StrataButtonVariant, isEnabled: Bool,
         isLoading: Bool, isPressed: Bool, isHovered: Bool) {
        if !isEnabled && !isLoading {
            foreground = theme.secondaryForeground
            fill = variant == .ghost || variant == .toolbar ? nil : theme.surface(.inset)
            return
        }
        foreground = variant == .primary ? theme.onInteractiveAccent :
            variant == .toolbar ? theme.accent :
            variant == .ghost ? theme.brandText : theme.foreground
        switch variant {
        case .primary:
            fill = isLoading ? theme.interactiveAccent :
                isPressed ? theme.accentActive :
                isHovered ? theme.accentHover : theme.interactiveAccent
        case .secondary:
            fill = isLoading ? nil : isPressed ? theme.surface(.selected) : isHovered ? theme.surface(.hover) : nil
        case .ghost:
            fill = !isLoading && (isPressed || isHovered) ? theme.accentSubtle : nil
        case .toolbar:
            fill = nil
        }
    }
}
