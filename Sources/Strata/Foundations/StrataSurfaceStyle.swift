import SwiftUI

/// Material is independent from the explicit theme and brand.
public enum StrataSurfaceStyle: Equatable, Sendable {
    case solid
    case glass
}

/// Neutral surfaces retain their role when material is reduced or disabled.
public enum StrataSurfaceRole: Equatable, Sendable {
    case region
    case card
    case inset
    case hover
    case selected
}

/// Internal test input; production follows the read-only system preference.
struct StrataReduceTransparencyOverrideKey: EnvironmentKey {
    static let defaultValue: Bool? = nil
}

private struct StrataMaterialAncestorKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var nativeReduceTransparencyOverride: Bool? {
        get { self[StrataReduceTransparencyOverrideKey.self] }
        set { self[StrataReduceTransparencyOverrideKey.self] = newValue }
    }
    fileprivate var nativeMaterialAncestor: Bool {
        get { self[StrataMaterialAncestorKey.self] }
        set { self[StrataMaterialAncestorKey.self] = newValue }
    }
}

/// Separates readable fills from a single inherited native blur.
struct StrataSurfaceTreatment: Equatable {
    static let legacyReadingOpacity = 0.94
    let glass: Bool
    let blur: Bool
    let decoration: Bool

    init(style: StrataSurfaceStyle, role: StrataSurfaceRole?, reduceTransparency: Bool, materialAncestor: Bool) {
        let floating = role == nil || role == .region || role == .card
        glass = style == .glass && !reduceTransparency && floating
        blur = glass && !materialAncestor
        decoration = glass && role != nil
    }
}

/// One outer material layer; readable content inherits an opaque token foreground.
public struct StrataSurfaceModifier: ViewModifier {
    public let theme: StrataTheme
    public let style: StrataSurfaceStyle
    public let cornerRadius: CGFloat
    public let role: StrataSurfaceRole?
    @Environment(\.accessibilityReduceTransparency) private var systemReduceTransparency
    @Environment(\.nativeReduceTransparencyOverride) private var reduceTransparencyOverride
    @Environment(\.nativeMaterialAncestor) private var materialAncestor

    private var treatment: StrataSurfaceTreatment {
        StrataSurfaceTreatment(style: style, role: role,
                               reduceTransparency: reduceTransparencyOverride ?? systemReduceTransparency,
                               materialAncestor: materialAncestor)
    }
    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    public init(theme: StrataTheme, style: StrataSurfaceStyle, cornerRadius: CGFloat,
                role: StrataSurfaceRole? = nil) {
        self.theme = theme
        self.style = style
        self.cornerRadius = cornerRadius
        self.role = role
    }

    public func body(content: Content) -> some View {
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
    private func roleBackground(_ role: StrataSurfaceRole) -> some View {
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
    public func strataSurface(theme: StrataTheme, style: StrataSurfaceStyle,
                              cornerRadius: CGFloat, role: StrataSurfaceRole? = nil) -> some View {
        modifier(StrataSurfaceModifier(theme: theme, style: style, cornerRadius: cornerRadius, role: role))
    }
}
