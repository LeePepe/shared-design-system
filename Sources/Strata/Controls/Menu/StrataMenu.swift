import DesignTokens
import SwiftUI

public struct StrataComponentMetrics: Equatable, Sendable {
    public let cardRadius: CGFloat
    public let controlRadius: CGFloat
    public let minimumHit: CGFloat
    public let verticalItemWidth: CGFloat
    public let spacingXS: CGFloat
    public let spacingSM: CGFloat
    public let spacingMD: CGFloat
    public let spacingLG: CGFloat
    public let spacingXL: CGFloat
    public let borderRegular: CGFloat

    public init(
        dimension: (String) throws -> Double = StyleTokens.dimension,
        spacing: (String) throws -> Double = StyleTokens.spacing,
        radius: (String) throws -> Double = StyleTokens.radius,
        border: (String) throws -> Double = StyleTokens.border
    ) throws {
        let minimumHit = CGFloat(try dimension("dimension.hit.minimum"))
        let spacingXS = CGFloat(try spacing("spacing.xs"))
        let spacingSM = CGFloat(try spacing("spacing.sm"))
        let spacingMD = CGFloat(try spacing("spacing.md"))
        let spacingLG = CGFloat(try spacing("spacing.lg"))
        let spacingXL = CGFloat(try spacing("spacing.xl"))
        let radiusMedium = CGFloat(try radius("radius.medium"))
        let radiusLarge = CGFloat(try radius("radius.large"))
        let borderRegular = CGFloat(try border("border.regular"))

        self.minimumHit = minimumHit
        self.spacingXS = spacingXS
        self.spacingSM = spacingSM
        self.spacingMD = spacingMD
        self.spacingLG = spacingLG
        self.spacingXL = spacingXL
        self.cardRadius = radiusLarge + spacingXS
        self.controlRadius = radiusMedium + spacingXS
        self.verticalItemWidth = minimumHit + spacingXL + spacingSM
        self.borderRegular = borderRegular
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
    private let metrics: StrataComponentMetrics

    public init(
        theme: StrataTheme,
        label: String,
        systemImage: String = "ellipsis",
        actions: [StrataMenuAction]
    ) throws {
        self.theme = theme
        self.label = label
        self.systemImage = systemImage
        self.actions = actions
        self.metrics = try StrataComponentMetrics()
    }

    public init(
        theme: StrataTheme,
        label: String,
        systemImage: String = "ellipsis",
        actions: [StrataMenuAction],
        metrics: StrataComponentMetrics
    ) {
        self.theme = theme
        self.label = label
        self.systemImage = systemImage
        self.actions = actions
        self.metrics = metrics
    }

    public var body: some View {
        Menu {
            ForEach(actions) { action in
                menuAction(action)
            }
        } label: {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
                .frame(minWidth: metrics.minimumHit,
                       minHeight: metrics.minimumHit)
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
