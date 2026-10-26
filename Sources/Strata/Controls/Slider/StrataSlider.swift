import SwiftUI

/// Invalid native slider configuration, detected before constructing the control.
public enum StrataSliderConfigurationError: Error, Equatable, Sendable {
    /// Bounds must be finite, strictly increasing, with a finite difference.
    case invalidRange
    /// Step must be finite and greater than zero.
    case invalidStep
}

/// A native SwiftUI slider with caller-owned value, labels and editing effects.
public struct StrataSlider<Label: View, MinimumValueLabel: View, MaximumValueLabel: View>: View {
    private let theme: StrataTheme
    @Binding private var value: Double
    private let range: ClosedRange<Double>
    private let step: Double
    private let onEditingChanged: (Bool) -> Void
    private let label: Label
    private let minimumValueLabel: MinimumValueLabel
    private let maximumValueLabel: MaximumValueLabel
    @Environment(\.isEnabled) private var isEnabled
    @State private var nativeControlHeight: CGFloat = 0

    /// The caller keeps the bound value finite and within `range`.
    /// Configuration errors do not change the binding or invoke editing effects.
    public init(
        theme: StrataTheme,
        value: Binding<Double>,
        in range: ClosedRange<Double>,
        step: Double,
        onEditingChanged: @escaping (Bool) -> Void,
        @ViewBuilder label: () -> Label,
        @ViewBuilder minimumValueLabel: () -> MinimumValueLabel,
        @ViewBuilder maximumValueLabel: () -> MaximumValueLabel
    ) throws {
        try StrataSliderConfiguration.validate(range: range, step: step)
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

            nativeControl

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

    // A frame/contentShape alone leaves the native track's touch region at its
    // intrinsic height. Scale that real control uniformly, fitting its width
    // before the transform, so native input and accessibility geometry agree.
    private var nativeControl: some View {
        let scale = nativeControlHeight > 0 ? max(1, 44 / nativeControlHeight) : 1
        let height = max(44, nativeControlHeight)
        return GeometryReader { available in
            Slider(value: $value, in: range, step: step, onEditingChanged: onEditingChanged) {
                label
            }
            .labelsHidden()
            .controlSize(.large)
            .fixedSize(horizontal: false, vertical: true)
            .frame(width: available.size.width / scale)
            .background {
                GeometryReader { intrinsic in
                    Color.clear.preference(key: StrataSliderIntrinsicHeight.self, value: intrinsic.size.height)
                }
            }
            .scaleEffect(scale)
            .frame(width: available.size.width, height: height)
            .tint(theme.accent)
            .accentColor(theme.accent)
        }
        .frame(minWidth: 44)
        .frame(height: height)
        .onPreferenceChange(StrataSliderIntrinsicHeight.self) { nativeControlHeight = $0 }
    }
}

private enum StrataSliderIntrinsicHeight: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

enum StrataSliderConfiguration {
    static func validate(range: ClosedRange<Double>, step: Double) throws {
        guard range.lowerBound.isFinite, range.upperBound.isFinite,
              range.lowerBound < range.upperBound,
              (range.upperBound - range.lowerBound).isFinite else {
            throw StrataSliderConfigurationError.invalidRange
        }
        guard step.isFinite, step > 0 else {
            throw StrataSliderConfigurationError.invalidStep
        }
    }
}
