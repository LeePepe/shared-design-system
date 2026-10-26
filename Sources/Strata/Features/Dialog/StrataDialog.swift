import DesignTokens
import SwiftUI

public enum StrataDialogConfigurationError: Error, Equatable, Sendable {
    case emptyTitle
    case emptyCloseLabel
    case emptyActionLabel
    case emptyStatusMessage
    case emptyGuardReason
    case duplicateActionID(String)
    case multiplePrimaryActions
}

public enum StrataDialogState: Equatable, Sendable {
    case populated
    case loading(message: String)
    case error(message: String)
}

public enum StrataDialogDismissalPolicy: Equatable, Sendable {
    case dismissible
    case guarded(reason: String)
}

public enum StrataDialogActionRole: Equatable, Sendable {
    case primary
    case secondary
    case destructive
    case cancel
}

public enum StrataDialogActionOutcome: Equatable, Sendable {
    case stayPresented
    case dismiss
}

public struct StrataDialogAction: Identifiable, Sendable {
    public let id: String
    public let label: String
    public let role: StrataDialogActionRole
    public let isEnabled: Bool
    public let perform: @Sendable @MainActor () -> StrataDialogActionOutcome

    @MainActor
    public init(
        id: String,
        label: String,
        role: StrataDialogActionRole,
        isEnabled: Bool = true,
        perform: @escaping @Sendable @MainActor () -> StrataDialogActionOutcome
    ) throws {
        guard !id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw StrataDialogConfigurationError.emptyActionLabel
        }
        self.id = id
        self.label = label
        self.role = role
        self.isEnabled = isEnabled
        self.perform = perform
    }
}

public struct StrataDialogPresentation: Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let closeLabel: String
    public let state: StrataDialogState
    public let dismissalPolicy: StrataDialogDismissalPolicy
    public let allowsOutsideDismiss: Bool
    public let actions: [StrataDialogAction]

    @MainActor
    public init(
        id: UUID = UUID(),
        title: String,
        closeLabel: String,
        state: StrataDialogState = .populated,
        dismissalPolicy: StrataDialogDismissalPolicy = .dismissible,
        allowsOutsideDismiss: Bool = false,
        actions: [StrataDialogAction]
    ) throws {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw StrataDialogConfigurationError.emptyTitle
        }
        guard !closeLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw StrataDialogConfigurationError.emptyCloseLabel
        }
        switch state {
        case .populated:
            break
        case .loading(let message), .error(let message):
            guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw StrataDialogConfigurationError.emptyStatusMessage
            }
        }
        switch dismissalPolicy {
        case .dismissible:
            break
        case .guarded(let reason):
            guard !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw StrataDialogConfigurationError.emptyGuardReason
            }
        }
        var seen = Set<String>()
        for action in actions where !seen.insert(action.id).inserted {
            throw StrataDialogConfigurationError.duplicateActionID(action.id)
        }
        guard actions.filter({ $0.role == .primary }).count <= 1 else {
            throw StrataDialogConfigurationError.multiplePrimaryActions
        }
        self.id = id
        self.title = title
        self.closeLabel = closeLabel
        self.state = state
        self.dismissalPolicy = dismissalPolicy
        self.allowsOutsideDismiss = allowsOutsideDismiss
        self.actions = actions
    }
}

public enum StrataDialogDismissal: Equatable, Sendable {
    case close
    case cancel
    case escape
    case outside
    case action(String)
}

struct StrataModalSession: Sendable, Equatable {
    private(set) var id: UUID
    private(set) var generation: UInt64 = 0

    init(id: UUID) {
        self.id = id
    }

    mutating func replace(id: UUID) {
        self.id = id
        generation &+= 1
    }

    mutating func invalidate() {
        generation &+= 1
    }

    func matches(id: UUID, generation: UInt64) -> Bool {
        self.id == id && self.generation == generation
    }
}

@MainActor
public struct StrataDialog<Base: View, Content: View>: View {
    @MainActor
    public struct Configuration {
        let theme: StrataTheme
        let presentation: Binding<StrataDialogPresentation?>
        let restoreFocus: @MainActor () -> Bool
        let onDismiss: @MainActor (UUID, StrataDialogDismissal) -> Void
        let base: Base
        let content: (StrataDialogPresentation) -> Content
        let radius: CGFloat
        let controlRadius: CGFloat
        let spacingXS: CGFloat
        let spacingSM: CGFloat
        let spacingMD: CGFloat
        let spacingLG: CGFloat
        let minimumHit: CGFloat
        let border: CGFloat
        let opacity: CGFloat
        let scrimColor: Color
        let scrimOpacity: CGFloat
        let destructiveColor: Color
        let onDestructiveColor: Color
        let headline: TypographyToken
        let body: TypographyToken
        let callout: TypographyToken

