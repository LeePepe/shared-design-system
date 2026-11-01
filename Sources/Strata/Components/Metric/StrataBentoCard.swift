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
        precondition(Self.isValidLabel(title), "StrataBentoCard titles must be one line and at most eight characters.")
        precondition(!primaryReadout.isEmpty && !primaryReadout.contains("…"),
                     "StrataBentoCard primary readouts must be present and must not be truncated.")
        if let statusBadgeText {
            precondition(!statusBadgeText.isEmpty && !statusBadgeText.contains("…"),
                         "StrataBentoCard status badges must be present and must not be truncated.")
        }
        if let hostWidth {
            precondition(hostWidth > 0, "StrataBentoCard host width must be positive.")
        }
        switch instrument {
        case let .progressRing(value, total), let .progressBar(value, total):
            precondition(StrataProgressBarValue.accepts(value: value, total: total),
                         "StrataBentoCard instruments require a finite positive total and a finite value or nil.")
        case .none:
            break
        }
        self.title = title
        self.primaryReadout = primaryReadout
        self.statusBadgeText = statusBadgeText
        self.instrument = instrument
        self.rows = rows
        self.hostWidth = hostWidth
    }

    private static func isValidLabel(_ label: String) -> Bool {
        !label.isEmpty && label.count <= (label.containsCJK ? 4 : 8)
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
            StrataProgressBar(theme: theme, value: value, total: total) {
                EmptyView()
            } currentValueLabel: {
                Text(verbatim: configuration.statusBadgeText ?? configuration.primaryReadout)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var instrumentHeight: CGFloat {
        switch configuration.instrument {
        case .none: 0
        case .progressRing: 44
        case .progressBar: 52
        }
    }
}

private extension String {
    var containsCJK: Bool {
        unicodeScalars.contains {
            (0x4E00...0x9FFF).contains($0.value) ||
            (0x3400...0x4DBF).contains($0.value) ||
            (0x3040...0x30FF).contains($0.value)
        }
    }
}
