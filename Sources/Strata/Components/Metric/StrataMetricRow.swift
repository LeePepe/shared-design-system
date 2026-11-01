import SwiftUI

/// A compact, data-only metric displayed beneath a telemetry card instrument.
public struct StrataMetricRowItem: Sendable, Equatable, Identifiable {
    public let id: String
    public let key: String
    public let value: String

    public init(id: String? = nil, key: String, value: String) {
        let resolvedID = id ?? key
        precondition(Self.accepts(key: key, value: value), "StrataMetricRowItem values must be valid, single-line telemetry text.")
        self.id = resolvedID
        self.key = key
        self.value = value
    }

    static func accepts(key: String, value: String) -> Bool {
        acceptsLabel(key) && acceptsReadout(value)
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

public struct StrataMetricRow: View {
    private let theme: StrataTheme
    private let item: StrataMetricRowItem
    private let instrument: Bool
    private let progress: Double?
    private let total: Double

    public init(
        theme: StrataTheme,
        item: StrataMetricRowItem,
        instrument: Bool = false,
        progress: Double? = nil,
        total: Double = 1
    ) {
        if instrument {
            precondition(StrataProgressBarValue.accepts(value: progress, total: total),
                         "StrataMetricRow instruments require a finite positive total and a finite value or nil.")
        }
        self.theme = theme
        self.item = item
        self.instrument = instrument
        self.progress = progress
        self.total = total
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 6) {
            if instrument {
                StrataProgressRing(theme: theme, value: progress, total: total)
            }
            Text(verbatim: item.key)
                .font(.caption)
                .foregroundStyle(theme.secondaryForeground)
                .lineLimit(1)
                .layoutPriority(0)
            Spacer(minLength: 0)
            Text(verbatim: item.value)
                .font(.caption.monospacedDigit())
                .foregroundStyle(theme.foreground)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .layoutPriority(1)
        }
        .frame(minHeight: instrument ? 24 : 18, maxHeight: instrument ? 24 : 18, alignment: .center)
        .alignmentGuide(.strataControlCenter) { $0[VerticalAlignment.center] }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(verbatim: "\(item.key), \(item.value)"))
        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
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