        public init(
            theme: StrataTheme,
            presentation: Binding<StrataDialogPresentation?>,
            restoreFocus: @escaping @MainActor () -> Bool = { false },
            onDismiss: @escaping @MainActor (UUID, StrataDialogDismissal) -> Void = { _, _ in },
            @ViewBuilder base: () -> Base,
            @ViewBuilder content: @escaping (StrataDialogPresentation) -> Content
        ) throws {
            self.theme = theme
            self.presentation = presentation
            self.restoreFocus = restoreFocus
            self.onDismiss = onDismiss
            self.base = base()
            self.content = content
            radius = try CGFloat(StyleTokens.radius("radius.large"))
            controlRadius = try CGFloat(StyleTokens.radius("radius.medium"))
            spacingXS = try CGFloat(StyleTokens.spacing("spacing.xs"))
            spacingSM = try CGFloat(StyleTokens.spacing("spacing.sm"))
            spacingMD = try CGFloat(StyleTokens.spacing("spacing.md"))
            spacingLG = try CGFloat(StyleTokens.spacing("spacing.lg"))
            minimumHit = try CGFloat(StyleTokens.dimension("dimension.hit.minimum"))
            border = try CGFloat(StyleTokens.border("border.regular"))
            opacity = try CGFloat(StyleTokens.opacity("opacity.subtle"))
            scrimColor = try StrataTokenColor.resolve("product.strata.material.shadow", theme: theme.mode)
            scrimOpacity = try CGFloat(StyleTokens.opacity("opacity.overlay"))
            destructiveColor = try StrataTokenColor.resolve("status.critical", theme: theme.mode)
            onDestructiveColor = try StrataTokenColor.resolve("status.on-critical", theme: theme.mode)
            headline = try StyleTokens.typography("typography.headline")
            body = try StyleTokens.typography("typography.body")
            callout = try StyleTokens.typography("typography.callout")
        }
    }

