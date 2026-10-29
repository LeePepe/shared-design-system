import SwiftUI

/// A compact circular progress indicator with an explicit 14-point optical box.
public struct StrataProgressRing: View {
    private let theme: StrataTheme
    private let value: Double?
    private let total: Double

    /// Pass `nil` for indeterminate progress. Finite values are clamped to `0...total`.
    public init(theme: StrataTheme, value: Double?, total: Double) {
        precondition(StrataProgressBarValue.accepts(value: value, total: total),
                     "StrataProgressRing requires a finite positive total and a finite value or nil.")
        self.theme = theme
        self.total = total
        self.value = value.map { min(max($0, 0), total) }
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(theme.secondaryForeground.opacity(0.25), lineWidth: 2)
            Circle()
                .trim(from: 0, to: value.map { CGFloat($0 / total) } ?? 0.25)
                .stroke(theme.accent, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 14, height: 14)
        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
    }
}

/// A centered status metric for rows that combine a progress ring and monospaced digits.
public struct StrataStatusMetricBadge: View {
    private let theme: StrataTheme
    private let value: String
    private let progress: Double?
    private let total: Double

    public init(theme: StrataTheme, value: String, progress: Double?, total: Double) {
        precondition(StrataProgressBarValue.accepts(value: progress, total: total),
                     "StrataStatusMetricBadge requires a finite positive total and a finite value or nil.")
        self.theme = theme
        self.value = value
        self.progress = progress
        self.total = total
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 4) {
            StrataProgressRing(theme: theme, value: progress, total: total)
            Text(verbatim: value)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(theme.foreground)
        }
        .frame(minHeight: 24, alignment: .center)
        .alignmentGuide(.strataControlCenter) { $0[VerticalAlignment.center] }
    }
}
