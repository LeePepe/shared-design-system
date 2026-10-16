import SwiftUI

/// Glass is reserved for floating surfaces and real controls. All explicit colors use the theme.
public enum NativeSurfaceStyle: Sendable {
    case opaque
    case glass
    case interactiveGlass

    func usesGlass(supported: Bool, reduceTransparency: Bool) -> Bool {
        supported && !reduceTransparency && self != .opaque
    }
}

private struct SurfaceModifier: ViewModifier {
    let theme: NativeDesignTheme
    let metrics: NativeSurfaceMetrics
    let style: NativeSurfaceStyle
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    @ViewBuilder func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: metrics.cornerRadius, style: .continuous)
        if #available(iOS 26, macOS 26, *), style.usesGlass(supported: true, reduceTransparency: reduceTransparency) {
            if style == .interactiveGlass {
                content.glassEffect(.regular.tint(theme.surfaceRaised).interactive(), in: shape)
            } else {
                content.glassEffect(.regular.tint(theme.surfaceRaised), in: shape)
            }
        } else {
            content.background(shape.fill(theme.surfaceRaised))
                .overlay(shape.strokeBorder(theme.textSecondary.opacity(metrics.borderOpacity),
                                            lineWidth: metrics.borderWidth))
                .shadow(color: theme.textPrimary.opacity(metrics.shadowOpacity),
                        radius: metrics.shadowRadius, x: metrics.shadowX, y: metrics.shadowY)
        }
    }
}

private struct FocusOutlineModifier: ViewModifier {
    let theme: NativeDesignTheme
    let focused: Bool
    let cornerRadius: CGFloat
    let width: CGFloat

    func body(content: Content) -> some View {
        content.overlay(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(theme.statusInfo.opacity(focused ? 1 : 0), lineWidth: width)
            .allowsHitTesting(false).accessibilityHidden(true))
    }
}

public extension View {
    /// Apply after padding and layout. Older OS versions and reduced transparency use an opaque
    /// token surface; token lookup failure is never caught or replaced by another color.
    func nativeSurface(theme: NativeDesignTheme, metrics: NativeSurfaceMetrics,
                       style: NativeSurfaceStyle) -> some View {
        modifier(SurfaceModifier(theme: theme, metrics: metrics, style: style))
    }

    /// Caller binds its native FocusState; the outline adds no focus or gesture ownership.
    func nativeFocusOutline(theme: NativeDesignTheme, focused: Bool,
                            cornerRadius: CGFloat, width: CGFloat) -> some View {
        modifier(FocusOutlineModifier(theme: theme, focused: focused,
                                      cornerRadius: cornerRadius, width: width))
    }
}
