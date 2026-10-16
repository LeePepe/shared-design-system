import SwiftUI

/// Invalid native slider configuration, detected before constructing the control.
public enum NativeSliderConfigurationError: Error, Equatable, Sendable {
    /// Bounds must be finite, strictly increasing, with a finite difference.
    case invalidRange
    /// Step must be finite and greater than zero.
    case invalidStep
}

/// A native SwiftUI slider with caller-owned value, labels and editing effects.
public struct NativeSlider<Label: View, MinimumValueLabel: View, MaximumValueLabel: View>: View {
    private let theme: NativeDesignTheme
    @Binding private var value: Double
    private let range: ClosedRange<Double>
    private let step: Double
    private let onEditingChanged: (Bool) -> Void
    private let label: Label
    private let minimumValueLabel: MinimumValueLabel
    private let maximumValueLabel: MaximumValueLabel
    @Environment(\.isEnabled) private var isEnabled

    /// The caller keeps the bound value finite and within `range`.
    /// Configuration errors do not change the binding or invoke editing effects.
    public init(
        theme: NativeDesignTheme,
        value: Binding<Double>,
        in range: ClosedRange<Double>,
        step: Double,
        onEditingChanged: @escaping (Bool) -> Void,
        @ViewBuilder label: () -> Label,
        @ViewBuilder minimumValueLabel: () -> MinimumValueLabel,
        @ViewBuilder maximumValueLabel: () -> MaximumValueLabel
    ) throws {
        try NativeSliderConfiguration.validate(range: range, step: step)
        self.theme = theme
        self._value = value
        self.range = range
        self.step = step
        self.onEditingChanged = onEditingChanged
        self.label = label()
        self.minimumValueLabel = minimumValueLabel()
        self.maximumValueLabel = maximumValueLabel()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            label
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)

            Slider(value: $value, in: range, step: step, onEditingChanged: onEditingChanged) {
                label
            }
            .labelsHidden()
            .controlSize(.large)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
            .tint(theme.accent)
            .accentColor(theme.accent)

            HStack(alignment: .top, spacing: 12) {
                minimumValueLabel
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                maximumValueLabel
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .multilineTextAlignment(.trailing)
            }
            .font(.caption)
            .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(isEnabled ? theme.foreground : theme.secondaryForeground)
        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
    }
}

enum NativeSliderConfiguration {
    static func validate(range: ClosedRange<Double>, step: Double) throws {
        guard range.lowerBound.isFinite, range.upperBound.isFinite,
              range.lowerBound < range.upperBound,
              (range.upperBound - range.lowerBound).isFinite else {
            throw NativeSliderConfigurationError.invalidRange
        }
        guard step.isFinite, step > 0 else {
            throw NativeSliderConfigurationError.invalidStep
        }
    }
}
