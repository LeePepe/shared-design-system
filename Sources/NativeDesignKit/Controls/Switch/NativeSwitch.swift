import SwiftUI

/// A native on/off control with an explicit theme and caller-owned state.
public struct NativeSwitch<Label: View>: View {
    private let theme: NativeDesignTheme
    @Binding private var isOn: Bool
    private let label: Label

    public init(
        theme: NativeDesignTheme,
        isOn: Binding<Bool>,
        @ViewBuilder label: () -> Label
    ) {
        self.theme = theme
        self._isOn = isOn
        self.label = label()
    }

    public var body: some View {
        Toggle(isOn: $isOn) {
            label
                .font(.body)
                .foregroundStyle(theme.foreground)
                .fixedSize(horizontal: false, vertical: true)
        }
        .toggleStyle(.switch)
        .tint(theme.accent)
        .frame(minWidth: 44, minHeight: 44)
        .contentShape(Rectangle())
        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
    }
}
