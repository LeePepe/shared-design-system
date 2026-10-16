import NativeDesignKit
import SwiftUI

/// Synthetic caller state only; no product integration or loading engine.
@main
struct ProgressBarReviewApp: App {
    private let configuration = Result { try ReviewConfiguration() }

    var body: some Scene {
        WindowGroup {
            switch configuration {
            case .success(let configuration):
                ProgressReviewBoard(configuration: configuration)
                    .preferredColorScheme(configuration.isDark ? .dark : .light)
            case .failure(let error):
                VStack(alignment: .leading, spacing: 16) {
                    Text("Fixture configuration failed").font(.title)
                    Text(String(describing: error)).accessibilityIdentifier("fixture-error")
                }
                .padding()
            }
        }
    }
}

private struct ReviewConfiguration {
    enum ConfigurationError: Error { case missing(String), invalid(String) }
    let theme: NativeDesignTheme
    let brand: String
    let mode: String
    let scenario: String
    let textSize: DynamicTypeSize
    let requestsReducedMotion: Bool
    var isDark: Bool { mode == "dark" }

    init() throws {
        let environment = ProcessInfo.processInfo.environment
        func required(_ name: String) throws -> String {
            guard let value = environment[name], !value.isEmpty else {
                throw ConfigurationError.missing(name)
            }
            return value
        }
        brand = try required("NDK_BRAND")
        mode = try required("NDK_THEME")
        scenario = try required("NDK_SCENARIO")
        guard ["matrix", "interaction", "long-label"].contains(scenario) else {
            throw ConfigurationError.invalid("NDK_SCENARIO")
        }
        switch mode {
        case "light": theme = try NativeDesignTheme(theme: .light, brand: brand)
        case "dark": theme = try NativeDesignTheme(theme: .dark, brand: brand)
        default: throw ConfigurationError.invalid("NDK_THEME")
        }
        switch try required("NDK_TEXT_SIZE") {
        case "large": textSize = .large
        case "accessibility2": textSize = .accessibility2
        default: throw ConfigurationError.invalid("NDK_TEXT_SIZE")
        }
        switch try required("NDK_REDUCE_MOTION_REQUEST") {
        case "false": requestsReducedMotion = false
        case "true": requestsReducedMotion = true
        default: throw ConfigurationError.invalid("NDK_REDUCE_MOTION_REQUEST")
        }
    }
}

