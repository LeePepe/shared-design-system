import DesignTokens
import SwiftUI

/// An immutable snapshot resolved for one explicit theme and provider brand.
public struct StrataTheme {
    public let mode: Theme
    public let canvas: Color
    public let surface: Color
    public let foreground: Color
    public let secondaryForeground: Color
    public let accent: Color
    public let onAccent: Color
    public let critical: Color
    public let onCritical: Color
    public let brandSeed: Color
    public let brandSeedInk: Color
    public let brandText: Color
    public let accentHover: Color
    public let accentActive: Color
    public let accentSubtle: Color
    public let success: Color
    public let successSurface: Color
    public let chartPrimary: Color
    private let region: Color
    private let inset: Color
    private let hover: Color
    private let selected: Color
    let isStrata: Bool
    let material: StrataMaterialColors

    /// Resolves fresh values from the exact DesignTokens dependency.
    /// Unknown brands and token errors propagate unchanged.
    public init(theme: Theme, brand: String) throws {
        try self.init(theme: theme, brand: brand, color: StrataTokenColor.resolve,
                      brandColor: { brand, role, theme in
            StrataTokenColor.color(from: try DesignTokens.brandColor(brand, role: role, theme: theme))
        })
    }

    /// Returns an opaque provider surface for caller-owned composition.
    public func surface(_ role: StrataSurfaceRole) -> Color {
        switch role {
        case .region: region
        case .card: surface
        case .inset: inset
        case .hover: hover
        case .selected: selected
        }
    }

    init(theme: Theme, brand: String,
         color: (String, Theme) throws -> Color,
         brandColor: (String, BrandRole, Theme) throws -> Color) throws {
        mode = theme
        let family: String?
        switch brand {
        case "strata-blue": family = "blue"
        case "strata-green": family = "green"
        case "strata-pink": family = "pink"
        case "strata-yellow": family = "yellow"
        case "strata-purple": family = "purple"
        default: family = nil
        }
        isStrata = family != nil
        if let family {
            // Brand validation remains the provider's responsibility.
            accent = try brandColor(brand, .accent, theme)
            onAccent = try brandColor(brand, .onAccent, theme)
            let prefix = "product.strata.\(family)."
            let brandPrefix = "brand.\(brand)."
            canvas = try color(prefix + "surface.page", theme)
            surface = try color(prefix + "surface.card", theme)
            region = try color(prefix + "surface.region", theme)
            inset = try color(prefix + "surface.inset", theme)
            hover = try color(prefix + "surface.hover", theme)
            selected = try color(prefix + "surface.selected", theme)
            foreground = try color("product.strata.text.primary", theme)
            secondaryForeground = try color("product.strata.text.secondary", theme)
            brandSeed = try color(brandPrefix + "seed", theme)
            brandSeedInk = try color(brandPrefix + "seed-ink", theme)
            brandText = try color(brandPrefix + "text", theme)
            accentHover = try color(brandPrefix + "hover", theme)
            accentActive = try color(brandPrefix + "active", theme)
            accentSubtle = try color(brandPrefix + "subtle", theme)
            success = try color("status.strata.success", theme)
            successSurface = try color("status.strata.success-surface", theme)
            chartPrimary = try color("product.strata.chart.primary", theme)
            critical = try color("status.strata.error", theme)
            onCritical = try color("status.strata.error-surface", theme)
            material = try StrataMaterialColors(prefix: prefix, theme: theme, color: color)
        } else {
            // Preserve the legacy lookup sequence and values, including exact errors.
            canvas = try color("product.surface.canvas", theme)
            surface = try color("product.surface.raised", theme)
            foreground = try color("product.text.primary", theme)
            secondaryForeground = try color("product.text.secondary", theme)
            accent = try brandColor(brand, .accent, theme)
            onAccent = try brandColor(brand, .onAccent, theme)
            critical = try color("status.critical", theme)
            onCritical = try color("status.on-critical", theme)
            region = surface; inset = surface; hover = surface; selected = surface
            brandSeed = accent; brandSeedInk = onAccent; brandText = accent
            accentHover = accent; accentActive = accent; accentSubtle = surface
            // Additional brand-independent semantics are explicit provider roles.
            // Existing legacy colors and their resolution order are unchanged.
            success = try color("status.strata.success", theme)
            successSurface = try color("status.strata.success-surface", theme)
            chartPrimary = try color("product.strata.chart.primary", theme)
            material = try StrataMaterialColors(legacy: surface, foreground: foreground, theme: theme, color: color)
        }
    }
}

struct StrataMaterialColors {
    let panel: Color
    let content: Color
    let control: Color
    let edge: Color
    let highlight: Color
    let innerEdge: Color
    let shadow: Color
    let ambient: Color
    let ambientSoft: Color
    let ambientEdge: Color

    init(prefix: String, theme: Theme, color: (String, Theme) throws -> Color) throws {
        panel = try color(prefix + "material.panel", theme)
        content = try color(prefix + "material.content", theme)
        control = try color(prefix + "material.control", theme)
        edge = try color("product.strata.material.edge", theme)
        highlight = try color("product.strata.material.highlight", theme)
        innerEdge = try color("product.strata.material.inner-edge", theme)
        shadow = try color("product.strata.material.shadow", theme)
        ambient = try color(prefix + "material.ambient", theme)
        ambientSoft = try color(prefix + "material.ambient-soft", theme)
        ambientEdge = try color(prefix + "material.ambient-edge", theme)
    }

    init(legacy: Color, foreground: Color, theme: Theme,
         color: (String, Theme) throws -> Color) throws {
        panel = legacy.opacity(theme == .light ? 0.62 : 0.72)
        // Worst-case black/light and white/dark backdrops retain >=4.5 secondary contrast.
        content = legacy.opacity(StrataSurfaceTreatment.legacyReadingOpacity)
        control = legacy
        edge = try color("product.strata.material.edge", theme)
        highlight = try color("product.strata.material.highlight", theme)
        innerEdge = try color("product.strata.material.inner-edge", theme)
        shadow = try color("product.strata.material.shadow", theme)
        ambient = foreground.opacity(0); ambientSoft = foreground.opacity(0); ambientEdge = foreground.opacity(0)
    }
}
