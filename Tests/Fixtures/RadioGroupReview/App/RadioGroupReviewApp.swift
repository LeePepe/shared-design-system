import NativeDesignKit
import SwiftUI

/// Synthetic component evidence; no product data, persistence or integration.
@main
struct RadioGroupReviewApp: App {
    private let configuration = Result { try ReviewConfiguration() }

    var body: some Scene {
        WindowGroup {
            switch configuration {
            case .success(let configuration):
                ReviewBoard(configuration: configuration)
                    .preferredColorScheme(configuration.mode == "dark" ? .dark : .light)
            case .failure(let error):
                VStack(alignment: .leading, spacing: 16) {
                    Text("Fixture configuration failed").font(.title)
                    Text(String(describing: error)).accessibilityIdentifier("fixture-error")
                }.padding()
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
    let size: DynamicTypeSize

    init() throws {
        let environment = ProcessInfo.processInfo.environment
        func required(_ name: String) throws -> String {
            guard let value = environment[name], !value.isEmpty else { throw ConfigurationError.missing(name) }
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
        case "large": size = .large
        case "accessibility2": size = .accessibility2
        default: throw ConfigurationError.invalid("NDK_TEXT_SIZE")
        }
    }
}

private struct Choice: Hashable { let id: String }

private struct ReviewBoard: View {
    let configuration: ReviewConfiguration
    @State private var selection = Choice(id: "balanced-id")
    @State private var disabledSelection = Choice(id: "detail-id")
    @State private var disabled = false
    @State private var reversed = false
    @State private var writes = 0

    private var theme: NativeDesignTheme { configuration.theme }
    private var choices: [(id: String, label: String)] {
        let values = [("compact-id", "Compact"), ("balanced-id", "Balanced"), ("detail-id", "Detailed")]
        return reversed ? Array(values.reversed()) : values
    }
    private var trackedSelection: Binding<Choice> {
        Binding(get: { selection }, set: { selection = $0; writes += 1 })
    }

    var body: some View {
        List {
            Group {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Native RadioGroup").font(.title.bold())
                    Text("\(configuration.brand.capitalized) · \(configuration.mode.capitalized) · iOS inline selection")
                        .font(.subheadline).foregroundStyle(theme.secondaryForeground)
                }
                .padding(.vertical, 8)
                if configuration.scenario == "long-label" {
                    longLabel
                } else {
                    selectionGroup
                    Text("Selected: \(selection.id)").accessibilityIdentifier("selection-state")
                    Text("Writes: \(writes)").accessibilityIdentifier("write-count")
                    if configuration.scenario == "matrix" {
                        NativeRadioGroup(theme: theme, selection: $disabledSelection) {
                            Text("Disabled choices")
                        } options: {
                            Text("Summary").accessibilityIdentifier("disabled-summary").tag(Choice(id: "summary-id"))
                            Text("Detailed report").accessibilityIdentifier("disabled-detail").tag(Choice(id: "detail-id"))
                        }
                        .disabled(true)
                    } else {
                        controls
                    }
                }
                Text("Synthetic review choices · Native inline picker")
                    .font(.caption).foregroundStyle(theme.secondaryForeground)
                    .accessibilityIdentifier("review-end")
            }
            .listRowBackground(theme.canvas)
        }
        .listStyle(.plain)
        .frame(width: configuration.scenario == "long-label" ? 320 : nil)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("review-list")
        .foregroundStyle(theme.foreground)
        .background(theme.canvas.ignoresSafeArea())
        .dynamicTypeSize(.large)
    }

    private var selectionGroup: some View {
        NativeRadioGroup(theme: theme, selection: trackedSelection) {
            Text("Review density")
        } options: {
            ForEach(choices, id: \.id) { choice in
                Text(choice.label).accessibilityIdentifier("option-\(choice.id)").tag(Choice(id: choice.id))
            }
        }
        .disabled(disabled)
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button { disabled.toggle() } label: {
                Text("Toggle disabled").frame(minHeight: 44)
            }
                .accessibilityIdentifier("toggle-disabled")
            Button { selection = Choice(id: "compact-id") } label: {
                Text("Select compact externally").frame(minHeight: 44)
            }
                .accessibilityIdentifier("select-external")
            Button { reversed.toggle() } label: {
                Text("Reverse caller order").frame(minHeight: 44)
            }
                .accessibilityIdentifier("reverse-order")
        }
        .buttonStyle(.borderless)
        .tint(theme.accent)
    }

    private var longLabel: some View {
        Group {
            Text("320 pt narrow layout").font(.headline)
            NativeRadioGroup(theme: theme, selection: trackedSelection) {
                Text("Review preference")
            } options: {
                Text("Show the complete description of every synthetic review option")
                    .accessibilityIdentifier("long-first").tag(Choice(id: "compact-id"))
                Text("Keep all detailed review notes visible")
                    .accessibilityIdentifier("long-second").tag(Choice(id: "balanced-id"))
            }
            .environment(\.dynamicTypeSize, configuration.size)
            Text("Selected: \(selection.id)").accessibilityIdentifier("selection-state")
        }
    }
}
