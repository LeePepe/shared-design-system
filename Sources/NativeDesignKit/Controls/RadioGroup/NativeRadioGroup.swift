import SwiftUI

/// A caller-owned single selection with native tagged option identity.
public struct NativeRadioGroup<Selection: Hashable, Label: View, Options: View>: View {
    private let theme: NativeDesignTheme
    @Binding private var selection: Selection
    private let label: Label
    private let options: Options

    public init(
        theme: NativeDesignTheme,
        selection: Binding<Selection>,
        @ViewBuilder label: () -> Label,
        @ViewBuilder options: () -> Options
    ) {
        self.theme = theme
        _selection = selection
        self.label = label()
        self.options = options()
    }

    public var body: some View {
        nativePicker
            .font(.body)
            .foregroundStyle(theme.foreground)
            .tint(theme.accent)
            .frame(minHeight: 44, alignment: .leading)
    }

    @ViewBuilder private var nativePicker: some View {
        let picker = Picker(selection: $selection) {
            Group { options }
                .fixedSize(horizontal: false, vertical: true)
                .frame(minWidth: 44, minHeight: 44, alignment: .leading)
        } label: {
            label
        }
        #if os(macOS)
        picker.pickerStyle(.radioGroup)
        #else
        picker.pickerStyle(.inline)
            .environment(\.defaultMinListRowHeight, 44)
        #endif
    }
}
