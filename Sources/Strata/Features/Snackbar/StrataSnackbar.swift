import DesignTokens
import SwiftUI

public enum StrataSnackbarConfigurationError: Error, Equatable, Sendable {
    case emptyMessage
    case emptyCloseLabel
    case emptyActionLabel
}

public struct StrataSnackbarAction: Sendable {
    public let label: String
    public let perform: @Sendable @MainActor () -> Void

    @MainActor
    public init(label: String, perform: @escaping @Sendable @MainActor () -> Void) throws {
        guard !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw StrataSnackbarConfigurationError.emptyActionLabel
        }
        self.label = label
        self.perform = perform
    }
}

public struct StrataSnackbarItem: Identifiable, Sendable {
    public let id: UUID
    public let message: String
    public let closeLabel: String
    public let action: StrataSnackbarAction?

    @MainActor
    public init(
        id: UUID = UUID(),
        message: String,
        closeLabel: String,
        action: StrataSnackbarAction? = nil
    ) throws {
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw StrataSnackbarConfigurationError.emptyMessage
        }
        guard !closeLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw StrataSnackbarConfigurationError.emptyCloseLabel
        }
        self.id = id
        self.message = message
        self.closeLabel = closeLabel
        self.action = action
    }
}

public enum StrataSnackbarDismissal: Equatable, Sendable {
    case timeout
    case action
    case close
    case escape
}

struct StrataPresentationObscuredKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var strataPresentationObscured: Bool {
        get { self[StrataPresentationObscuredKey.self] }
        set { self[StrataPresentationObscuredKey.self] = newValue }
    }
}

struct StrataModalVisibilityPreference: PreferenceKey {
    static let defaultValue = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

struct StrataFeedbackLifetime: Sendable {
    private(set) var remaining: TimeInterval = 0
    private(set) var generation: UInt64 = 0
    private(set) var currentID: UUID?
    private var lastNow: TimeInterval?
    private var paused = false
    private var hasAction = false
    private var hostEpoch: UUID?

    mutating func synchronize(id: UUID?, hasAction: Bool, hostEpoch: UUID, now: TimeInterval) {
        guard id != currentID || hostEpoch != self.hostEpoch || self.hasAction != hasAction else {
            advance(to: now)
            return
        }
        currentID = id
        self.hostEpoch = hostEpoch
        self.hasAction = hasAction
        remaining = id == nil ? 0 : (hasAction ? .infinity : 5)
        lastNow = now
        generation &+= 1
    }

    mutating func setPaused(_ value: Bool, now: TimeInterval) {
        advance(to: now)
        paused = value
        lastNow = now
    }

    mutating func cancel() {
        currentID = nil
        remaining = 0
        lastNow = nil
        generation &+= 1
    }

    func permitsExpiry(id: UUID, hostEpoch: UUID, generation: UInt64, now: TimeInterval) -> Bool {
        currentID == id && self.hostEpoch == hostEpoch && self.generation == generation &&
            !paused && !hasAction && remaining <= 0 && (lastNow.map { now - $0 >= remaining } ?? false)
    }

    private mutating func advance(to now: TimeInterval) {
        guard let lastNow, !paused, remaining.isFinite else {
            self.lastNow = now
            return
        }
        remaining = max(0, remaining - max(0, now - lastNow))
        self.lastNow = now
    }
}

@MainActor
public struct StrataSnackbar<Content: View, BottomBar: View>: View {
    @MainActor
    public struct Configuration {
        let theme: StrataTheme
        let item: Binding<StrataSnackbarItem?>
        let isPresentationObscured: Bool
        let restoreFocus: @MainActor () -> Bool
        let onDismiss: @MainActor (UUID, StrataSnackbarDismissal) -> Void
        let content: Content
        let bottomBar: BottomBar
        let radius: CGFloat
        let controlRadius: CGFloat
        let spacingXS: CGFloat
        let spacingSM: CGFloat
        let spacingMD: CGFloat
        let spacingLG: CGFloat
        let minimumHit: CGFloat
        let border: CGFloat
        let bodyTypography: TypographyToken
        let calloutTypography: TypographyToken

