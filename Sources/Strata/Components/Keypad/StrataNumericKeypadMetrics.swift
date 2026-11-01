import DesignTokens
import SwiftUI

/// Shared Class A geometry for compact numeric keypads.
public struct StrataNumericKeypadMetrics: Equatable, Sendable {
    public let totalGridHeight: CGFloat
    public let horizontalPadding: CGFloat
    public let verticalPadding: CGFloat
    public let interColumnSpacing: CGFloat
    public let interRowSpacing: CGFloat
    public let sideColumnWidth: CGFloat
    public let compactCellRadius: CGFloat
    public let digitRowHeight: CGFloat
    public let minimumScaleFactor: CGFloat

    public init(
        spacing: (String) throws -> Double = StyleTokens.spacing,
        radius: (String) throws -> Double = StyleTokens.radius
    ) throws {
        totalGridHeight = 232
        horizontalPadding = 12
        verticalPadding = 6
        interColumnSpacing = CGFloat(try spacing("spacing.sm"))
        interRowSpacing = CGFloat(try spacing("spacing.sm"))
        sideColumnWidth = 68
        compactCellRadius = CGFloat(try radius("radius.small"))
        digitRowHeight = (totalGridHeight - (verticalPadding * 2) - (interRowSpacing * 3)) / 4
        minimumScaleFactor = 0.85
    }

    public func actionHeight(forCount count: Int) -> CGFloat {
        guard count > 0 else { return 0 }
        return (totalGridHeight - (verticalPadding * 2) - (interRowSpacing * CGFloat(count - 1))) / CGFloat(count)
    }
}
