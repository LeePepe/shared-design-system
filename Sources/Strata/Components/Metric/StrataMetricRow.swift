import SwiftUI

/// A compact, data-only metric displayed beneath a telemetry card instrument.
public struct StrataMetricRowItem: Sendable, Equatable, Identifiable {
    public let id: String
    public let key: String
    public let value: String

    public init(id: String? = nil, key: String, value: String) {
        let resolvedID = id ?? key
        precondition(Self.isValidLabel(key), "StrataMetricRowItem keys must be one line and at most eight characters.")
        precondition(!value.contains("…"), "StrataMetricRowItem values must not contain numeric truncation.")
        self.id = resolvedID
        self.key = key
        self.value = value
    }

    private static func isValidLabel(_ label: String) -> Bool {
        !label.isEmpty && label.count <= (label.containsCJK ? 4 : 8)
    }
}

public struct StrataMetricRow: View {
    private let theme: StrataTheme
    private let item: StrataMetricRowItem
    private let instrument: Bool

    public init(theme: StrataTheme, item: StrataMetricRowItem, instrument: Bool = false) {
        self.theme = theme
        self.item = item
        self.instrument = instrument
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 6) {
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
        .frame(minHeight: 18, maxHeight: 18, alignment: .center)
        .alignmentGuide(.strataControlCenter) { $0[VerticalAlignment.center] }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(verbatim: "\(item.key), \(item.value)"))
        .modifier(StrataMetricRowInstrumentModifier(theme: theme, visible: instrument))
    }
}

private struct StrataMetricRowInstrumentModifier: ViewModifier {
    let theme: StrataTheme
    let visible: Bool

    func body(content: Content) -> some View {
        if visible {
            HStack(spacing: 4) {
                StrataProgressRing(theme: theme, value: nil, total: 1)
                content
            }
        } else {
            content
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
