import SwiftUI

/// A caller-owned floating container for controls docked near a screen edge.
public struct StrataDockedBar<Content: View>: View {
    private let theme: StrataTheme
    private let style: StrataSurfaceStyle
    private let content: Content

    public init(
        theme: StrataTheme,
        style: StrataSurfaceStyle = .glass,
        @ViewBuilder content: () -> Content
    ) {
        self.theme = theme
        self.style = style
        self.content = content()
    }

    public var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 32, alignment: .leading)
            .strataSurface(theme: theme, style: style, cornerRadius: 32, role: .region)
            .padding(.horizontal, 12)
            .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
    }
}
