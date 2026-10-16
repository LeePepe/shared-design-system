import NativeDesignKit
import SwiftUI

/// Synthetic test-only state. Theme/configuration errors remain visible.
@main
struct SliderReviewApp: App {
    private let configuration = Result { try ReviewConfiguration() }

    var body: some Scene {
        WindowGroup {
            switch configuration {
            case .success(let configuration):
                SliderReviewBoard(configuration: configuration)
                    .preferredColorScheme(configuration.mode == "dark" ? .dark : .light)
            case .failure(let error):
                Text(String(describing: error)).padding()
                    .accessibilityIdentifier("fixture-error")
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

    init() throws {
        let environment = ProcessInfo.processInfo.environment
        func required(_ key: String) throws -> String {
            guard let value = environment[key], !value.isEmpty else { throw ConfigurationError.missing(key) }
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
    }
}

private struct SliderReviewBoard: View {
    let configuration: ReviewConfiguration
    @State private var minimum = 0.0
    @State private var midpoint = 50.0
    @State private var maximum = 100.0
    @State private var disabledValue = 50.0
    @State private var amount = 0.0
    @State private var isDisabled = false
    @State private var isEditing = false
    @State private var editingStarts = 0
    @State private var editingEnds = 0
    @State private var bounds: [String: CGRect] = [:]
    private var theme: NativeDesignTheme { configuration.theme }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Native Slider").font(.title.bold())
                Text("\(configuration.brand.capitalized) · \(configuration.mode.capitalized) · iOS SwiftUI")
                    .font(.subheadline).foregroundStyle(theme.secondaryForeground)
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
        VStack(alignment: .leading, spacing: 20) {
            control("matrix-minimum", title: "Minimum · 0 units", value: $minimum)
            control("matrix-midpoint", title: "Midpoint · 50 units", value: $midpoint)
            control("matrix-maximum", title: "Maximum · 100 units", value: $maximum)
            control("matrix-disabled", title: "Disabled · 50 units", value: $disabledValue)
                .disabled(true)
            Text("Synthetic review values · 0…100 · step 5")
                .font(.caption).accessibilityIdentifier("matrix-end")
        }
    }

    private var interaction: some View {
        VStack(alignment: .leading, spacing: 16) {
            ReviewSlider(theme: theme, id: "adjustable", title: "Synthetic amount", value: $amount,
                         range: -50...50, minimum: "−50 units", maximum: "50 units", onEditingChanged: editingChanged)
                .disabled(isDisabled)
            Text(verbatim: "Value: \(amount) units").accessibilityIdentifier("bound-value")
            Text("Starts: \(editingStarts); ends: \(editingEnds); editing: \(isEditing)")
                .font(.caption).accessibilityIdentifier("editing-events")
            Button(isDisabled ? "Enable slider" : "Disable slider") { isDisabled.toggle() }
                .accessibilityIdentifier("toggle-disabled")
            HStack {
                Button("Minimum") { amount = -50 }.accessibilityIdentifier("set-minimum")
                Button("Midpoint") { amount = 0 }.accessibilityIdentifier("set-midpoint")
                Button("Maximum") { amount = 50 }.accessibilityIdentifier("set-maximum")
            }
            .buttonStyle(.bordered)
        }
    }

    private var longLabel: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("320 pt · Deutsch · \(configuration.textSize == .accessibility2 ? "accessibility2" : "large")")
                .font(.caption)
            ReviewSlider(theme: theme, id: "long", title: "Lautstärke für alle verbundenen Geräte gemeinsam einstellen",
                         value: $midpoint, range: 0...100, minimum: "Leise Wiedergabe", maximum: "Laute Wiedergabe",
                         onEditingChanged: editingChanged)
                .dynamicTypeSize(configuration.textSize)
            Text("Measured layout").font(.caption)
                .accessibilityIdentifier("layout-metrics")
                .accessibilityValue(Text(verbatim: metricDescription))
            Text("Synthetic review value · 50 units").font(.caption)
                .accessibilityIdentifier("long-end")
        }
        .padding(16)
        .frame(width: 320, alignment: .leading)
        .coordinateSpace(name: "long-board")
        .onPreferenceChange(ReviewBounds.self) { bounds = $0 }
    }

    private var metricDescription: String {
        let component = bounds["long-component", default: .zero]
        let title = bounds["long-title", default: .zero]
        return "height=\(component.height);width=\(component.width);titleHeight=\(title.height);" +
            "titleInside=\(!title.isEmpty && component.insetBy(dx: -0.001, dy: -0.001).contains(title))"
    }

    private func control(_ id: String, title: String, value: Binding<Double>) -> some View {
        ReviewSlider(theme: theme, id: id, title: title, value: value,
                     range: 0...100, minimum: "0 units", maximum: "100 units", onEditingChanged: { _ in })
    }

    private func editingChanged(_ editing: Bool) {
        isEditing = editing
        if editing { editingStarts += 1 } else { editingEnds += 1 }
    }
}

private struct ReviewSlider: View {
    let theme: NativeDesignTheme
    let id: String
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let minimum: String
    let maximum: String
    let onEditingChanged: (Bool) -> Void

    var body: some View {
        switch Result(catching: {
            try NativeSlider(theme: theme, value: $value, in: range, step: 5,
                             onEditingChanged: onEditingChanged) {
                Text(verbatim: title).background { measure("\(id)-title") }
            } minimumValueLabel: {
                Text(verbatim: minimum).accessibilityIdentifier("\(id)-minimum")
            } maximumValueLabel: {
                Text(verbatim: maximum).accessibilityIdentifier("\(id)-maximum")
            }
        }) {
        case .success(let slider):
            slider
                .accessibilityIdentifier(id)
                .background { measure("\(id)-component") }
        case .failure(let error):
            Text(String(describing: error)).accessibilityIdentifier("fixture-error")
        }
    }

    private func measure(_ name: String) -> some View {
        GeometryReader { proxy in
            Color.clear.preference(key: ReviewBounds.self, value: [name: proxy.frame(in: .named("long-board"))])
        }
    }
}

private struct ReviewBounds: PreferenceKey {
    static let defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { current, next in
            current.width * current.height > next.width * next.height ? current : next
        }
    }
}
