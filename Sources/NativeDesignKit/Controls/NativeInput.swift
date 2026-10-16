import SwiftUI

public struct NativeTextField: View {
    private let title: LocalizedStringKey
    @Binding private var text: String
    private let theme: NativeDesignTheme
    private let metrics: NativeControlMetrics
    @Environment(\.isEnabled) private var isEnabled

    public init(_ title: LocalizedStringKey, text: Binding<String>, theme: NativeDesignTheme,
                metrics: NativeControlMetrics) {
        self.title = title; _text = text; self.theme = theme; self.metrics = metrics
    }

    public var body: some View {
        TextField(title, text: $text)
            .textFieldStyle(.roundedBorder)
            // The native style owns bezel insets and keyboard-focus feedback.
            .nativeMinimumHitTarget(metrics.minimumHitSize)
            .foregroundColor(isEnabled ? theme.textPrimary : theme.textSecondary)
            .tint(theme.statusInfo)
            // Keep native placeholder, selection and bezel appearance with the
            // explicit theme, including inside an oppositely themed parent.
            .colorScheme(theme.theme == .dark ? .dark : .light)
    }
}

public struct NativeSecureField: View {
    private let title: LocalizedStringKey
    @Binding private var text: String
    private let theme: NativeDesignTheme
    private let metrics: NativeControlMetrics

    public init(_ title: LocalizedStringKey, text: Binding<String>, theme: NativeDesignTheme,
                metrics: NativeControlMetrics) {
        self.title = title; _text = text; self.theme = theme; self.metrics = metrics
    }

    public var body: some View {
        SecureField(title, text: $text).textFieldStyle(.plain)
            .modifier(FieldChrome(theme: theme, metrics: metrics))
    }
}

/// Caller controls editor height; the visible label remains available to assistive technology.
public struct NativeTextEditor<Label: View>: View {
    @Binding private var text: String
    private let theme: NativeDesignTheme
    private let metrics: NativeControlMetrics
    private let accessibilityLabel: Text
    private let label: Label
    private let forceLegacyBackground: Bool

    public init(text: Binding<String>, theme: NativeDesignTheme, metrics: NativeControlMetrics,
                accessibilityLabel: Text, @ViewBuilder label: () -> Label) {
        self.init(text: text, theme: theme, metrics: metrics, accessibilityLabel: accessibilityLabel,
                  forceLegacyBackground: false, label: label)
    }

    /// Internal native-host test seam: exercise the actual old-OS background path on current SDKs.
    init(text: Binding<String>, theme: NativeDesignTheme, metrics: NativeControlMetrics,
         accessibilityLabel: Text, forceLegacyBackground: Bool, @ViewBuilder label: () -> Label) {
        _text = text; self.theme = theme; self.metrics = metrics
        self.accessibilityLabel = accessibilityLabel; self.label = label()
        self.forceLegacyBackground = forceLegacyBackground
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: metrics.spacing) {
            label.accessibilityHidden(true)
            editor.accessibilityLabel(accessibilityLabel)
        }.modifier(ControlChrome(theme: theme, metrics: metrics))
    }

    @ViewBuilder private var editor: some View {
        if forceLegacyBackground {
            legacyEditor
        } else if #available(iOS 16, macOS 13, *) {
            TextEditor(text: $text).scrollContentBackground(.hidden)
                .modifier(FieldChrome(theme: theme, metrics: metrics))
        } else {
            legacyEditor
        }
    }

    private var legacyEditor: some View {
        TextEditor(text: $text)
            .modifier(FieldChrome(theme: theme, metrics: metrics))
            // The native background cannot be hidden on iOS 15/macOS 12. Its appearance
            // must match our required text theme even when the surrounding app differs.
            .colorScheme(theme.theme == .dark ? .dark : .light)
    }
}

public struct NativeSearchField: View {
    private let title: LocalizedStringKey
    @Binding private var text: String
    private let theme: NativeDesignTheme
    private let metrics: NativeControlMetrics
    private let clearLabel: Text

    public init(_ title: LocalizedStringKey, text: Binding<String>, theme: NativeDesignTheme,
                metrics: NativeControlMetrics, clearLabel: Text) {
        self.title = title; _text = text; self.theme = theme
        self.metrics = metrics; self.clearLabel = clearLabel
    }

    public var body: some View {
        HStack(spacing: metrics.spacing) {
            Image(systemName: "magnifyingglass").accessibilityHidden(true)
            TextField(title, text: $text).textFieldStyle(.plain)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill").nativeMinimumHitTarget(metrics.minimumHitSize)
                }.buttonStyle(.plain).accessibilityLabel(clearLabel)
            }
        }.modifier(FieldChrome(theme: theme, metrics: metrics))
    }
}
