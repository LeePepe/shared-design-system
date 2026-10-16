import SwiftUI

public enum NativeButtonPresentation: Sendable, CaseIterable {
    case prominent, bordered, plain, glass
}

/// A native Button with a caller-owned label and loading state. Icon-only callers supply
/// an accessibilityLabel. Loading retains the label's layout and blocks repeated actions.
public struct NativeButton<Label: View>: View {
    private let theme: NativeDesignTheme
    private let metrics: NativeControlMetrics
    private let presentation: NativeButtonPresentation
    private let isLoading: Bool
    private let loadingLabel: Text
    private let action: () -> Void
    private let label: Label
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    public init(theme: NativeDesignTheme, metrics: NativeControlMetrics,
                presentation: NativeButtonPresentation, isLoading: Bool,
                loadingLabel: Text, action: @escaping () -> Void,
                @ViewBuilder label: () -> Label) {
        self.theme = theme
        self.metrics = metrics
        self.presentation = presentation
        self.isLoading = isLoading
        self.loadingLabel = loadingLabel
        self.action = action
        self.label = label()
    }

    public var body: some View {
        styledButton.tint(theme.statusInfo).disabled(isLoading)
            .accessibilityValue(isLoading ? loadingLabel : Text(""))
    }

    private var button: some View {
        Button(action: action) {
            label.padding(metrics.padding)
                .nativeMinimumHitTarget(metrics.minimumHitSize)
                .foregroundColor(presentation == .prominent ? theme.statusOnInfo : theme.textPrimary)
                .opacity(isLoading ? 0 : 1)
                .overlay {
                    if isLoading {
                        ProgressView().tint(presentation == .prominent ? theme.statusOnInfo : theme.statusInfo)
                            .accessibilityHidden(true)
                    }
                }
        }
    }

    @ViewBuilder private var styledButton: some View {
        switch presentation {
        case .prominent: button.buttonStyle(.borderedProminent)
        case .bordered: button.buttonStyle(.bordered)
        case .plain: button.buttonStyle(.plain)
        case .glass:
            if #available(iOS 26, macOS 26, *), !reduceTransparency {
                button.buttonStyle(.glass)
            } else {
                button.buttonStyle(.bordered)
            }
        }
    }
}
