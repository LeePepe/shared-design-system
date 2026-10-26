import SwiftUI

/// A noninteractive surface that gives caller-owned content a readable hierarchy.
///
/// The caller owns every view, action and accessibility label inside the card.
/// The card does not imply selection, navigation or activation.
public struct StrataCard<Header: View, Content: View, Supporting: View, Actions: View>: View {
    private let theme: StrataTheme
    private let surface: StrataSurfaceStyle
    private let header: Header
    private let content: Content
    private let supporting: Supporting
    private let actions: Actions

    /// Creates a card with an explicit theme, material and four semantic slots.
    /// Pass `EmptyView` for a slot that is not needed.
    public init(
        theme: StrataTheme,
        surface: StrataSurfaceStyle,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content,
        @ViewBuilder supporting: () -> Supporting,
        @ViewBuilder actions: () -> Actions
    ) {
        self.theme = theme
        self.surface = surface
        self.header = header()
        self.content = content()
        self.supporting = supporting()
        self.actions = actions()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
                .font(.headline)
                .foregroundStyle(theme.foreground)
                .accessibilityAddTraits(.isHeader)
            content
                .font(.body)
                .foregroundStyle(theme.foreground)
            supporting
                .font(.subheadline)
                .foregroundStyle(theme.secondaryForeground)
            actions
                .font(.body)
                .foregroundStyle(theme.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .strataSurface(theme: theme, style: surface, cornerRadius: 24, role: .card)
    }
}

public extension StrataCard where Header == EmptyView, Supporting == EmptyView, Actions == EmptyView {
    /// Creates a plain content card without introducing empty semantic sections.
    init(
        theme: StrataTheme,
        surface: StrataSurfaceStyle,
        @ViewBuilder content: () -> Content
    ) {
        self.init(theme: theme, surface: surface) {
            EmptyView()
        } content: {
            content()
        } supporting: {
            EmptyView()
        } actions: {
            EmptyView()
        }
    }
}