    private let configuration: Configuration
    @FocusState private var ownedFocus: String?
    @AccessibilityFocusState private var ownedAccessibilityFocus: String?
    @State private var session: StrataModalSession?
    @State private var guardMessage: String?
    @State private var announcedStatus: StrataDialogState?

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        ZStack {
            configuration.base
                .disabled(configuration.presentation.wrappedValue != nil)
                .accessibilityHidden(configuration.presentation.wrappedValue != nil)
            if let item = configuration.presentation.wrappedValue {
                configuration.scrimColor.opacity(configuration.scrimOpacity)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .accessibilityIdentifier("strata-dialog-scrim")
                    .onTapGesture {
                        dismiss(item, reason: .outside)
                    }
                dialog(item)
            }
        }
        .background(configuration.theme.canvas.ignoresSafeArea())
        .environment(\.colorScheme, configuration.theme.mode == .light ? .light : .dark)
        .preference(
            key: StrataModalVisibilityPreference.self,
            value: configuration.presentation.wrappedValue != nil
        )
        .environment(\.strataPresentationObscured, configuration.presentation.wrappedValue != nil)
        .onChange(of: configuration.presentation.wrappedValue?.id) { _ in
            guardMessage = nil
            if let item = configuration.presentation.wrappedValue {
                synchronizeSession(for: item)
            } else {
                session?.invalidate()
                session = nil
            }
        }
    }

    private func dialog(_ item: StrataDialogPresentation) -> some View {
        VStack(alignment: .leading, spacing: configuration.spacingMD) {
            HStack(alignment: .firstTextBaseline, spacing: configuration.spacingSM) {
                Text(item.title)
                    .font(.system(size: configuration.headline.size, weight: .bold))
                    .foregroundStyle(configuration.theme.foreground)
                    .accessibilityAddTraits(.isHeader)
                Spacer(minLength: configuration.spacingSM)
                Button(item.closeLabel) {
                    dismiss(item, reason: .close)
                }
                .frame(minWidth: configuration.minimumHit, minHeight: configuration.minimumHit)
                .accessibilityIdentifier("strata-dialog-close")
                .focused($ownedFocus, equals: "close")
                .accessibilityFocused($ownedAccessibilityFocus, equals: "close")
                .dialogCancelShortcut(enabled: item.dismissalPolicy == .dismissible)
            }
            configuration.content(item)
            status(item.state)
            if let guardMessage = guardReason(for: item) ?? guardMessage {
                Text(guardMessage)
                    .font(.system(size: configuration.body.size))
                    .foregroundStyle(configuration.theme.critical)
                    .accessibilityIdentifier("strata-dialog-guard")
            }
            HStack(spacing: configuration.spacingSM) {
                ForEach(item.actions) { action in
                    actionButton(action, item: item)
                }
            }
        }
        .padding(configuration.spacingLG)
        .frame(maxWidth: 520)
        .background(
            RoundedRectangle(cornerRadius: configuration.radius, style: .continuous)
                .fill(configuration.theme.surface(.card))
        )
        .overlay {
            RoundedRectangle(cornerRadius: configuration.radius, style: .continuous)
                .stroke(configuration.theme.foreground.opacity(configuration.opacity), lineWidth: configuration.border)
        }
        .padding(configuration.spacingMD)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("strata-dialog")
        .dialogEscapeDismissal(enabled: item.dismissalPolicy == .dismissible) {
            dismiss(item, reason: .escape)
        }
        .onAppear {
            synchronizeSession(for: item)
            if ownedFocus == nil && ownedAccessibilityFocus == nil {
                let target = item.actions.first(where: { $0.role != .destructive && $0.isEnabled })?.id ?? "close"
                ownedFocus = target
                ownedAccessibilityFocus = target
            }
        }
        .onChange(of: item.state) { state in
            announceStatusIfNeeded(state)
        }
        .onChange(of: item.dismissalPolicy) { policy in
            if case .dismissible = policy {
                guardMessage = nil
            }
        }
    }

    @ViewBuilder
    private func actionButton(_ action: StrataDialogAction, item: StrataDialogPresentation) -> some View {
        let isLoading = isLoading(item.state)
        switch action.role {
        case .primary:
            Button(action.label) { perform(action, for: item) }
                .buttonStyle(.borderedProminent)
                .tint(configuration.theme.accent)
                .foregroundStyle(configuration.theme.onAccent)
                .keyboardShortcut(.defaultAction)
                .disabled(!action.isEnabled || (isLoading && action.role != .cancel))
                .frame(minHeight: configuration.minimumHit)
                .accessibilityIdentifier("strata-dialog-action-\(action.id)")
                .focused($ownedFocus, equals: action.id)
                .accessibilityFocused($ownedAccessibilityFocus, equals: action.id)
        case .destructive:
            Button(role: .destructive) { perform(action, for: item) } label: { Text(action.label) }
                .buttonStyle(.borderedProminent)
                .tint(configuration.destructiveColor)
                .foregroundStyle(configuration.onDestructiveColor)
                .disabled(!action.isEnabled || (isLoading && action.role != .cancel))
                .frame(minHeight: configuration.minimumHit)
                .accessibilityIdentifier("strata-dialog-action-\(action.id)")
                .focused($ownedFocus, equals: action.id)
                .accessibilityFocused($ownedAccessibilityFocus, equals: action.id)
        case .secondary:
            Button(action.label) { perform(action, for: item) }
                .buttonStyle(.bordered)
                .tint(configuration.theme.foreground)
                .disabled(!action.isEnabled || (isLoading && action.role != .cancel))
                .frame(minHeight: configuration.minimumHit)
                .accessibilityIdentifier("strata-dialog-action-\(action.id)")
                .focused($ownedFocus, equals: action.id)
                .accessibilityFocused($ownedAccessibilityFocus, equals: action.id)
        case .cancel:
            Button(role: .cancel) { perform(action, for: item) } label: { Text(action.label) }
                .buttonStyle(.bordered)
                .tint(configuration.theme.foreground)
                .disabled(!action.isEnabled)
                .frame(minHeight: configuration.minimumHit)
                .accessibilityIdentifier("strata-dialog-action-\(action.id)")
                .focused($ownedFocus, equals: action.id)
                .accessibilityFocused($ownedAccessibilityFocus, equals: action.id)
        }

    }

    private func isLoading(_ state: StrataDialogState) -> Bool {
        if case .loading = state {
            return true
        }
        return false
    }

    @ViewBuilder
    private func status(_ state: StrataDialogState) -> some View {
        switch state {
        case .populated:
            EmptyView()
        case .loading(let message):
            Text(message)
                .font(.system(size: configuration.body.size))
                .foregroundStyle(configuration.theme.secondaryForeground)
                .accessibilityIdentifier("strata-dialog-status")
        case .error(let message):
            Text(message)
                .font(.system(size: configuration.body.size))
                .foregroundStyle(configuration.theme.critical)
                .accessibilityIdentifier("strata-dialog-status")
        }
    }

    private func perform(_ action: StrataDialogAction, for item: StrataDialogPresentation) {
        let isLoading = isLoading(item.state)
        guard action.isEnabled, (!isLoading || action.role == .cancel),
              configuration.presentation.wrappedValue?.id == item.id else { return }
        synchronizeSession(for: item)
        guard let generation = session?.generation,
              session?.matches(id: item.id, generation: generation) == true else { return }
        if action.role == .cancel {
            guard case .dismissible = item.dismissalPolicy else {
                dismiss(item, reason: .cancel)
                return
            }
            configuration.presentation.wrappedValue = nil
            _ = action.perform()
            configuration.onDismiss(item.id, .cancel)
            restoreFocusIfNeeded()
            return
        }
        let outcome = action.perform()
        guard outcome == .dismiss,
              configuration.presentation.wrappedValue?.id == item.id,
              session?.matches(id: item.id, generation: generation) == true else { return }
        configuration.presentation.wrappedValue = nil
        configuration.onDismiss(item.id, .action(action.id))
        restoreFocusIfNeeded()
    }

    private func restoreFocusIfNeeded() {
        guard (ownedFocus != nil || ownedAccessibilityFocus != nil),
              configuration.presentation.wrappedValue == nil else { return }
        _ = configuration.restoreFocus()
        ownedFocus = nil
        ownedAccessibilityFocus = nil
        session?.invalidate()
        session = nil
        guardMessage = nil
    }

    private func synchronizeSession(for item: StrataDialogPresentation) {
        if session == nil {
            session = StrataModalSession(id: item.id)
        } else if session?.id != item.id {
            session?.replace(id: item.id)
        }
    }

    private func dismiss(_ item: StrataDialogPresentation, reason: StrataDialogDismissal) {
        guard configuration.presentation.wrappedValue?.id == item.id else { return }
        if reason == .outside, !item.allowsOutsideDismiss { return }
        if case .guarded(let guardReason) = item.dismissalPolicy,
           reason == .close || reason == .cancel || reason == .escape || reason == .outside {
            guardMessage = guardReason
            return
        }
        configuration.presentation.wrappedValue = nil
        configuration.onDismiss(item.id, reason)
        restoreFocusIfNeeded()
    }

    private func guardReason(for item: StrataDialogPresentation) -> String? {
        guard case .guarded(let reason) = item.dismissalPolicy else { return nil }
        return reason
    }

    private func announceStatusIfNeeded(_ state: StrataDialogState) {
        guard state != .populated, announcedStatus != state else { return }
        announcedStatus = state
        if #available(iOS 17.0, macOS 14.0, *) {
            switch state {
            case .loading(let message), .error(let message):
                AccessibilityNotification.Announcement(message).post()
            case .populated:
                break
            }
        }
    }
}

