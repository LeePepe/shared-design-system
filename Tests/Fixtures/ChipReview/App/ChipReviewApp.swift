@testable import Strata
import SwiftUI

@main
struct ChipReviewApp: App {
    private let configuration = Result { try Configuration() }

    var body: some Scene {
        WindowGroup {
            switch configuration {
            case .success(let configuration):
                ChipBoard(configuration: configuration)
                    .preferredColorScheme(configuration.mode == "dark" ? .dark : .light)
            case .failure(let error):
                Text("Fixture configuration failed: \(String(describing: error))")
                    .accessibilityIdentifier("fixture-error").padding()
            }
        }
    }
}

private struct Configuration {
    enum Invalid: Error { case input(String) }
    let theme: StrataTheme
    let brand: String
    let mode: String
    let scenario: String
    let size: DynamicTypeSize

    init() throws {
        let environment = ProcessInfo.processInfo.environment
        func required(_ key: String) throws -> String {
            guard let value = environment[key], !value.isEmpty else { throw Invalid.input(key) }
            return value
        }
        brand = try required("NDK_BRAND")
        mode = try required("NDK_THEME")
        switch mode {
        case "light": theme = try StrataTheme(theme: .light, brand: brand)
        case "dark": theme = try StrataTheme(theme: .dark, brand: brand)
        default: throw Invalid.input("NDK_THEME")
        }
        scenario = try required("NDK_SCENARIO")
        guard ["matrix", "interaction", "long-label"].contains(scenario) else {
            throw Invalid.input("NDK_SCENARIO")
        }
        switch try required("NDK_TEXT_SIZE") {
        case "large": size = .large
        case "accessibility2": size = .accessibility2
        default: throw Invalid.input("NDK_TEXT_SIZE")
        }
    }
}

private struct ChipBoard: View {
    let configuration: Configuration
    @State private var count = 0
    @State private var isDisabled = false
    @State private var isPresent = true
    @State private var bounds: [String: CGRect] = [:]
    private var theme: StrataTheme { configuration.theme }
    private let longText = "Forschungsnotizen und ausführliche Beschreibungen gemeinsam organisieren"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Strata Chip").font(.title.bold())
                Text("\(configuration.brand.capitalized) · \(configuration.mode.capitalized) · Synthetic review")
                    .font(.caption).foregroundStyle(theme.secondaryForeground)
                switch configuration.scenario {
                case "matrix": matrix
                case "long-label": longLabel
                default: interaction
                }
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
        VStack(alignment: .leading, spacing: 14) {
            ForEach(["neutral", "accent", "critical"], id: \.self) { name in
                VStack(alignment: .leading, spacing: 6) {
                    Text(name.capitalized).font(.headline)
                    StrataChip(theme: theme, tone: tone(name)) {
                        Text("\(name.capitalized) static").accessibilityIdentifier("static-\(name)")
                    }
                    StrataChip(theme: theme, tone: tone(name),
                               removalAccessibilityLabel: Text("Remove \(name) item"),
                               onRemove: { count += 1 }) { Text("Removable item") }
                    StrataChip(theme: theme, tone: tone(name),
                               removalAccessibilityLabel: Text("Remove disabled \(name) item"),
                               onRemove: { count += 1 }) { Text("Disabled removal") }
                        .disabled(true)
                }
            }
            Text("Static / Removable / Disabled · No product state")
                .font(.caption).accessibilityIdentifier("matrix-end")
        }
    }

    private var interaction: some View {
        VStack(alignment: .leading, spacing: 16) {
            StrataChip(theme: theme, tone: .neutral) {
                Text("Static content").accessibilityIdentifier("static-content")
            }
            StrataChip(theme: theme, tone: .accent,
                       removalAccessibilityLabel: Text("Remove research note"), onRemove: { count += 1 }) {
                Text("Research note").accessibilityIdentifier("action-label")
            }
            .disabled(isDisabled)
            .background(measure("action"))
            Text("Removals: \(count)").accessibilityIdentifier("action-count")
            Text("Geometry").accessibilityIdentifier("action-geometry")
                .accessibilityValue(rectangle("action"))
            Button(isDisabled ? "Enable removal" : "Disable removal") { isDisabled.toggle() }
                .accessibilityIdentifier("toggle-disabled").buttonStyle(.bordered)
            if isPresent {
                StrataChip(theme: theme, tone: .critical,
                           removalAccessibilityLabel: Text("Remove temporary note"), onRemove: { isPresent = false }) {
                    Text("Temporary note").accessibilityIdentifier("owned-label")
                }
            }
            Text(isPresent ? "Caller retains item" : "Caller removed item")
                .accessibilityIdentifier("caller-state")
        }
        .coordinateSpace(name: "chip-board")
        .onPreferenceChange(ReviewBounds.self) { bounds = $0 }
    }

    private var longLabel: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("320 pt narrow layout").font(.headline)
            VStack(alignment: .leading, spacing: 16) {
                StrataChip(theme: theme, tone: .neutral) {
                    Text(longText).accessibilityIdentifier("long-static-label")
                        .background(measure("static-label"))
                }
                .background(measure("static"))
                StrataChip(theme: theme, tone: .critical,
                           removalAccessibilityLabel: Text("Forschungsnotiz entfernen"), onRemove: { count += 1 }) {
                    Text(longText).accessibilityIdentifier("long-removable-label")
                        .background(measure("removable-label"))
                }
                .background(measure("removable"))
            }
            .environment(\.dynamicTypeSize, configuration.size)
            Text("Static shape: \(safety("static"))")
                .accessibilityIdentifier("static-safety")
                .accessibilityValue("\(rectangle("static")); capsule=\(safety("static", capsule: true))")
            Text("Removable shape: \(safety("removable"))")
                .accessibilityIdentifier("removable-safety")
                .accessibilityValue("\(rectangle("removable")); capsule=\(safety("removable", capsule: true))")
            Text("Removals: \(count)").accessibilityIdentifier("action-count")
            Text("Deutsch · \(configuration.size == .accessibility2 ? "accessibility2" : "large")")
                .font(.caption).accessibilityIdentifier("long-end")
        }
        .padding(16)
        .frame(width: 320, alignment: .leading)
        .coordinateSpace(name: "chip-board")
        .onPreferenceChange(ReviewBounds.self) { bounds = $0 }
    }

    private func measure(_ name: String) -> some View {
        GeometryReader { proxy in
            Color.clear.preference(key: ReviewBounds.self,
                                   value: [name: proxy.frame(in: .named("chip-board"))])
        }
    }

    private func rectangle(_ name: String) -> String {
        let rect = bounds[name] ?? .zero
        return "\(rect.minX),\(rect.minY),\(rect.width),\(rect.height)"
    }

    private func safety(_ name: String, capsule: Bool = false) -> String {
        guard let rect = bounds[name], let label = bounds[name + "-label"],
              !rect.isEmpty, !label.isEmpty else { return "pending" }
        let path = capsule ? Capsule().path(in: rect) : StrataChipShape().path(in: rect)
        let corners = [CGPoint(x: label.minX, y: label.minY), CGPoint(x: label.maxX, y: label.minY),
                       CGPoint(x: label.minX, y: label.maxY), CGPoint(x: label.maxX, y: label.maxY)]
        return corners.allSatisfy { path.contains($0) } ? "inside" : "outside"
    }

    private func tone(_ name: String) -> StrataChipTone {
        switch name {
        case "accent": .accent
        case "critical": .critical
        default: .neutral
        }
    }
}

private struct ReviewBounds: PreferenceKey {
    static let defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, next in next })
    }
}
