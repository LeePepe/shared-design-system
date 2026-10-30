import SwiftUI

/// A borderless semantic heading with optional supporting content and actions.
public struct StrataSectionHeader<TrailingContent: View>: View {
    private let theme: StrataTheme
    private let title: String
    private let subtitle: String?
    private let badgeText: String?
    private let trailing: TrailingContent

    public init(
        theme: StrataTheme,
        title: String,
        subtitle: String? = nil,
        badgeText: String? = nil,
        @ViewBuilder trailing: () -> TrailingContent
    ) {
        self.theme = theme
        self.title = title
        self.subtitle = subtitle
        self.badgeText = badgeText
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(
            alignment: (subtitle == nil || subtitle?.isEmpty == true) ? .center : .firstTextBaseline,
            spacing: 8
        ) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(theme.foreground)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    if let badgeText, !badgeText.isEmpty {
                        Text(badgeText)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(theme.secondaryForeground)
                            .lineLimit(1)
                    }
                }
                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(theme.secondaryForeground)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            trailing
                .foregroundStyle(theme.foreground)
                .fixedSize()
        }
        .frame(height: 44, alignment: .center)
        .background(theme.surface)
        .accessibilityAddTraits(.isHeader)
        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
    }
}
