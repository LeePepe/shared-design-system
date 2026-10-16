import SwiftUI

public struct NativeSlider<Label: View>: View {
    @Binding private var value: Double
    private let bounds: ClosedRange<Double>
    private let step: Double
    private let theme: NativeDesignTheme
    private let metrics: NativeControlMetrics
    private let onEditingChanged: (Bool) -> Void
    private let label: Label

    public init(value: Binding<Double>, in bounds: ClosedRange<Double>, step: Double,
                theme: NativeDesignTheme, metrics: NativeControlMetrics,
                onEditingChanged: @escaping (Bool) -> Void, @ViewBuilder label: () -> Label) {
        precondition(step.isFinite && step > 0 && bounds.lowerBound.isFinite && bounds.upperBound.isFinite)
        _value = value; self.bounds = bounds; self.step = step; self.theme = theme
        self.metrics = metrics; self.onEditingChanged = onEditingChanged; self.label = label()
    }

    public var body: some View {
        Slider(value: $value, in: bounds, step: step, onEditingChanged: onEditingChanged) { label }
            .frame(minHeight: metrics.minimumHitSize)
            .modifier(ControlChrome(theme: theme, metrics: metrics))
    }
}

public struct NativeStepper<Label: View>: View {
    @Binding private var value: Int
    private let bounds: ClosedRange<Int>
    private let step: Int
    private let theme: NativeDesignTheme
    private let metrics: NativeControlMetrics
    private let label: Label

    public init(value: Binding<Int>, in bounds: ClosedRange<Int>, step: Int,
                theme: NativeDesignTheme, metrics: NativeControlMetrics,
                @ViewBuilder label: () -> Label) {
        precondition(step > 0)
        _value = value; self.bounds = bounds; self.step = step
        self.theme = theme; self.metrics = metrics; self.label = label()
    }

    public var body: some View {
        Stepper(value: $value, in: bounds, step: step) { label }
            .frame(minHeight: metrics.minimumHitSize)
            .modifier(ControlChrome(theme: theme, metrics: metrics))
    }
}

/// Native platform date/time presentation, locale, calendar, time zone and keyboard behavior.
public struct NativeDatePicker<Label: View>: View {
    @Binding private var selection: Date
    private let bounds: ClosedRange<Date>
    private let components: DatePickerComponents
    private let theme: NativeDesignTheme
    private let metrics: NativeControlMetrics
    private let label: Label

    public init(selection: Binding<Date>, in bounds: ClosedRange<Date>,
                displayedComponents: DatePickerComponents, theme: NativeDesignTheme,
                metrics: NativeControlMetrics, @ViewBuilder label: () -> Label) {
        _selection = selection; self.bounds = bounds; components = displayedComponents
        self.theme = theme; self.metrics = metrics; self.label = label()
    }

    public var body: some View {
        DatePicker(selection: $selection, in: bounds, displayedComponents: components) { label }
            .frame(minHeight: metrics.minimumHitSize)
            .modifier(ControlChrome(theme: theme, metrics: metrics))
    }
}
