import DesignTokens
import NativeDesignKit
import SwiftUI

public enum SamplePalette {
    public static func color(_ id: String, theme: Theme) throws -> Color {
        try NativeTokenColor.resolve(id, theme: theme)
    }

    public static func makeTheme(theme: Theme) throws -> NativeDesignTheme {
        try NativeDesignTheme(theme: theme)
    }

    @MainActor
    public static func makeCard<Content: View>(
        theme: NativeDesignTheme,
        @ViewBuilder content: () -> Content
    ) -> NativeCard<Content> {
        NativeCard(theme: theme, content: content)
    }
}
