import DesignTokens
import SwiftUI

/// Token-backed geometry for dense, single-axis data-entry rows.
public struct StrataTabularRowMetrics: Equatable, Sendable {
    public let indexWidth: CGFloat
    public let checkboxHitTarget: CGFloat
    public let minimumRowHeight: CGFloat
    public let controlSpacing: CGFloat
    public let compactBadgeHeight: CGFloat
    public let compactCellRadius: CGFloat
    public let borderHairline: CGFloat

    public init(
        dimension: (String) throws -> Double = StyleTokens.dimension,
        spacing: (String) throws -> Double = StyleTokens.spacing,
        radius: (String) throws -> Double = StyleTokens.radius,
        border: (String) throws -> Double = StyleTokens.border
    ) throws {
        indexWidth = CGFloat(try dimension("dimension.icon.small"))
        checkboxHitTarget = CGFloat(try dimension("dimension.hit.minimum"))
        minimumRowHeight = checkboxHitTarget
        controlSpacing = CGFloat(try spacing("spacing.sm"))
        compactBadgeHeight = CGFloat(try spacing("spacing.xl"))
        compactCellRadius = CGFloat(try radius("radius.small"))
        borderHairline = CGFloat(try border("border.hairline"))
    }
}

/// A compact metadata hint that stays on the input's axis instead of adding a banner row.
public struct StrataInlineHint: View {
    private let theme: StrataTheme
    private let label: String
    private let hint: String

    public init(theme: StrataTheme, label: String, hint: String) {
        self.theme = theme
        self.label = label
        self.hint = hint
    }

    public var body: some View {
        Text(hint)
            .font(.caption)
            .foregroundStyle(theme.accent.opacity(0.65))
            .lineLimit(1)
            .accessibilityLabel(label)
            .accessibilityValue(hint)
            .accessibilityHint("Displayed inline in the input row")
    }
}

/// Omits an inactive dock slot from layout rather than reserving transparent height.
public struct StrataBottomSlot<Content: View>: View {
    private let isActive: Bool
    private let content: Content

    public init(isActive: Bool, @ViewBuilder content: () -> Content) {
        self.isActive = isActive
        self.content = content()
    }

    @ViewBuilder
    public var body: some View {
        if isActive {
            content
        } else {
            EmptyView()
        }
    }
}
