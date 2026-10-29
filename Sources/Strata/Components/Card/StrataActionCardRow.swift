import SwiftUI

/// A card row with one primary body action and one visually separate trailing action.
public struct StrataActionCardRow<Badge: View, TrailingAction: View>: View {
    private let theme: StrataTheme
    private let title: String
    private let subtitle: String?
    private let onPrimaryTap: () -> Void
    private let badge: Badge
    private let trailingAction: TrailingAction

    public init(
        theme: StrataTheme,
        title: String,
        subtitle: String? = nil,
        onPrimaryTap: @escaping () -> Void,
        @ViewBuilder badge: () -> Badge,
        @ViewBuilder trailingAction: () -> TrailingAction
    ) {
        self.theme = theme
        self.title = title
        self.subtitle = subtitle
        self.onPrimaryTap = onPrimaryTap
        self.badge = badge()
        self.trailingAction = trailingAction()
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onPrimaryTap) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(theme.foreground)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .layoutPriority(1)
                        badge
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(theme.secondaryForeground)
                            .fixedSize(horizontal: true, vertical: false)
                    }

                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(theme.secondaryForeground)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)

            trailingAction
                .frame(width: 44, height: 44)
                .clipped()
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .strataSurface(theme: theme, style: .solid, cornerRadius: 16, role: .card)
        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
    }
}

public extension StrataActionCardRow where Badge == EmptyView {
    /// Creates a row without an inline badge.
    init(
        theme: StrataTheme,
        title: String,
        subtitle: String? = nil,
        onPrimaryTap: @escaping () -> Void,
        @ViewBuilder trailingAction: () -> TrailingAction
    ) {
        self.init(
            theme: theme,
            title: title,
            subtitle: subtitle,
            onPrimaryTap: onPrimaryTap,
            badge: { EmptyView() },
            trailingAction: trailingAction
        )
    }
}
