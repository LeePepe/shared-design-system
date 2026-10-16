import SwiftUI

/// Explicit native adaptation inputs. Values are supplied by a caller's reviewed style provider.
/// There is deliberately no default scale or implicit theme.
public struct NativeControlMetrics: Sendable, Equatable {
    public let padding: CGFloat
    public let spacing: CGFloat
    public let cornerRadius: CGFloat
    public let minimumHitSize: CGFloat
    public let iconSize: CGFloat
    public let borderWidth: CGFloat
    public let disabledOpacity: Double

    public init(padding: CGFloat, spacing: CGFloat, cornerRadius: CGFloat,
                minimumHitSize: CGFloat, iconSize: CGFloat, borderWidth: CGFloat,
                disabledOpacity: Double) {
        precondition([padding, spacing, cornerRadius, minimumHitSize, iconSize, borderWidth]
            .allSatisfy { $0.isFinite && $0 >= 0 })
        precondition(disabledOpacity.isFinite && (0...1).contains(disabledOpacity))
        self.padding = padding
        self.spacing = spacing
        self.cornerRadius = cornerRadius
        self.minimumHitSize = minimumHitSize
        self.iconSize = iconSize
        self.borderWidth = borderWidth
        self.disabledOpacity = disabledOpacity
    }
}

public struct NativeSurfaceMetrics: Sendable, Equatable {
    public let cornerRadius: CGFloat
    public let borderWidth: CGFloat
    public let borderOpacity: Double
    public let shadowRadius: CGFloat
    public let shadowX: CGFloat
    public let shadowY: CGFloat
    public let shadowOpacity: Double

    public init(cornerRadius: CGFloat, borderWidth: CGFloat, borderOpacity: Double,
                shadowRadius: CGFloat, shadowX: CGFloat, shadowY: CGFloat,
                shadowOpacity: Double) {
        precondition([cornerRadius, borderWidth, shadowRadius].allSatisfy { $0.isFinite && $0 >= 0 })
        precondition(shadowX.isFinite && shadowY.isFinite)
        precondition([borderOpacity, shadowOpacity].allSatisfy { $0.isFinite && (0...1).contains($0) })
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.borderOpacity = borderOpacity
        self.shadowRadius = shadowRadius
        self.shadowX = shadowX
        self.shadowY = shadowY
        self.shadowOpacity = shadowOpacity
    }
}

/// Maps provider typography onto native Dynamic Type. `lineSpacing` is additional leading,
/// not a fixed frame height; text remains free to grow and wrap.
public struct NativeTypography {
    public let size: CGFloat
    public let relativeTo: Font.TextStyle
    public let weight: Font.Weight
    public let lineSpacing: CGFloat
    public let tracking: CGFloat
    public let monospacedDigits: Bool

    public init(size: CGFloat, relativeTo: Font.TextStyle, weight: Font.Weight,
                lineSpacing: CGFloat, tracking: CGFloat, monospacedDigits: Bool) {
        precondition(size.isFinite && size > 0 && lineSpacing.isFinite && lineSpacing >= 0 && tracking.isFinite)
        self.size = size
        self.relativeTo = relativeTo
        self.weight = weight
        self.lineSpacing = lineSpacing
        self.tracking = tracking
        self.monospacedDigits = monospacedDigits
    }
}

private struct TypographyModifier: ViewModifier {
    let typography: NativeTypography
    @ScaledMetric private var size: CGFloat
    @ScaledMetric private var leading: CGFloat
    @ScaledMetric private var tracking: CGFloat

    init(_ typography: NativeTypography) {
        self.typography = typography
        _size = ScaledMetric(wrappedValue: typography.size, relativeTo: typography.relativeTo)
        _leading = ScaledMetric(wrappedValue: typography.lineSpacing, relativeTo: typography.relativeTo)
        _tracking = ScaledMetric(wrappedValue: typography.tracking, relativeTo: typography.relativeTo)
    }

    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 16, macOS 13, *) {
            styled(content).tracking(tracking)
        } else {
            styled(content)
        }
    }

    @ViewBuilder private func styled(_ content: Content) -> some View {
        if typography.monospacedDigits {
            content.font(.system(size: size, weight: typography.weight)).monospacedDigit()
                .lineSpacing(leading)
        } else {
            content.font(.system(size: size, weight: typography.weight))
                .lineSpacing(leading)
        }
    }
}

public extension View {
    func nativeTypography(_ typography: NativeTypography) -> some View {
        modifier(TypographyModifier(typography))
    }

    /// Enlarges layout and interaction bounds without replacing the child's control semantics.
    func nativeMinimumHitTarget(_ size: CGFloat) -> some View {
        frame(minWidth: size, minHeight: size).contentShape(Rectangle())
    }

    /// A centered readable column. Safe areas, logical alignment and keyboard avoidance remain native.
    func nativeReadableWidth(_ maximum: CGFloat, alignment: Alignment = .center) -> some View {
        frame(maxWidth: maximum, alignment: alignment).frame(maxWidth: .infinity, alignment: alignment)
    }

    /// Allows vertically growing localized text at large accessibility sizes.
    func nativeGrowingText() -> some View {
        lineLimit(nil).fixedSize(horizontal: false, vertical: true)
    }
}

/// Text-specific adaptation preserves tracking on iOS 15 and macOS 12 as well.
private struct TypographyText: View {
    let text: Text
    let typography: NativeTypography
    @ScaledMetric private var size: CGFloat
    @ScaledMetric private var leading: CGFloat
    @ScaledMetric private var tracking: CGFloat

    init(text: Text, typography: NativeTypography) {
        self.text = text
        self.typography = typography
        _size = ScaledMetric(wrappedValue: typography.size, relativeTo: typography.relativeTo)
        _leading = ScaledMetric(wrappedValue: typography.lineSpacing, relativeTo: typography.relativeTo)
        _tracking = ScaledMetric(wrappedValue: typography.tracking, relativeTo: typography.relativeTo)
    }

    var body: some View {
        let styled = text.font(.system(size: size, weight: typography.weight)).tracking(tracking)
        if typography.monospacedDigits {
            styled.monospacedDigit().lineSpacing(leading)
        } else {
            styled.lineSpacing(leading)
        }
    }
}

public extension Text {
    @MainActor func nativeTypography(_ typography: NativeTypography) -> some View {
        TypographyText(text: self, typography: typography)
    }
}