        public init(
            theme: StrataTheme,
            item: Binding<StrataSnackbarItem?>,
            isPresentationObscured: Bool = false,
            restoreFocus: @escaping @MainActor () -> Bool = { false },
            onDismiss: @escaping @MainActor (UUID, StrataSnackbarDismissal) -> Void = { _, _ in },
            @ViewBuilder content: () -> Content,
            @ViewBuilder bottomBar: () -> BottomBar
        ) throws {
            self.theme = theme
            self.item = item
            self.isPresentationObscured = isPresentationObscured
            self.restoreFocus = restoreFocus
            self.onDismiss = onDismiss
            self.content = content()
            self.bottomBar = bottomBar()
            // The consolidated provider currently exposes these geometry values
            // through its stable spacing scale.
            radius = try CGFloat(StyleTokens.radius("radius.large"))
            controlRadius = try CGFloat(StyleTokens.radius("radius.medium"))
            spacingXS = try CGFloat(StyleTokens.spacing("spacing.xs"))
            spacingSM = try CGFloat(StyleTokens.spacing("spacing.sm"))
            spacingMD = try CGFloat(StyleTokens.spacing("spacing.md"))
            spacingLG = try CGFloat(StyleTokens.spacing("spacing.lg"))
            minimumHit = try CGFloat(StyleTokens.dimension("dimension.hit.minimum"))
            border = try CGFloat(StyleTokens.border("border.regular"))
            let subtleOpacity = try StyleTokens.opacity("opacity.subtle")
            self.borderOpacity = CGFloat(subtleOpacity)
            bodyTypography = try StyleTokens.typography("typography.body")
            calloutTypography = try StyleTokens.typography("typography.callout")
        }

        let borderOpacity: CGFloat
    }

    private let configuration: Configuration
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.strataPresentationObscured) private var environmentObscured
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var lifetime = StrataFeedbackLifetime()
    @State private var hostEpoch = UUID()
    @State private var modalVisible = false
    @State private var isHovered = false
    @FocusState private var isFocused: Bool
    @FocusState private var ownedFocus: FocusTarget?
    @AccessibilityFocusState private var ownedAccessibilityFocus: FocusTarget?
    @State private var announcedItemID: UUID?

