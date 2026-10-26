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
            Button {
                guard !isDisabled else { return }
                selection = item.id
            } label: {
                HStack(alignment: .center, spacing: StrataComponentMetrics.spacingSM) {
                    Text(item.title)
                        .fixedSize(horizontal: false, vertical: true)
                    if let badgeCount = item.badgeCount, badgeCount > 0 {
                        Text("\(badgeCount)")
                            .font(.caption.weight(.semibold))
                            .monospacedDigit()
                            .padding(.horizontal, StrataComponentMetrics.spacingSM)
                            .frame(minHeight: StrataComponentMetrics.spacingMD)
                            .foregroundStyle(isSelected ? theme.accent : theme.onAccent)
                            .background(
                                (isSelected ? theme.onAccent : theme.accent),
                                in: Capsule()
                            )
                            .accessibilityLabel("\(badgeCount)")
                    }
                }
                .font(.callout.weight(.semibold))
                .frame(
                    minWidth: axis == .vertical
                        ? StrataComponentMetrics.verticalItemWidth
                        : StrataComponentMetrics.minimumHit,
                    minHeight: StrataComponentMetrics.minimumHit,
                    alignment: axis == .vertical ? .leading : .center
                )
                .padding(.horizontal, StrataComponentMetrics.spacingMD)
                .foregroundStyle(foreground(isSelected: isSelected))
                .background(
                    isSelected ? theme.accent : theme.surface(.card),
                    in: RoundedRectangle(
                        cornerRadius: StrataComponentMetrics.controlRadius,
                        style: .continuous
                    )
                )
            }
            .buttonStyle(.plain)
            .disabled(isDisabled)
            .accessibilityValue(accessibilityValue(for: item, isSelected: isSelected))
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
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

    private func accessibilityValue(
        for item: StrataSegmentedItem,
        isSelected: Bool
    ) -> Text {
        if let badgeCount = item.badgeCount, badgeCount > 0 {
            return Text(isSelected ? "Selected, \(badgeCount)" : "\(badgeCount)")
        }
        return Text(isSelected ? "Selected" : "")
    }
}
