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
    private let metrics: StrataComponentMetrics

    public init(
        theme: StrataTheme,
        kind: Kind,
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        isActionLoading: Bool = false,
        action: (() -> Void)? = nil
    ) throws {
        self.theme = theme
        self.kind = kind
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.isActionLoading = isActionLoading
        self.action = action
        self.metrics = try StrataComponentMetrics()
    }

    public init(
        theme: StrataTheme,
        kind: Kind,
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        isActionLoading: Bool = false,
        action: (() -> Void)? = nil,
        metrics: StrataComponentMetrics
    ) {
        self.theme = theme
        self.kind = kind
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.isActionLoading = isActionLoading
        self.action = action
        self.metrics = metrics
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: metrics.spacingMD) {
            HStack(alignment: .center, spacing: metrics.spacingSM) {
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
                    HStack(spacing: metrics.spacingSM) {
                        if isActionLoading {
                            ProgressView()
                                .tint(theme.onAccent)
                                .accessibilityHidden(true)
                        }
                        Text(actionTitle)
                    }
                    .foregroundStyle(theme.onAccent)
                    .frame(minWidth: metrics.minimumHit,
                           minHeight: metrics.minimumHit)
                    .padding(.horizontal, metrics.spacingLG)
                    .background(
                        RoundedRectangle(
                            cornerRadius: metrics.controlRadius,
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
        .padding(.horizontal, metrics.spacingXL)
        .padding(.vertical, metrics.spacingLG)
        .modifier(CardSurface(theme: theme, kind: kind, metrics: metrics))
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
    let metrics: StrataComponentMetrics

    func body(content: Content) -> some View {
        if kind == .error {
            content
                .background {
                    RoundedRectangle(
                        cornerRadius: metrics.cardRadius,
                        style: .continuous
                    )
                    .fill(theme.onCritical)
                }
                .overlay {
                    RoundedRectangle(
                        cornerRadius: metrics.cardRadius,
                        style: .continuous
                    )
                    .strokeBorder(theme.critical, lineWidth: metrics.borderRegular)
                }
        } else {
            content.strataSurface(
                theme: theme,
                style: .solid,
                cornerRadius: metrics.cardRadius,
                role: .card
            )
        }
    }
}
