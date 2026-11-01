import SwiftUI

public enum StrataNumericKeypadMode: Sendable, Equatable {
    case decimal
    case integer
}

public enum StrataNumericKeypadKey: Sendable, Equatable {
    case digit(Int)
    case decimalSeparator
    case backspace
    case sideAction(id: String)
    case done
}

public struct StrataNumericKeypadSideAction: Sendable, Equatable, Identifiable {
    public let id: String
    public let title: String
    public let systemImage: String?

    public init(id: String, title: String, systemImage: String? = nil) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
    }
}

public struct StrataNumericKeypadConfiguration: Sendable, Equatable {
    public let mode: StrataNumericKeypadMode
    public let leftActions: [StrataNumericKeypadSideAction]
    public let rightActions: [StrataNumericKeypadSideAction]
    public let doneLabel: String

    public init(
        mode: StrataNumericKeypadMode = .decimal,
        leftActions: [StrataNumericKeypadSideAction] = [],
        rightActions: [StrataNumericKeypadSideAction] = [],
        doneLabel: String = "Done"
    ) {
        self.mode = mode
        self.leftActions = leftActions
        self.rightActions = rightActions
        self.doneLabel = doneLabel
    }

    public init(
        mode: StrataNumericKeypadMode,
        leadingActions: [StrataNumericKeypadSideAction],
        trailingActions: [StrataNumericKeypadSideAction],
        doneTitle: String
    ) {
        self.init(mode: mode, leftActions: leadingActions, rightActions: trailingActions, doneLabel: doneTitle)
    }

    public var leadingActions: [StrataNumericKeypadSideAction] { leftActions }
    public var trailingActions: [StrataNumericKeypadSideAction] { rightActions }
    public var doneTitle: String { doneLabel }
}

/// A compact, explicit-theme numeric keypad for detached input hosts.
public struct StrataNumericKeypad: View {
    private let theme: StrataTheme
    private let configuration: StrataNumericKeypadConfiguration
    private let metrics: StrataNumericKeypadMetrics
    private let colorScheme: ColorScheme
    private let onKey: (StrataNumericKeypadKey) -> Void

    public init(
        theme: StrataTheme,
        configuration: StrataNumericKeypadConfiguration = .init(),
        colorScheme: ColorScheme? = nil,
        onKey: @escaping (StrataNumericKeypadKey) -> Void
    ) throws {
        self.theme = theme
        self.configuration = configuration
        self.metrics = try StrataNumericKeypadMetrics()
        self.colorScheme = colorScheme ?? (theme.mode == .light ? .light : .dark)
        self.onKey = onKey
    }

    public var body: some View {
        HStack(spacing: metrics.interColumnSpacing) {
            actionColumn(configuration.leftActions, includesDone: false)
            digitGrid
            actionColumn(configuration.rightActions, includesDone: true)
        }
        .padding(.horizontal, metrics.horizontalPadding)
        .padding(.vertical, metrics.verticalPadding)
        .frame(maxWidth: .infinity)
        .frame(height: metrics.totalGridHeight)
        .overlay(alignment: .top) {
            Rectangle().fill(theme.material.edge).frame(height: 1)
        }
        .environment(\.colorScheme, colorScheme)
    }

    private var digitGrid: some View {
        let keys: [StrataNumericKeypadKey] = (1...9).map { .digit($0) } +
            (configuration.mode == .decimal ? [.decimalSeparator, .digit(0), .backspace] : [.decimalSeparator, .digit(0), .backspace])
        return LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: metrics.interColumnSpacing), count: 3),
            spacing: metrics.interRowSpacing
        ) {
            ForEach(Array(keys.enumerated()), id: \.offset) { _, key in
                keyButton(key, title: title(for: key), prominent: false)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: metrics.digitRowHeight * 4 + metrics.interRowSpacing * 3)
    }

    private func actionColumn(_ actions: [StrataNumericKeypadSideAction], includesDone: Bool) -> some View {
        let slots = includesDone
            ? actions.map { Optional($0) } + [nil]
            : actions.map { Optional($0) }
        return VStack(spacing: metrics.interRowSpacing) {
            if slots.isEmpty {
                Color.clear
            } else {
                ForEach(Array(slots.enumerated()), id: \.offset) { index, action in
                    if let action {
                        keyButton(.sideAction(id: action.id), title: action.title, image: action.systemImage, prominent: false)
                    } else if includesDone && index == slots.count - 1 {
                        keyButton(.done, title: configuration.doneLabel, prominent: true)
                    } else {
                        Color.clear
                    }
                }
            }
        }
        .frame(width: metrics.sideColumnWidth, height: metrics.digitRowHeight * 4 + metrics.interRowSpacing * 3)
        .frame(maxHeight: .infinity)
    }

    private func keyButton(_ key: StrataNumericKeypadKey, title: String, image: String? = nil, prominent: Bool) -> some View {
        Button { onKey(key) } label: {
            Group {
                if let image {
                    Label(title, systemImage: image)
                } else {
                    Text(title)
                }
            }
            .font(prominent ? .caption.weight(.medium) : key.isDigit ? .title3.monospacedDigit() : .caption.weight(.medium))
            .lineLimit(1)
            .minimumScaleFactor(metrics.minimumScaleFactor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(RoundedRectangle(cornerRadius: metrics.compactCellRadius))
        }
        .buttonStyle(StrataNumericKeypadButtonStyle(theme: theme, radius: metrics.compactCellRadius, prominent: prominent))
    }

    private func title(for key: StrataNumericKeypadKey) -> String {
        switch key {
        case .digit(let value): String(value)
        case .decimalSeparator: "."
        case .backspace: "Delete"
        case .sideAction: ""
        case .done: configuration.doneTitle
        }
    }
}

private extension StrataNumericKeypadKey {
    var isDigit: Bool {
        if case .digit = self { return true }
        return false
    }
}

private struct StrataNumericKeypadButtonStyle: ButtonStyle {
    let theme: StrataTheme
    let radius: CGFloat
    let prominent: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(prominent ? theme.onInteractiveAccent : theme.foreground)
            .background(prominent ? theme.interactiveAccent : theme.surface(.inset))
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .opacity(configuration.isPressed ? 0.82 : 1)
    }
}
