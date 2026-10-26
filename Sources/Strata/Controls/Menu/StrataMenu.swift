import DesignTokens
import SwiftUI

enum StrataComponentMetrics {
    static let cardRadius = token("radius.large", StyleTokens.radius)
    static let controlRadius = token("radius.medium", StyleTokens.radius)
    static let spacingSM = token("spacing.sm", StyleTokens.spacing)
    static let spacingMD = token("spacing.md", StyleTokens.spacing)
    static let spacingLG = token("spacing.lg", StyleTokens.spacing)
    static let spacingXL = token("spacing.xl", StyleTokens.spacing)
    static let minimumHit = token("dimension.hit.minimum", StyleTokens.dimension)

    static let verticalItemWidth = minimumHit + spacingSM + spacingXL

    private static func token(
        _ id: String,
        _ resolve: (String) throws -> Double
    ) -> CGFloat {
        do {
            return CGFloat(try resolve(id))
        } catch {
            preconditionFailure("Strata token \(id) failed to resolve: \(error)")
        }
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
