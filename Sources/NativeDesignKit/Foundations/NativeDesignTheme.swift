import DesignTokens
import SwiftUI

/// An immutable snapshot resolved for one explicit theme and provider brand.
public struct NativeDesignTheme {
    public let mode: Theme
    public let canvas: Color
    public let surface: Color
    public let foreground: Color
    public let secondaryForeground: Color
    public let accent: Color
    public let onAccent: Color
    public let critical: Color
    public let onCritical: Color

    /// Resolves fresh values from the exact DesignTokens dependency.
    /// Unknown brands and token errors propagate unchanged.
    public init(theme: Theme, brand: String) throws {
        try self.init(
            theme: theme,
            brand: brand,
            color: NativeTokenColor.resolve,
            brandColor: { brand, role, theme in
                NativeTokenColor.color(from: try DesignTokens.brandColor(brand, role: role, theme: theme))
            }
        )
    }

    init(
        theme: Theme,
        brand: String,
        color: (String, Theme) throws -> Color,
        brandColor: (String, BrandRole, Theme) throws -> Color
    ) throws {
        mode = theme
        canvas = try color("product.surface.canvas", theme)
        surface = try color("product.surface.raised", theme)
        foreground = try color("product.text.primary", theme)
        secondaryForeground = try color("product.text.secondary", theme)
        accent = try brandColor(brand, .accent, theme)
        onAccent = try brandColor(brand, .onAccent, theme)
        critical = try color("status.critical", theme)
        onCritical = try color("status.on-critical", theme)
    }
}
