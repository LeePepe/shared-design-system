import DesignTokens
import SwiftUI

/// Converts semantic token colors into explicit-theme SwiftUI colors.
public enum NativeTokenColor {
    /// Resolves through DesignTokens, propagating its errors unchanged.
    public static func resolve(_ id: String, theme: Theme) throws -> SwiftUI.Color {
        color(from: try DesignTokens.color(id, theme: theme))
    }

    /// RGBA channels are encoded sRGB bytes; alpha is already in 0...1.
    static func color(from rgba: RGBA) -> SwiftUI.Color {
        SwiftUI.Color(
            .sRGB,
            red: Double(rgba.r) / 255,
            green: Double(rgba.g) / 255,
            blue: Double(rgba.b) / 255,
            opacity: rgba.a
        )
    }
}
