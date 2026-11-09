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

public struct StrataComponentMetrics: Equatable, Sendable {
    public let cardRadius: CGFloat
    public let controlRadius: CGFloat
    public let compactCellRadius: CGFloat
    public let minimumHit: CGFloat
    public let verticalItemWidth: CGFloat
    public let spacingXS: CGFloat
    public let spacingSM: CGFloat
    public let spacingMD: CGFloat
    public let spacingLG: CGFloat
    public let spacingXL: CGFloat
    public let borderRegular: CGFloat

    public init(
        dimension: (String) throws -> Double = StyleTokens.dimension,
        spacing: (String) throws -> Double = StyleTokens.spacing,
        radius: (String) throws -> Double = StyleTokens.radius,
        border: (String) throws -> Double = StyleTokens.border
    ) throws {
        let minimumHit = CGFloat(try dimension("dimension.hit.minimum"))
        let spacingXS = CGFloat(try spacing("spacing.xs"))
        let spacingSM = CGFloat(try spacing("spacing.sm"))
        let spacingMD = CGFloat(try spacing("spacing.md"))
        let spacingLG = CGFloat(try spacing("spacing.lg"))
        let spacingXL = CGFloat(try spacing("spacing.xl"))
        let radiusMedium = CGFloat(try radius("radius.medium"))
        let radiusLarge = CGFloat(try radius("radius.large"))
        let compactCellRadius = CGFloat(try radius("radius.small"))
        let borderRegular = CGFloat(try border("border.regular"))

        self.minimumHit = minimumHit
        self.spacingXS = spacingXS
        self.spacingSM = spacingSM
        self.spacingMD = spacingMD
        self.spacingLG = spacingLG
        self.spacingXL = spacingXL
        self.cardRadius = radiusLarge + spacingXS
        self.controlRadius = radiusMedium + spacingXS
        self.compactCellRadius = compactCellRadius
        self.verticalItemWidth = minimumHit + spacingXL + spacingSM
        self.borderRegular = borderRegular
    }
}

public extension VerticalAlignment {
    static let strataControlCenter = VerticalAlignment(
        StrataControlCenterAlignment.self
    )

    static let strataInputBaseline = VerticalAlignment(
        StrataInputBaselineAlignment.self
    )
}

private enum StrataControlCenterAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[VerticalAlignment.center]
    }
}

private enum StrataInputBaselineAlignment: AlignmentID {
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
        context[.firstTextBaseline]
    }
}
