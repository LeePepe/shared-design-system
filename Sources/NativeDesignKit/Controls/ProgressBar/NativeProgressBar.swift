import SwiftUI

/// Native linear progress with explicit theme and caller-owned localized content.
public struct NativeProgressBar<Label: View, CurrentValueLabel: View>: View {
    private let theme: NativeDesignTheme
    private let progress: NativeProgressBarValue
    private let label: Label
    private let currentValueLabel: CurrentValueLabel

    /// Pass `nil` for indeterminate progress. `total` must be finite and positive,
    /// and a non-nil `value` must be finite. Finite values clamp to `0...total`.
    /// Builders own localization and formatting, including readable waiting text.
    public init(
        theme: NativeDesignTheme,
        value: Double?,
        total: Double,
        @ViewBuilder label: () -> Label,
        @ViewBuilder currentValueLabel: () -> CurrentValueLabel
    ) {
        self.theme = theme
        progress = NativeProgressBarValue(value: value, total: total)
        self.label = label()
        self.currentValueLabel = currentValueLabel()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            label
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.foreground)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
            currentValueLabel
                .font(.caption)
                .foregroundStyle(theme.secondaryForeground)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
            ProgressView(value: progress.value, total: progress.total) {
                label
            } currentValueLabel: {
                currentValueLabel
            }
            .labelsHidden()
            .progressViewStyle(.linear)
            .tint(theme.accent)
            .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
            .background(theme.surface, in: Capsule())
            .frame(minHeight: 8)
        }
    }
}

/// Mirrors the native finite-range normalization while rejecting undefined input.
struct NativeProgressBarValue {
    let value: Double?
    let total: Double

    static func accepts(value: Double?, total: Double) -> Bool {
        total.isFinite && total > 0 && (value?.isFinite ?? true)
    }

    init(value: Double?, total: Double) {
        precondition(Self.accepts(value: value, total: total),
                     "NativeProgressBar requires a finite positive total and a finite value or nil.")
        self.total = total
        self.value = value.map { min(max($0, 0), total) }
    }
}
