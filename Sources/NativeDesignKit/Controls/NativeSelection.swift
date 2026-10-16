import SwiftUI

public struct NativeToggle<Label: View>: View {
    private let theme: NativeDesignTheme
    private let metrics: NativeControlMetrics
    @Binding private var isOn: Bool
    private let label: Label

    public init(isOn: Binding<Bool>, theme: NativeDesignTheme, metrics: NativeControlMetrics,
                @ViewBuilder label: () -> Label) {
        _isOn = isOn
        self.theme = theme
        self.metrics = metrics
        self.label = label()
    }

    public var body: some View {
        Toggle(isOn: $isOn) { label }.toggleStyle(.switch)
            .frame(minHeight: metrics.minimumHitSize)
            .modifier(ControlChrome(theme: theme, metrics: metrics))
    }
}

/// macOS uses the native checkbox. iOS uses a Button-backed ToggleStyle because SwiftUI
/// has no iOS checkbox style. It supports activation, disabled state and an accessible value.
public struct NativeCheckbox<Label: View>: View {
    private let theme: NativeDesignTheme
    private let metrics: NativeControlMetrics
    private let checkedValue: Text
    private let uncheckedValue: Text
    @Binding private var isOn: Bool
    private let label: Label

    public init(isOn: Binding<Bool>, theme: NativeDesignTheme, metrics: NativeControlMetrics,
                checkedValue: Text, uncheckedValue: Text, @ViewBuilder label: () -> Label) {
        _isOn = isOn
        self.theme = theme
        self.metrics = metrics
        self.checkedValue = checkedValue
        self.uncheckedValue = uncheckedValue
        self.label = label()
    }

    public var body: some View {
        #if os(macOS)
        Toggle(isOn: $isOn) { label }.toggleStyle(.checkbox)
            .frame(minHeight: metrics.minimumHitSize)
            .modifier(ControlChrome(theme: theme, metrics: metrics))
        #else
        Toggle(isOn: $isOn) { label }
            .toggleStyle(CheckboxStyle(theme: theme, metrics: metrics,
                                       checkedValue: checkedValue, uncheckedValue: uncheckedValue))
            .modifier(ControlChrome(theme: theme, metrics: metrics))
        #endif
    }
}

#if os(iOS)
private struct CheckboxStyle: ToggleStyle {
    let theme: NativeDesignTheme
    let metrics: NativeControlMetrics
    let checkedValue: Text
    let uncheckedValue: Text

    func makeBody(configuration: Configuration) -> some View {
        Button { configuration.isOn.toggle() } label: {
            HStack(spacing: metrics.spacing) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .font(.system(size: metrics.iconSize)).accessibilityHidden(true)
                configuration.label
            }.nativeMinimumHitTarget(metrics.minimumHitSize)
                .contentShape(Rectangle())
        }.buttonStyle(.plain)
            .accessibilityValue(configuration.isOn ? checkedValue : uncheckedValue)
            .accessibilityAddTraits(configuration.isOn ? [.isSelected] : [])
    }
}
#endif

/// Caller supplies tagged native picker options. macOS uses radioGroup; iOS uses inline Picker.
public struct NativeRadioGroup<Selection: Hashable, Label: View, Content: View>: View {
    @Binding private var selection: Selection
    private let theme: NativeDesignTheme
    private let metrics: NativeControlMetrics
    private let label: Label
    private let content: Content

    public init(selection: Binding<Selection>, theme: NativeDesignTheme, metrics: NativeControlMetrics,
                @ViewBuilder label: () -> Label, @ViewBuilder content: () -> Content) {
        _selection = selection
        self.theme = theme
        self.metrics = metrics
        self.label = label()
        self.content = content()
    }

    public var body: some View {
        #if os(macOS)
        picker.pickerStyle(.radioGroup)
        #else
        picker.pickerStyle(.inline)
        #endif
    }

    private var picker: some View {
        Picker(selection: $selection) { content } label: { label }
            .modifier(ControlChrome(theme: theme, metrics: metrics))
    }
}

public enum NativePickerPresentation: Sendable, CaseIterable { case menu, segmented, inline }

public struct NativePicker<Selection: Hashable, Label: View, Content: View>: View {
    @Binding private var selection: Selection
    private let theme: NativeDesignTheme
    private let metrics: NativeControlMetrics
    private let presentation: NativePickerPresentation
    private let label: Label
    private let content: Content

    public init(selection: Binding<Selection>, theme: NativeDesignTheme, metrics: NativeControlMetrics,
                presentation: NativePickerPresentation, @ViewBuilder label: () -> Label,
                @ViewBuilder content: () -> Content) {
        _selection = selection
        self.theme = theme
        self.metrics = metrics
        self.presentation = presentation
        self.label = label()
        self.content = content()
    }

    public var body: some View {
        styled.modifier(ControlChrome(theme: theme, metrics: metrics))
            .frame(minHeight: metrics.minimumHitSize)
    }

    private var picker: some View { Picker(selection: $selection) { content } label: { label } }

    @ViewBuilder private var styled: some View {
        switch presentation {
        case .menu: picker.pickerStyle(.menu)
        case .segmented: picker.pickerStyle(.segmented)
        case .inline: picker.pickerStyle(.inline)
        }
    }
}