private struct ProgressReviewBoard: View {
    let configuration: ReviewConfiguration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var state = 0
    @State private var bounds: [String: CGRect] = [:]
    private var theme: NativeDesignTheme { configuration.theme }
    private let longLabel = "Vorbereitung aller ausgewählten Dateien für die nächste Übertragung"
    private let longValue = "50 von 100 Dateien vorbereitet — bitte warten Sie auf die nächste Aktualisierung"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Native Progress Bar").font(.title.bold())
                Text("\(configuration.brand.capitalized) · \(configuration.mode.capitalized) · iOS SwiftUI")
                    .font(.subheadline).foregroundStyle(theme.secondaryForeground)
                switch configuration.scenario {
                case "matrix": matrix
                case "long-label": longLabelBoard
                default: interaction
                }
                Text("Synthetic review data · caller-owned state")
                    .font(.caption).foregroundStyle(theme.secondaryForeground)
                    .accessibilityIdentifier("review-end")
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityIdentifier("review-scroll")
        .foregroundStyle(theme.foreground)
        .background(theme.canvas.ignoresSafeArea())
        .dynamicTypeSize(.large)
    }

    private var matrix: some View {
        VStack(alignment: .leading, spacing: 24) {
            sample("Zero", value: 0, current: "0 of 100 files · 0%", id: "matrix-zero")
            sample("In progress", value: 50, current: "50 of 100 files · 50%", id: "matrix-mid")
            sample("Complete", value: 100, current: "100 of 100 files · 100%", id: "matrix-complete")
            sample("Waiting", value: nil, current: "Waiting for the next update…", id: "matrix-indeterminate")
            Text(configuration.requestsReducedMotion ? "Fixture request: Reduce Motion" : "Fixture request: standard motion")
                .font(.caption).accessibilityIdentifier("motion-request")
            Text("Observed system Reduce Motion: \(reduceMotion ? "on" : "off")")
                .font(.caption).accessibilityIdentifier("motion-observed")
            Text("Native animation behavior is platform-owned.").font(.caption)
        }
    }

    private var interaction: some View {
        VStack(alignment: .leading, spacing: 20) {
            sample("Preparing files", value: interactionValue,
                   current: interactionText, id: "progress-target")
                .background(measure("interaction"))
                .coordinateSpace(name: "progress-measurement")
                .onPreferenceChange(ReviewBounds.self) { bounds = $0 }
            Text("State: \(state)").accessibilityIdentifier("caller-state")
            Text("Rendered progress size").font(.caption)
                .accessibilityIdentifier("progress-footprint")
                .accessibilityValue(Text(verbatim: "\(bounds["interaction"]?.width ?? 0)|\(bounds["interaction"]?.height ?? 0)"))
            Button("Next synthetic state") { state = (state + 1) % 6 }
                .font(.body)
                .padding(12)
                .frame(minWidth: 44, minHeight: 44)
                .background(theme.surface, in: RoundedRectangle(cornerRadius: 16))
                .accessibilityIdentifier("next-state")
            Text("States: zero, middle, complete, waiting, below zero, above total")
                .font(.caption)
        }
        .buttonStyle(.plain)
    }

    private var interactionValue: Double? {
        switch state {
        case 0: 0
        case 1: 50
        case 2: 100
        case 3: nil
        case 4: -20
        default: 120
        }
    }

    private var interactionText: String {
        switch state {
        case 0, 4: "0 of 100 files"
        case 1: "50 of 100 files"
        case 2, 5: "100 of 100 files"
        default: "Waiting for update"
        }
    }

    private var longLabelBoard: some View {
        VStack(alignment: .leading, spacing: 12) {
            NativeProgressBar(theme: theme, value: 50, total: 100) {
                Text(verbatim: longLabel).background(measure("label"))
            } currentValueLabel: {
                Text(verbatim: longValue).background(measure("value"))
            }
            .dynamicTypeSize(configuration.textSize)
            .accessibilityIdentifier("long-progress")
            .background(measure("outer"))
            .coordinateSpace(name: "progress-measurement")
            .onPreferenceChange(ReviewBounds.self) { bounds = $0 }
            Text("320 pt board · \(configuration.textSize == .large ? "large" : "accessibility2")")
                .font(.caption).accessibilityIdentifier("text-request")
            Text(layoutIsSafe ? "Layout: inside" : "Layout: pending or outside")
                .font(.caption).accessibilityIdentifier("layout-safety")
                .accessibilityValue(Text(verbatim: geometryDescription))
            Text("Rendered progress size").font(.caption)
                .accessibilityIdentifier("long-footprint")
                .accessibilityValue(Text(verbatim: "\(bounds["outer"]?.width ?? 0)|\(bounds["outer"]?.height ?? 0)"))
        }
        .padding(16)
        .frame(width: 320, alignment: .leading)
        .background(theme.surface, in: RoundedRectangle(cornerRadius: 24))
    }

    private var layoutIsSafe: Bool {
        guard let outer = bounds["outer"], let label = bounds["label"], let value = bounds["value"],
              !outer.isEmpty, !label.isEmpty, !value.isEmpty else { return false }
        return outer.insetBy(dx: -0.5, dy: -0.5).contains(label)
            && outer.insetBy(dx: -0.5, dy: -0.5).contains(value)
            && label.maxY <= value.minY + 0.5
    }

    private var geometryDescription: String {
        "outer=\(bounds["outer"] ?? .zero); label=\(bounds["label"] ?? .zero); value=\(bounds["value"] ?? .zero)"
    }

    private func measure(_ id: String) -> some View {
        GeometryReader { proxy in
            Color.clear.preference(key: ReviewBounds.self,
                                   value: [id: proxy.frame(in: .named("progress-measurement"))])
        }
    }

    private func sample(_ label: String, value: Double?, current: String, id: String) -> some View {
        NativeProgressBar(theme: theme, value: value, total: 100) {
            Text(verbatim: label)
        } currentValueLabel: {
            Text(verbatim: current)
        }
        .accessibilityIdentifier(id)
    }
}

private struct ReviewBounds: PreferenceKey {
    static let defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { old, new in
            old.width * old.height > new.width * new.height ? old : new
        }
    }
}
