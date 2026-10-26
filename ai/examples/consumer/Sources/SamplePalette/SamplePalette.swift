import DesignTokens
import Strata
import SwiftUI

public enum SamplePalette {
    public static func color(_ id: String, theme: Theme) throws -> Color {
        try StrataTokenColor.resolve(id, theme: theme)
    }
}
