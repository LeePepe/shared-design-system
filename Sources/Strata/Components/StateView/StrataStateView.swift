import SwiftUI

public struct StrataStateView: View {
    public enum Kind: Sendable, Equatable {
        case empty
        case loading
        case error
    }

    private let theme: StrataTheme
    private let kind: Kind
    private let title: String
    private let message: String?
    private let actionTitle: String?
    private let isActionLoading: Bool
    private let action: (() -> Void)?

    public init(
        theme: StrataTheme,
        kind: Kind,
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        isActionLoading: Bool = false,
        action: (() -> Void)? = nil
    ) {
        self.theme = theme
        self.kind = kind
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.isActionLoading = isActionLoading
        self.action = action
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: StrataComponentMetrics.spacingMD) {
            HStack(alignment: .center, spacing: StrataComponentMetrics.spacingSM) {
                if kind == .loading {
                    ProgressView()
                        .tint(theme.accent)
                        .accessibilityLabel("Loading")
                } else if kind == .error {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(theme.critical)
                        .accessibilityHidden(true)
                }
                Text(title)
                    .font(.headline)
                    .foregroundStyle(foreground)
                    .accessibilityAddTraits(.isHeader)
            }
            if let message, !message.isEmpty {
                Text(message)
                    .font(.body)
                    .foregroundStyle(kind == .error ? theme.critical : theme.secondaryForeground)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let actionTitle, let action, kind != .loading {
                Button {
                    guard !isActionLoading else { return }
                    action()
                } label: {
                    HStack(spacing: StrataComponentMetrics.spacingSM) {
                        if isActionLoading {
                            ProgressView()
                                .tint(theme.accent)
                                .accessibilityHidden(true)
                        }
                        Text(actionTitle)
                    }
                    .frame(minWidth: StrataComponentMetrics.minimumHit,
                           minHeight: StrataComponentMetrics.minimumHit)
                    .padding(.horizontal, StrataComponentMetrics.spacingMD)
                }
                .buttonStyle(.borderedProminent)
                .tint(theme.accent)
                .disabled(isActionLoading)
                .accessibilityLabel(actionTitle)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, StrataComponentMetrics.spacingLG)
        .padding(.vertical, StrataComponentMetrics.spacingMD)
        .strataSurface(
            theme: theme,
            style: .solid,
            cornerRadius: StrataComponentMetrics.cardRadius,
            role: kind == .error ? nil : .card
        )
        .background {
            if kind == .error {
                RoundedRectangle(
                    cornerRadius: StrataComponentMetrics.cardRadius,
                    style: .continuous
                )
                .fill(theme.onCritical)
            }
        }
        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
        .accessibilityElement(children: .contain)
    }

    private var foreground: Color {
        kind == .error ? theme.critical : theme.foreground
    }
}