    private enum FocusTarget: Hashable {
        case action
        case close
    }

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            configuration.content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: configuration.spacingSM) {
                if let item = configuration.item.wrappedValue, !isObscured {
                    snackbar(item)
                        .padding(.horizontal, configuration.spacingMD)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                configuration.bottomBar
                    .padding(.horizontal, configuration.spacingMD)
            }
            .padding(.bottom, configuration.spacingSM)
        }
        .background(configuration.theme.canvas.ignoresSafeArea())
        .environment(\.colorScheme, configuration.theme.mode == .light ? .light : .dark)
        .onPreferenceChange(StrataModalVisibilityPreference.self) { modalVisible = $0 }
        .onChange(of: isPaused) { paused in
            lifetime.setPaused(paused, now: ProcessInfo.processInfo.systemUptime)
        }
        .onChange(of: scenePhase) { phase in
            lifetime.setPaused(
                phase != .active || isFocusedOrHoveredOrObscured,
                now: ProcessInfo.processInfo.systemUptime
            )
        }
        .onChange(of: configuration.item.wrappedValue?.id) { _ in
            synchronizeLifetime()
            announceIfNeeded()
        }
        .onChange(of: isObscured) { _ in announceIfNeeded() }
        .onAppear {
            synchronizeLifetime()
            announceIfNeeded()
        }
        .task(id: configuration.item.wrappedValue?.id) { await monitorLifetime() }
    }

    private func snackbar(_ item: StrataSnackbarItem) -> some View {
        HStack(spacing: configuration.spacingSM) {
            Text(item.message)
                .font(.system(size: configuration.bodyTypography.size,
                              weight: .regular,
                              design: .default))
                .foregroundStyle(configuration.theme.foreground)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("strata-snackbar-message")
            if let action = item.action {
                Button(action.label) {
                    dismiss(item, reason: .action)
                }
                .font(.system(size: configuration.calloutTypography.size, weight: .semibold))
                .frame(minWidth: configuration.minimumHit, minHeight: configuration.minimumHit)
                .accessibilityIdentifier("strata-snackbar-action")
                .focused($ownedFocus, equals: .action)
                .accessibilityFocused($ownedAccessibilityFocus, equals: .action)
            }
            Button(item.closeLabel) {
                dismiss(item, reason: .close)
            }
            .font(.system(size: configuration.calloutTypography.size, weight: .semibold))
            .frame(minWidth: configuration.minimumHit, minHeight: configuration.minimumHit)
            .accessibilityIdentifier("strata-snackbar-close")
            .focused($ownedFocus, equals: .close)
            .accessibilityFocused($ownedAccessibilityFocus, equals: .close)
        }
        .padding(.horizontal, configuration.spacingMD)
        .padding(.vertical, configuration.spacingXS)
        .frame(maxWidth: .infinity, minHeight: configuration.minimumHit)
        .background(
            RoundedRectangle(cornerRadius: configuration.radius, style: .continuous)
                .fill(configuration.theme.surface(.card))
        )
        .overlay {
            RoundedRectangle(cornerRadius: configuration.radius, style: .continuous)
                .stroke(configuration.theme.foreground.opacity(configuration.borderOpacity), lineWidth: configuration.border)
        }
        .onHover { isHovered = $0 }
        .focused($isFocused)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("strata-snackbar")
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: item.id)
        .escapeDismissal { dismiss(item, reason: .escape) }
    }

    private var isPaused: Bool {
        isFocusedOrHoveredOrObscured || ownedFocus != nil || ownedAccessibilityFocus != nil
    }

    private var isFocusedOrHoveredOrObscured: Bool {
        isFocused || isHovered || scenePhase != .active || environmentObscured ||
            configuration.isPresentationObscured || modalVisible
    }

    private var isObscured: Bool {
        configuration.isPresentationObscured || environmentObscured || modalVisible
    }

    private func synchronizeLifetime() {
        let now = ProcessInfo.processInfo.systemUptime
        if isPaused {
            lifetime.setPaused(true, now: now)
        }
        lifetime.synchronize(
            id: configuration.item.wrappedValue?.id,
            hasAction: configuration.item.wrappedValue?.action != nil,
            hostEpoch: hostEpoch,
            now: now
        )
        lifetime.setPaused(isPaused, now: now)
    }

    private func dismiss(_ item: StrataSnackbarItem, reason: StrataSnackbarDismissal) {
        guard configuration.item.wrappedValue?.id == item.id else { return }
        let shouldRestoreFocus = ownedFocus != nil || ownedAccessibilityFocus != nil
        lifetime.cancel()
        configuration.item.wrappedValue = nil
        if reason == .action {
            item.action?.perform()
        }
        configuration.onDismiss(item.id, reason)
        if configuration.item.wrappedValue != nil {
            synchronizeLifetime()
        } else if shouldRestoreFocus {
            _ = configuration.restoreFocus()
        }
    }

    private func monitorLifetime() async {
        while !Task.isCancelled {
            do {
                try await Task.sleep(nanoseconds: 100_000_000)
            } catch {
                return
            }
            guard let item = configuration.item.wrappedValue else { return }
            let now = ProcessInfo.processInfo.systemUptime
            if isPaused {
                lifetime.setPaused(true, now: now)
            }
            lifetime.synchronize(id: item.id, hasAction: item.action != nil, hostEpoch: hostEpoch, now: now)
            lifetime.setPaused(isPaused, now: now)
            let generation = lifetime.generation
            if lifetime.remaining <= 0, lifetime.permitsExpiry(
                id: item.id, hostEpoch: hostEpoch, generation: generation, now: now
            ) {
                dismiss(item, reason: .timeout)
                return
            }
        }

    }

    private func announceIfNeeded() {
        guard let item = configuration.item.wrappedValue, !isObscured, announcedItemID != item.id else {
            return
        }
        announcedItemID = item.id
        if #available(iOS 17.0, macOS 14.0, *) {
            AccessibilityNotification.Announcement(item.message).post()
        }
    }
}

private extension View {
    @ViewBuilder
    func escapeDismissal(perform action: @escaping () -> Void) -> some View {
#if os(macOS)
        onExitCommand(perform: action)
#else
        self
#endif
    }
}

@MainActor
public extension StrataSnackbar where BottomBar == EmptyView {
    init(
        theme: StrataTheme,
        item: Binding<StrataSnackbarItem?>,
        isPresentationObscured: Bool = false,
        restoreFocus: @escaping @MainActor () -> Bool = { false },
        onDismiss: @escaping @MainActor (UUID, StrataSnackbarDismissal) -> Void = { _, _ in },
        @ViewBuilder content: () -> Content
    ) throws {
        self.init(configuration: try Configuration(
            theme: theme,
            item: item,
            isPresentationObscured: isPresentationObscured,
            restoreFocus: restoreFocus,
            onDismiss: onDismiss,
            content: content,
            bottomBar: { EmptyView() }
        ))
    }
}
