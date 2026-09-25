import DesignTokens
import NativeDesignKit
import SwiftUI

public enum SamplePalette {
    public static func color(_ id: String, theme: Theme) throws -> Color {
        try NativeTokenColor.resolve(id, theme: theme)
    }
}