@MainActor
public struct StrataAlertDialog<Base: View>: View {
    @MainActor
    public struct Configuration {
        let theme: StrataTheme
        let isPresented: Binding<Bool>
        let title: String
        let message: String
        let confirmLabel: String
        let cancelLabel: String
        let isDestructive: Bool
        let confirm: @MainActor () -> Void
        let base: Base

        public init(
            theme: StrataTheme,
            isPresented: Binding<Bool>,
            title: String,
            message: String,
            confirmLabel: String,
            cancelLabel: String,
            isDestructive: Bool = false,
            confirm: @escaping @MainActor () -> Void,
            @ViewBuilder base: () -> Base
        ) throws {
            guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw StrataDialogConfigurationError.emptyTitle
            }
            guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw StrataDialogConfigurationError.emptyStatusMessage
            }
            guard !confirmLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw StrataDialogConfigurationError.emptyActionLabel
            }
            guard !cancelLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw StrataDialogConfigurationError.emptyCloseLabel
            }
            self.theme = theme
            self.isPresented = isPresented
            self.title = title
            self.message = message
            self.confirmLabel = confirmLabel
            self.cancelLabel = cancelLabel
            self.isDestructive = isDestructive
            self.confirm = confirm
            self.base = base()
        }
    }

    private let configuration: Configuration

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        configuration.base
            .environment(\.colorScheme, configuration.theme.mode == .light ? .light : .dark)
            .preference(key: StrataModalVisibilityPreference.self, value: configuration.isPresented.wrappedValue)
            .environment(\.strataPresentationObscured, configuration.isPresented.wrappedValue)
            .alert(configuration.title, isPresented: configuration.isPresented) {
                Button(configuration.cancelLabel, role: .cancel) {}
                Button(configuration.confirmLabel, role: configuration.isDestructive ? .destructive : nil) {
                    configuration.confirm()
                }
            } message: {
                Text(configuration.message)
            }
    }
}

private extension View {
    @ViewBuilder
    func dialogEscapeDismissal(enabled: Bool, perform action: @escaping () -> Void) -> some View {
#if os(macOS)
        if enabled {
            onExitCommand(perform: action)
        } else {
            self
        }
#else
        self
#endif
    }

    @ViewBuilder
    func dialogCancelShortcut(enabled: Bool) -> some View {
        if enabled {
            keyboardShortcut(.escape, modifiers: [])
        } else {
            self
        }
    }
}
