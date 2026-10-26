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
                        .accessibilityHidden(true)
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
                                .tint(theme.onAccent)
                                .accessibilityHidden(true)
                        }
                        Text(actionTitle)
                    }
                    .foregroundStyle(theme.onAccent)
                    .frame(minWidth: StrataComponentMetrics.minimumHit,
                           minHeight: StrataComponentMetrics.minimumHit)
                    .padding(.horizontal, StrataComponentMetrics.spacingLG)
                    .background(
                        RoundedRectangle(
                            cornerRadius: StrataComponentMetrics.controlRadius,
                            style: .continuous
                        )
                        .fill(theme.accent)
                    )
                }
                .buttonStyle(.plain)
                .disabled(isActionLoading)
                .accessibilityLabel(actionTitle)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, StrataComponentMetrics.spacingXL)
        .padding(.vertical, StrataComponentMetrics.spacingLG)
        .modifier(CardSurface(theme: theme, kind: kind))
        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
        .accessibilityElement(children: .contain)
    }

    private var foreground: Color {
        kind == .error ? theme.critical : theme.foreground
    }

    nonisolated static func usesErrorSurface(for kind: Kind) -> Bool {
        kind == .error
    }
}

private struct CardSurface: ViewModifier {
    let theme: StrataTheme
    let kind: StrataStateView.Kind

    func body(content: Content) -> some View {
        if kind == .error {
            content
                .background {
                    RoundedRectangle(
                        cornerRadius: StrataComponentMetrics.cardRadius,
                        style: .continuous
                    )
                    .fill(theme.onCritical)
                }
                .overlay {
                    RoundedRectangle(
                        cornerRadius: StrataComponentMetrics.cardRadius,
                        style: .continuous
                    )
                    .strokeBorder(theme.critical, lineWidth: 1)
                }
        } else {
            content.strataSurface(
                theme: theme,
                style: .solid,
                cornerRadius: StrataComponentMetrics.cardRadius,
                role: .card
            )
        }
    }
}
