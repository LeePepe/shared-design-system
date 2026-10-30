import DesignTokens
import SwiftUI

/// A compact, opaque section header designed to remain readable when pinned.
public struct StrataStickySectionHeader<Accessory: View>: View {
    private let theme: StrataTheme
    private let index: Int
    private let completedCount: Int
    private let totalCount: Int
    private let title: String
    private let isLargeMode: Bool
    private let hairlineHeight: CGFloat
    private let accessory: Accessory

    public init(
        theme: StrataTheme,
        index: Int,
        completedCount: Int,
        totalCount: Int,
        title: String,
        isLargeMode: Bool = false,
        border: (String) throws -> Double = StyleTokens.border,
        @ViewBuilder accessory: () -> Accessory
    ) throws {
        self.theme = theme
        self.index = index
        self.completedCount = completedCount
        self.totalCount = totalCount
        self.title = title
        self.isLargeMode = isLargeMode
        self.hairlineHeight = CGFloat(try border("border.hairline"))
        self.accessory = accessory()
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 8) {
            badge
            Text(title)
                .font(isLargeMode ? .title3.weight(.semibold) : .headline)
                .foregroundStyle(theme.foreground)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
            accessory
                .foregroundStyle(theme.foreground)
                .fixedSize()
        }
        .padding(.vertical, 4)
        .frame(minHeight: 36)
        .background(theme.surface)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.secondaryForeground.opacity(0.24))
                .frame(height: hairlineHeight)
        }
        .accessibilityAddTraits(.isHeader)
        .accessibilityValue("\(completedCount) of \(totalCount) completed")
        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
    }

    private var badge: some View {
        let isCompleted = totalCount > 0 && completedCount >= totalCount
        return ZStack {
            Circle()
                .fill(isCompleted ? theme.success : theme.surface(.selected))
            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(theme.onAccent)
            } else {
                Text("\(index)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(theme.foreground)
            }
        }
        .frame(width: 28, height: 28)
        .accessibilityLabel(isCompleted ? "Completed section \(index)" : "Section \(index)")
    }
}
