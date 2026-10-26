import DesignTokens
import SwiftUI

struct StrataComponentMetrics {
    static let cardRadius: CGFloat = 24
    static let controlRadius: CGFloat = 16
    static let minimumHit: CGFloat = 44
    static let verticalItemWidth: CGFloat = 76
    static let spacingXS: CGFloat = 6
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 12
    static let spacingLG: CGFloat = 16
    static let spacingXL: CGFloat = 24

    init(
        dimension: (String) throws -> Double = StyleTokens.dimension,
        spacing: (String) throws -> Double = StyleTokens.spacing,
        radius: (String) throws -> Double = StyleTokens.radius
    ) throws {
        _ = try dimension("dimension.hit.minimum")
        _ = try spacing("spacing.xs")
        _ = try spacing("spacing.sm")
        _ = try spacing("spacing.md")
        _ = try spacing("spacing.lg")
        _ = try spacing("spacing.xl")
        _ = try radius("radius.large")
        _ = try radius("radius.medium")
    }
}

public struct StrataMenuAction: Identifiable, Sendable {
    public enum Role: Sendable {
        case standard
        case destructive
    }

    public let id: String
    public let title: String
    public let systemImage: String?
    public let role: Role
    public let isDisabled: Bool
    public let handler: @Sendable @MainActor () -> Void

    public init(
        id: String,
        title: String,
        systemImage: String? = nil,
        role: Role = .standard,
        isDisabled: Bool = false,
        handler: @escaping @Sendable @MainActor () -> Void
    ) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.role = role
        self.isDisabled = isDisabled
        self.handler = handler
    }
}

public struct StrataMenu: View {
    private let theme: StrataTheme
    private let label: String
    private let systemImage: String
    private let actions: [StrataMenuAction]

    public init(
        theme: StrataTheme,
        label: String,
        systemImage: String = "ellipsis",
        actions: [StrataMenuAction]
    ) {
        self.theme = theme
        self.label = label
        self.systemImage = systemImage
        self.actions = actions
    }

    public var body: some View {
        Menu {
            ForEach(actions) { action in
                menuAction(action)
            }
        } label: {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .frame(minWidth: StrataComponentMetrics.minimumHit,
                       minHeight: StrataComponentMetrics.minimumHit)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(label)
        .foregroundStyle(theme.secondaryForeground)
        .tint(theme.accent)
        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
    }

    @ViewBuilder
    private func menuAction(_ action: StrataMenuAction) -> some View {
        switch action.role {
        case .standard:
            Button {
                action.handler()
            } label: {
                actionLabel(action)
            }
            .disabled(action.isDisabled)
        case .destructive:
            Button(role: .destructive) {
                action.handler()
            } label: {
                actionLabel(action)
            }
            .disabled(action.isDisabled)
        }
    }

    @ViewBuilder
    private func actionLabel(_ action: StrataMenuAction) -> some View {
        if let systemImage = action.systemImage {
            Label(action.title, systemImage: systemImage)
        } else {
            Text(action.title)
        }
    }
}
