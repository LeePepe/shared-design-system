import SwiftUI

/// Explicit semantic emphasis; all colors are resolved by the supplied theme.
public enum NativeControlTone: Sendable, CaseIterable {
    case neutral, info, warning, critical

    func colors(_ theme: NativeDesignTheme) -> (background: Color, foreground: Color) {
        switch self {
        case .neutral: return (theme.surfaceRaised, theme.textPrimary)
        case .info: return (theme.statusInfo, theme.statusOnInfo)
        case .warning: return (theme.statusWarning, theme.statusOnWarning)
        case .critical: return (theme.statusCritical, theme.statusOnCritical)
        }
    }
}

struct ControlChrome: ViewModifier {
    let theme: NativeDesignTheme
    let metrics: NativeControlMetrics
    @Environment(\.isEnabled) private var isEnabled

    func body(content: Content) -> some View {
        content.tint(theme.statusInfo).foregroundColor(theme.textPrimary)
            .opacity(isEnabled ? 1 : metrics.disabledOpacity)
    }
}

struct FieldChrome: ViewModifier {
    let theme: NativeDesignTheme
    let metrics: NativeControlMetrics

    func body(content: Content) -> some View {
        content.padding(metrics.padding)
            .frame(minHeight: metrics.minimumHitSize)
            .background(RoundedRectangle(cornerRadius: metrics.cornerRadius).fill(theme.surfaceRaised))
            .overlay(RoundedRectangle(cornerRadius: metrics.cornerRadius)
                .strokeBorder(theme.textSecondary, lineWidth: metrics.borderWidth)
                .allowsHitTesting(false).accessibilityHidden(true))
            .modifier(ControlChrome(theme: theme, metrics: metrics))
    }
}
