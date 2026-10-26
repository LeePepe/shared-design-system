import Strata
import SwiftUI

/// Synthetic caller-owned state for real SwiftUI/XCTest review only.
@main
struct TextFieldReviewApp: App {
    private let configuration = Result { try ReviewConfiguration() }

    var body: some Scene {
        WindowGroup {
            switch configuration {
            case .success(let configuration):
                TextFieldReviewBoard(configuration: configuration)
                    .preferredColorScheme(configuration.mode == "dark" ? .dark : .light)
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
    let theme: StrataTheme
    let brand: String
    let mode: String
    let scenario: String
    let textSize: DynamicTypeSize

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
        case "light": theme = try StrataTheme(theme: .light, brand: brand)
        case "dark": theme = try StrataTheme(theme: .dark, brand: brand)
        default: throw ConfigurationError.invalid("NDK_THEME")
        }
        switch try required("NDK_TEXT_SIZE") {
        case "large": textSize = .large
        case "accessibility2": textSize = .accessibility2
        default: throw ConfigurationError.invalid("NDK_TEXT_SIZE")
        }
    }
}

private struct TextFieldReviewBoard: View {
    let configuration: ReviewConfiguration
    @State private var name = "Initial value"
    @State private var empty = ""
    @State private var unavailable = "Unavailable"
    @State private var contact = "example"
    @State private var note = "Notiz"
    @State private var edits = 0
    @State private var submissions = 0
    @State private var bounds: [String: CGRect] = [:]
    private var theme: StrataTheme { configuration.theme }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Strata TextField").font(.title.bold())
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
        .onPreferenceChange(ReviewBounds.self) { bounds = $0 }
    }

    private var matrix: some View {
        VStack(alignment: .leading, spacing: 24) {
            StrataTextField(theme: theme, text: $name) { Text("Display name") }
                .accessibilityIdentifier("matrix-populated")
            StrataTextField(theme: theme, text: $empty, prompt: Text("Enter a short note")) {
                Text("A longer label that can wrap at narrow widths")
            }
            .accessibilityIdentifier("matrix-empty")
            StrataTextField(theme: theme, text: $unavailable,
                            accessibilityLabel: Text("Unavailable field")) {
                Label("Unavailable field", systemImage: "lock")
            }
            .disabled(true)
            .accessibilityIdentifier("matrix-disabled")
            VStack(alignment: .leading, spacing: 8) {
                StrataTextField(theme: theme, text: $contact, prompt: Text("name@example.com")) {
                    Text("Email address")
                }
                .accessibilityIdentifier("matrix-validation")
                Label("Enter a complete email address.", systemImage: "exclamationmark.circle.fill")
                    .font(.footnote).foregroundStyle(theme.critical)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("caller-validation")
            }
            Text("Synthetic caller data · Validation belongs to the caller")
                .font(.caption).foregroundStyle(theme.secondaryForeground)
                .accessibilityIdentifier("matrix-end")
        }
    }

    private var interaction: some View {
        VStack(alignment: .leading, spacing: 16) {
            StrataTextField(theme: theme, text: $name, prompt: Text("Enter a value"),
                            accessibilityLabel: Text("Display name")) {
                Text("Display name")
                    .recordBounds("active-label", color: theme.surface)
            }
            .accessibilityIdentifier("active-input")
            .recordBounds("active-component", color: theme.surface)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .submitLabel(.done)
            .onChange(of: name) { _ in edits += 1 }
            .onSubmit { submissions += 1 }
            Text(name).accessibilityIdentifier("caller-value")
            Text("Edits: \(edits)").accessibilityIdentifier("edit-count")
            Text("Submissions: \(submissions)").accessibilityIdentifier("submit-count")
            StrataTextField(theme: theme, text: $unavailable,
                            accessibilityLabel: Text("Unavailable field")) {
                Text("Unavailable field")
                    .recordBounds("disabled-label", color: theme.surface)
            }
            .disabled(true)
            .accessibilityIdentifier("disabled-input")
            .recordBounds("disabled-component", color: theme.surface)
            Text(unavailable).accessibilityIdentifier("disabled-value")
            geometryReadout("active")
            geometryReadout("disabled")
        }
    }

    private var longLabel: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 16) {
                StrataTextField(theme: theme, text: $note,
                                accessibilityLabel: Text("Vollständiger Anzeigename für die gemeinsame Zusammenarbeit")) {
                    Text("Vollständiger Anzeigename für die gemeinsame Zusammenarbeit")
                        .recordBounds("long-label", color: theme.surface)
                }
                .accessibilityIdentifier("long-input")
                .recordBounds("long-component", color: theme.surface)
                .environment(\.dynamicTypeSize, configuration.textSize)
                Text("320 pt · Deutsch · \(configuration.textSize == .accessibility2 ? "accessibility2" : "large")")
                    .font(.caption).foregroundStyle(theme.secondaryForeground)
                    .accessibilityIdentifier("long-end")
            }
            .padding(16)
            .frame(width: 320, alignment: .leading)
            .recordBounds("long-board", color: theme.surface)
            geometryReadout("long")
        }
    }

    private func geometryReadout(_ prefix: String) -> some View {
        Text("\(prefix.capitalized) layout measured")
            .font(.caption)
            .accessibilityIdentifier("\(prefix)-geometry")
            .accessibilityValue(Text(verbatim: geometryDescription(prefix)))
    }

    private func geometryDescription(_ prefix: String) -> String {
        guard let label = bounds["\(prefix)-label"],
              let component = bounds["\(prefix)-component"],
              !label.isEmpty, !component.isEmpty else { return "pending" }
        // The visible label and the component's entire extent are measured in
        // SwiftUI. Their gap is the production 8 pt; the remaining rect is the
        // visible padded input surface. UI tests tap that rect, not editor bounds.
        let surface = CGRect(x: component.minX, y: label.maxY + 8,
                             width: component.width, height: component.maxY - label.maxY - 8)
        return [label, surface, component, bounds["long-board"] ?? component]
            .map { "\($0.minX),\($0.minY),\($0.width),\($0.height)" }
            .joined(separator: "|")
    }
}

private extension View {
    func recordBounds(_ id: String, color: Color) -> some View {
        background {
            GeometryReader { proxy in
                color.opacity(0).preference(key: ReviewBounds.self,
                                            value: [id: proxy.frame(in: .global)])
            }
        }
    }
}

private struct ReviewBounds: PreferenceKey {
    static let defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue().filter { !$0.value.isEmpty }, uniquingKeysWith: { _, next in next })
    }
}
