import SwiftUI

/// Material is independent from the explicit theme and brand.
public enum NativeSurfaceStyle: Equatable, Sendable {
    case solid
    case glass
}

/// Neutral surfaces retain their role when material is reduced or disabled.
public enum NativeSurfaceRole: Equatable, Sendable {
    case region
    case card
    case inset
    case hover
    case selected
}

/// Internal test input; production follows the read-only system preference.
struct NativeReduceTransparencyOverrideKey: EnvironmentKey {
    static let defaultValue: Bool? = nil
}

private struct NativeMaterialAncestorKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var nativeReduceTransparencyOverride: Bool? {
        get { self[NativeReduceTransparencyOverrideKey.self] }
        set { self[NativeReduceTransparencyOverrideKey.self] = newValue }
    }
    fileprivate var nativeMaterialAncestor: Bool {
        get { self[NativeMaterialAncestorKey.self] }
        set { self[NativeMaterialAncestorKey.self] = newValue }
    }
}

/// Separates readable fills from a single inherited native blur.
struct NativeSurfaceTreatment: Equatable {
    static let legacyReadingOpacity = 0.94
    let glass: Bool
    let blur: Bool
    let decoration: Bool

    init(style: NativeSurfaceStyle, role: NativeSurfaceRole?, reduceTransparency: Bool, materialAncestor: Bool) {
        let floating = role == nil || role == .region || role == .card
        glass = style == .glass && !reduceTransparency && floating
        blur = glass && !materialAncestor
        decoration = glass && role != nil
    }
}

struct NativeSurfaceModifier: ViewModifier {
    let theme: NativeDesignTheme
    let style: NativeSurfaceStyle
    let cornerRadius: CGFloat
    let role: NativeSurfaceRole?
    @Environment(\.accessibilityReduceTransparency) private var systemReduceTransparency
    @Environment(\.nativeReduceTransparencyOverride) private var reduceTransparencyOverride
    @Environment(\.nativeMaterialAncestor) private var materialAncestor

    private var treatment: NativeSurfaceTreatment {
        NativeSurfaceTreatment(style: style, role: role,
                               reduceTransparency: reduceTransparencyOverride ?? systemReduceTransparency,
                               materialAncestor: materialAncestor)
    }
    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    func body(content: Content) -> some View {
        content
            .foregroundStyle(theme.foreground)
            .environment(\.nativeMaterialAncestor, treatment.glass || materialAncestor)
            .background {
                if let role {
                    roleBackground(role)
                } else if treatment.glass {
                    // Existing callers retain their unadorned material treatment.
                    shape.fill(.regularMaterial)
                        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
                } else {
                    shape.fill(role.map(theme.surface) ?? theme.surface)
                }
            }
    }

    @ViewBuilder
    private func roleBackground(_ role: NativeSurfaceRole) -> some View {
        if treatment.glass {
            ZStack {
                if treatment.blur {
                    shape.fill(.regularMaterial)
                        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
                }
                shape.fill(role == .region ? theme.material.panel : theme.material.content)
                shape.strokeBorder(role == .region ? theme.material.edge : theme.material.innerEdge, lineWidth: 1)
                shape.strokeBorder(
                    LinearGradient(colors: [theme.material.highlight.opacity(role == .region ? 1 : 0.4), theme.material.highlight.opacity(0)],
                                   startPoint: .topLeading, endPoint: .center), lineWidth: 1)
            }
            .shadow(color: role == .region ? theme.material.shadow : theme.material.shadow.opacity(0),
                    radius: 12, x: 0, y: 4)
        } else {
            shape.fill(theme.surface(role))
        }
    }
}

extension View {
    func nativeSurface(theme: NativeDesignTheme, style: NativeSurfaceStyle,
                       cornerRadius: CGFloat, role: NativeSurfaceRole? = nil) -> some View {
        modifier(NativeSurfaceModifier(theme: theme, style: style, cornerRadius: cornerRadius, role: role))
    }
}
