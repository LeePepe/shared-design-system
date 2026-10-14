import SwiftUI

/// Pure role model for NativeCard styling.
enum NativeCardRoleModel {
    static let backgroundRole: SemanticTokenRole = .surfaceRaised
    static let foregroundRole: SemanticTokenRole = .textPrimary
}

/// Generic presentation container with raised-surface background and primary foreground styling.
public struct NativeCard<Content: View>: View {
    private let theme: NativeDesignTheme
    private let content: Content

    /// Creates a card with explicit theme and caller-owned content.
    public init(
        theme: NativeDesignTheme,
        @ViewBuilder content: () -> Content
    ) {
        self.theme = theme
        self.content = content()
    }

    public var body: some View {
        content
            .foregroundColor(theme.color(for: NativeCardRoleModel.foregroundRole))
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(theme.color(for: NativeCardRoleModel.backgroundRole))
            )
    }
}
