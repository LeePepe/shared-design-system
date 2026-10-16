import SwiftUI

public enum NativeButtonPresentation: Sendable, CaseIterable {
    case prominent, bordered, plain, glass
}

/// A native Button with a caller-owned label and loading state. Icon-only callers supply
/// an accessibilityLabel. Loading retains the visible label, reserves indicator geometry,
/// and blocks repeated actions. Roles retain their native Button semantics.
public struct NativeButton<Label: View>: View {
    private let theme: NativeDesignTheme
    private let metrics: NativeControlMetrics
    private let presentation: NativeButtonPresentation
    private let role: ButtonRole?
    private let isLoading: Bool
    private let loadingLabel: Text
    private let action: () -> Void
    private let label: Label
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    public init(theme: NativeDesignTheme, metrics: NativeControlMetrics,
                presentation: NativeButtonPresentation, role: ButtonRole? = nil, isLoading: Bool,
                loadingLabel: Text, action: @escaping () -> Void,
                @ViewBuilder label: () -> Label) {
        self.theme = theme
        self.metrics = metrics
        self.presentation = presentation
        self.role = role
        self.isLoading = isLoading
        self.loadingLabel = loadingLabel
        self.action = action
        self.label = label()
    }

    public var body: some View {
        styledButton.tint(actionTint).disabled(isLoading)
            .accessibilityValue(isLoading ? loadingLabel : Text(""))
    }

    private var actionTint: Color {
        role == .destructive ? theme.statusCritical : theme.statusInfo
    }

    private var labelColor: Color {
        if presentation == .prominent {
            return role == .destructive ? theme.statusOnCritical : theme.statusOnInfo
        }
        return role == .destructive ? theme.statusCritical : theme.textPrimary
    }

    private var button: some View {
        Button(role: role, action: action) {
            // The native style owns bezel padding. Keep the requested target inside
            // the Button label so its entire area activates the native control.
            HStack(spacing: metrics.spacing) {
                label
                ZStack {
                    if isLoading {
                        ProgressView().tint(presentation == .prominent ? labelColor : actionTint)
                    }
                }
                .frame(width: metrics.iconSize, height: metrics.iconSize)
                .accessibilityHidden(true)
            }
            .nativeMinimumHitTarget(metrics.minimumHitSize)
            .foregroundColor(labelColor)
        }
    }

    @ViewBuilder private var styledButton: some View {
        switch presentation {
        case .prominent: button.buttonStyle(.borderedProminent)
        case .bordered: button.buttonStyle(.bordered)
        case .plain: button.buttonStyle(.plain)
        case .glass:
            #if compiler(>=6.2)
            if #available(iOS 26, macOS 26, *), !reduceTransparency {
                button.buttonStyle(.glass)
            } else {
                button.buttonStyle(.bordered)
            }
            #else
            button.buttonStyle(.bordered)
            #endif
        }
    }
}
