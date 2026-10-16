import SwiftUI

/// Material is independent from the explicit theme and brand.
public enum NativeSurfaceStyle: Equatable, Sendable {
    case solid
    case glass
}

/// Internal test input; production follows the read-only system preference.
struct NativeReduceTransparencyOverrideKey: EnvironmentKey {
    static let defaultValue: Bool? = nil
}

extension EnvironmentValues {
    var nativeReduceTransparencyOverride: Bool? {
        get { self[NativeReduceTransparencyOverrideKey.self] }
        set { self[NativeReduceTransparencyOverrideKey.self] = newValue }
    }
}

/// One outer material layer; readable content inherits an opaque token foreground.
struct NativeSurfaceModifier: ViewModifier {
    let theme: NativeDesignTheme
    let style: NativeSurfaceStyle
    let cornerRadius: CGFloat
    @Environment(\.accessibilityReduceTransparency) private var systemReduceTransparency
    @Environment(\.nativeReduceTransparencyOverride) private var reduceTransparencyOverride

    private var reduceTransparency: Bool {
        reduceTransparencyOverride ?? systemReduceTransparency
    }

    func body(content: Content) -> some View {
        content
            .foregroundStyle(theme.foreground)
            .background {
                if style == .glass && !reduceTransparency {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.regularMaterial)
                        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
                } else {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(theme.surface)
                }
            }
    }
}

extension View {
    func nativeSurface(
        theme: NativeDesignTheme,
        style: NativeSurfaceStyle,
        cornerRadius: CGFloat
    ) -> some View {
        modifier(NativeSurfaceModifier(theme: theme, style: style, cornerRadius: cornerRadius))
    }
}
