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
    private let metrics: StrataComponentMetrics

    public init(
        theme: StrataTheme,
        items: [StrataSegmentedItem],
        selection: Binding<String>,
        axis: Axis = .horizontal,
        isDisabled: Bool = false
    ) throws {
        self.theme = theme
        self.items = items
        self._selection = selection
        self.axis = axis
        self.isDisabled = isDisabled
        self.metrics = try StrataComponentMetrics()
    }

    public init(
        theme: StrataTheme,
        items: [StrataSegmentedItem],
        selection: Binding<String>,
        axis: Axis = .horizontal,
        isDisabled: Bool = false,
        metrics: StrataComponentMetrics
    ) {
        self.theme = theme
        self.items = items
        self._selection = selection
        self.axis = axis
        self.isDisabled = isDisabled
        self.metrics = metrics
    }

    public var body: some View {
        Group {
            switch axis {
            case .horizontal:
                HStack(spacing: metrics.spacingSM) {
                    itemViews
                }
            case .vertical:
                VStack(spacing: metrics.spacingSM) {
                    itemViews
                }
            }
        }
        .padding(metrics.spacingSM)
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
        let isVertical = axis == .vertical
        let horizontalPadding = isVertical ? metrics.spacingSM : metrics.spacingMD
        let itemContent = HStack(
            alignment: .center,
            spacing: isVertical ? metrics.spacingXS : metrics.spacingSM
        ) {
            Text(item.title)
                .font(isVertical ? .subheadline.weight(.semibold) : .callout.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
            if let badgeCount = item.badgeCount, badgeCount > 0 {
                Text(verbatim: String(badgeCount))
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
                    .padding(.horizontal, isVertical ? metrics.spacingXS : metrics.spacingSM)
                    .frame(minHeight: metrics.spacingMD)
                    .foregroundStyle(badgeForeground(isSelected: isSelected))
                    .background(
                        badgeBackground(isSelected: isSelected),
                        in: Capsule()
                    )
                    .accessibilityHidden(true)
            }
        }
        let paddedContent = itemContent
            .lineLimit(isVertical ? 2 : nil)
            .minimumScaleFactor(1)
            .padding(.horizontal, horizontalPadding)
        Group {
            if isVertical {
                    paddedContent
                        .frame(
                            width: metrics.verticalItemWidth,
                            alignment: .leading
                        )
                        .frame(minHeight: metrics.minimumHit, alignment: .leading)
            } else {
                paddedContent
                    .frame(
                        minWidth: metrics.minimumHit,
                        minHeight: metrics.minimumHit,
                        alignment: .center
                    )
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .foregroundStyle(foreground(isSelected: isSelected))
        .background(
            background(isSelected: isSelected),
            in: RoundedRectangle(
                cornerRadius: metrics.controlRadius,
                style: .continuous
            )
        )
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(
            cornerRadius: metrics.controlRadius,
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
