import SwiftUI

public struct StrataSegmentedItem: Identifiable, Sendable, Equatable {
    public let id: String
    public let title: String
    public let badgeCount: Int?

    public init(id: String, title: String, badgeCount: Int? = nil) {
        self.id = id
        self.title = title
        self.badgeCount = badgeCount
    }
}

public struct StrataSegmentedBar: View {
    public enum Axis: Sendable {
        case horizontal
        case vertical
    }

    private let theme: StrataTheme
    private let items: [StrataSegmentedItem]
    @Binding private var selection: String
    private let axis: Axis
    private let isDisabled: Bool

    public init(
        theme: StrataTheme,
        items: [StrataSegmentedItem],
        selection: Binding<String>,
        axis: Axis = .horizontal,
        isDisabled: Bool = false
    ) {
        self.theme = theme
        self.items = items
        self._selection = selection
        self.axis = axis
        self.isDisabled = isDisabled
    }

    public var body: some View {
        Group {
            switch axis {
            case .horizontal:
                HStack(spacing: StrataComponentMetrics.spacingSM) {
                    itemViews
                }
            case .vertical:
                VStack(spacing: StrataComponentMetrics.spacingSM) {
                    itemViews
                }
            }
        }
        .padding(StrataComponentMetrics.spacingSM)
        .background(theme.surface(.inset), in: shape)
        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
    }

    @ViewBuilder
    private var itemViews: some View {
        ForEach(items) { item in
            let isSelected = item.id == selection
            let itemAccessibilityIdentifier =
                "segmented-\(axis == .vertical ? "vertical" : "horizontal")-\(item.id)"
            let itemAccessibilityValue = Self.accessibilityValue(for: item.badgeCount)
            Button {
                guard !isDisabled else { return }
                selection = item.id
            } label: {
                itemLabel(item, isSelected: isSelected)
            }
            .buttonStyle(.plain)
            .disabled(isDisabled)
            .accessibilityLabel(item.title)
            .accessibilityIdentifier(itemAccessibilityIdentifier)
            .accessibilityValue(itemAccessibilityValue)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
    }

    @ViewBuilder
    private func itemLabel(_ item: StrataSegmentedItem, isSelected: Bool) -> some View {
        let horizontalPadding = axis == .vertical
            ? StrataComponentMetrics.spacingSM
            : StrataComponentMetrics.spacingMD
        HStack(alignment: .center, spacing: StrataComponentMetrics.spacingSM) {
            Text(item.title)
                .fixedSize(horizontal: false, vertical: true)
            if let badgeCount = item.badgeCount, badgeCount > 0 {
                Text(verbatim: String(badgeCount))
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
                    .padding(.horizontal, StrataComponentMetrics.spacingSM)
                    .frame(minHeight: StrataComponentMetrics.spacingMD)
                    .foregroundStyle(badgeForeground(isSelected: isSelected))
                    .background(
                        badgeBackground(isSelected: isSelected),
                        in: Capsule()
                    )
                    .accessibilityHidden(true)
            }
        }
        .font(.callout.weight(.semibold))
        .lineLimit(axis == .vertical ? 2 : nil)
        .minimumScaleFactor(1)
        .padding(.horizontal, horizontalPadding)
        .frame(
            minWidth: axis == .vertical
                ? StrataComponentMetrics.verticalItemWidth
                : StrataComponentMetrics.minimumHit,
            minHeight: StrataComponentMetrics.minimumHit,
            alignment: axis == .vertical ? .leading : .center
        )
        .foregroundStyle(foreground(isSelected: isSelected))
        .background(
            background(isSelected: isSelected),
            in: RoundedRectangle(
                cornerRadius: StrataComponentMetrics.controlRadius,
                style: .continuous
            )
        )
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: StrataComponentMetrics.controlRadius,
            style: .continuous
        )
    }

    private func foreground(isSelected: Bool) -> Color {
        if isDisabled {
            return theme.secondaryForeground
        }
        return isSelected ? theme.onAccent : theme.foreground
    }

    private func background(isSelected: Bool) -> Color {
        if isSelected && isDisabled {
            return theme.surface(.selected)
        }
        return isSelected ? theme.accent : theme.surface(.card)
    }

    private func badgeForeground(isSelected: Bool) -> Color {
        if isDisabled && isSelected {
            return theme.secondaryForeground
        }
        return isSelected ? theme.accent : theme.onAccent
    }

    private func badgeBackground(isSelected: Bool) -> Color {
        if isDisabled && isSelected {
            return theme.surface(.inset)
        }
        return isSelected ? theme.onAccent : theme.accent
    }

    nonisolated static func accessibilityValue(for badgeCount: Int?) -> String {
        guard let badgeCount, badgeCount > 0 else { return "" }
        return "\(badgeCount)"
    }
}
