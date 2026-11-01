import SwiftUI

public enum StrataBentoInstrument: Sendable, Equatable {
    case none
    case progressRing(value: Double?, total: Double)
    case progressBar(value: Double?, total: Double)
}

public struct StrataBentoCardConfiguration: Sendable, Equatable {
    public let title: String
    public let primaryReadout: String
    public let statusBadgeText: String?
    public let instrument: StrataBentoInstrument
    public let rows: [StrataMetricRowItem]
    public let hostWidth: CGFloat?

    public init(
        title: String,
        primaryReadout: String,
        statusBadgeText: String? = nil,
        instrument: StrataBentoInstrument = .none,
        rows: [StrataMetricRowItem] = [],
        hostWidth: CGFloat? = nil
    ) {
        precondition(Self.accepts(
            title: title,
            primaryReadout: primaryReadout,
            statusBadgeText: statusBadgeText,
            instrument: instrument,
            hostWidth: hostWidth
        ), "StrataBentoCardConfiguration contains invalid telemetry content.")
        self.title = title
        self.primaryReadout = primaryReadout
        self.statusBadgeText = statusBadgeText
        self.instrument = instrument
        self.rows = rows
        self.hostWidth = hostWidth
    }

    static func accepts(
        title: String,
        primaryReadout: String,
        statusBadgeText: String? = nil,
        instrument: StrataBentoInstrument = .none,
        hostWidth: CGFloat? = nil
    ) -> Bool {
        acceptsLabel(title) &&
            acceptsReadout(primaryReadout) &&
            (statusBadgeText.map(acceptsReadout) ?? true) &&
            (hostWidth.map { $0 > 0 } ?? true) &&
            acceptsInstrument(instrument)
    }

    private static func acceptsInstrument(_ instrument: StrataBentoInstrument) -> Bool {
        switch instrument {
        case .none:
            true
        case let .progressRing(value, total), let .progressBar(value, total):
            StrataProgressBarValue.accepts(value: value, total: total)
        }
    }

    private static func acceptsLabel(_ label: String) -> Bool {
        let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty &&
            !label.containsNewline &&
            label.count <= (label.containsCJK ? 4 : 8)
    }

    private static func acceptsReadout(_ readout: String) -> Bool {
        !readout.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !readout.containsNewline &&
            !readout.contains("…") &&
            !readout.contains("...")
    }
}

public struct StrataBentoCard: View {
    private let theme: StrataTheme
    private let configuration: StrataBentoCardConfiguration

    public init(theme: StrataTheme, configuration: StrataBentoCardConfiguration) {
        self.theme = theme
        self.configuration = configuration
    }

    public var body: some View {
        cardBody
            .padding(12)
            .strataSurface(theme: theme, style: .solid, cornerRadius: 16, role: .card)
            .frame(width: configuration.hostWidth)
    }

    private var cardBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 6) {
                Text(verbatim: configuration.title)
                    .font(.caption)
                    .foregroundStyle(theme.secondaryForeground)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Text(verbatim: configuration.primaryReadout)
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(theme.foreground)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .layoutPriority(1)
            }
            .frame(height: 22)
            .accessibilityAddTraits(.isHeader)

            instrumentView
                .frame(height: instrumentHeight)

            ForEach(configuration.rows) { item in
                StrataMetricRow(theme: theme, item: item)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
    }

    @ViewBuilder
    private var instrumentView: some View {
        switch configuration.instrument {
        case .none:
            EmptyView()
        case let .progressRing(value, total):
            HStack(spacing: 6) {
                StrataProgressRing(theme: theme, value: value, total: total)
                if let statusBadgeText = configuration.statusBadgeText {
                    Text(verbatim: statusBadgeText)
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(theme.secondaryForeground)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case let .progressBar(value, total):
            if let statusBadgeText = configuration.statusBadgeText {
                StrataProgressBar(theme: theme, value: value, total: total) {
                    EmptyView()
                } currentValueLabel: {
                    Text(verbatim: statusBadgeText)
                        .font(.caption.monospacedDigit())
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            } else {
                StrataProgressBar(theme: theme, value: value, total: total) {
                    EmptyView()
                } currentValueLabel: {
                    EmptyView()
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var instrumentHeight: CGFloat {
        switch configuration.instrument {
        case .none: 0
        case .progressRing, .progressBar: 48
        }
    }
}

private extension String {
    var containsNewline: Bool {
        contains("\n") || contains("\r")
    }

    var containsCJK: Bool {
        unicodeScalars.contains {
            (0x4E00...0x9FFF).contains($0.value) ||
            (0x3400...0x4DBF).contains($0.value) ||
            (0x3040...0x30FF).contains($0.value)
        }
    }
}
