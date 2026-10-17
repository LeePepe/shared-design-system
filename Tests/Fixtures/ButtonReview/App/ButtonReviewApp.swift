@testable import NativeDesignKit
import SwiftUI

/// Synthetic review fixture only. Theme resolution failures are shown, never replaced.
@main
struct ButtonReviewApp: App {
    private let configuration = Result { try ReviewConfiguration() }

    var body: some Scene {
        WindowGroup {
            if ProcessInfo.processInfo.arguments.contains("--button-flat-control-isolation") {
                ButtonFlatControlIsolation()
            } else {
                switch configuration {
                case .success(let configuration):
                    ButtonReviewBoard(configuration: configuration)
                        .preferredColorScheme(configuration.isDark ? .dark : .light)
                        .environment(\.locale, Locale(identifier: configuration.language))
                        .environment(\.nativeReduceTransparencyOverride, configuration.forceReduced ? true : nil)
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
}

private struct ReviewConfiguration {
    enum ConfigurationError: Error { case missing(String), invalid(String) }
    let theme: NativeDesignTheme
    let brand: String
    let mode: String
    let scenario: String
    let surface: NativeSurfaceStyle
    let buttonInitializer: String
    let requestedSurface: String
    let textSize: DynamicTypeSize
    let language: String
    let forceReduced: Bool
    var isDark: Bool { mode == "dark" }

    init() throws {
        let environment = ProcessInfo.processInfo.environment
        guard [nil, "true", "false"].contains(environment["NDK_FORCE_REDUCED"]) else {
            throw ConfigurationError.invalid("NDK_FORCE_REDUCED")
        }
        forceReduced = environment["NDK_FORCE_REDUCED"] == "true"
        buttonInitializer = environment["NDK_BUTTON_INITIALIZER"] ?? "explicit-surface"
        guard ["explicit-surface", "original-solid"].contains(buttonInitializer) else {
            throw ConfigurationError.invalid("NDK_BUTTON_INITIALIZER")
        }
        func required(_ name: String) throws -> String {
            guard let value = environment[name], !value.isEmpty else {
                throw ConfigurationError.missing(name)
            }
            return value
        }
        brand = try required("NDK_BRAND")
        mode = try required("NDK_THEME")
        scenario = try required("NDK_SCENARIO")
        guard ["specimen", "matrix", "interaction", "long-label", "input-diagnostics"].contains(scenario) else {
            throw ConfigurationError.invalid("NDK_SCENARIO")
        }
        requestedSurface = try required("NDK_SURFACE")
        switch requestedSurface {
        case "glass": surface = .glass
        case "solid": surface = .solid
        default: throw ConfigurationError.invalid("NDK_SURFACE")
        }
        guard buttonInitializer != "original-solid" || ["matrix", "interaction", "long-label"].contains(scenario) else {
            throw ConfigurationError.invalid("NDK_BUTTON_INITIALIZER scenario")
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
        language = try required("NDK_LANGUAGE")
        guard ["en", "de"].contains(language) else {
            throw ConfigurationError.invalid("NDK_LANGUAGE")
        }
    }
}

private struct ButtonReviewBoard: View {
    let configuration: ReviewConfiguration
    @State private var actionCount = 0
    @State private var isLoading = false
    @State private var isDisabled = false
    @State private var buttonBounds: CGRect = .zero
    @State private var idleLabelBounds: CGRect = .zero
    @State private var loadingLabelBounds: CGRect = .zero
    @State private var specimenTextBounds: [String: CGRect] = [:]
    @State private var pointerTarget = "none"
    @State private var pointerEntries = 0
    @State private var pointerVisits: Set<String> = []
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.nativeReduceTransparencyOverride) private var reduceTransparencyOverride
    private var theme: NativeDesignTheme { configuration.theme }

    var body: some View {
        Group {
            if configuration.scenario == "specimen" {
                specimen.accessibilityIdentifier("review-scroll")
                    .accessibilityValue("reduce-transparency=\(reduceTransparency);pointer=\(pointerTarget);entries=\(pointerEntries);visited=\(pointerVisits.sorted().joined(separator: ","));forced-reduced=\(reduceTransparencyOverride == true)")
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        switch configuration.scenario {
                        case "matrix": matrix
                        case "long-label": longLabel
                        case "input-diagnostics": ButtonInputDiagnostics(theme: theme)
                        default: interaction
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .accessibilityIdentifier("review-scroll")
                .accessibilityValue("initializer=\(configuration.buttonInitializer);requested-surface=\(configuration.requestedSurface);reduce-transparency=\(reduceTransparency)")
                .foregroundStyle(theme.foreground)
                .background(theme.canvas.ignoresSafeArea())
            }
        }
        .dynamicTypeSize(.large)
        .onPreferenceChange(SpecimenTextBounds.self) { specimenTextBounds = $0 }
    }

    private var specimen: some View {
        StrataSpecimen(theme: theme, surface: configuration.surface, title: "01  Button") {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        specimenButton(.primary, id: "specimen-save") {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark").accessibilityHidden(true)
                                specimenLabel("Save", id: "specimen-save")
                            }
                        }
                        specimenButton(.secondary, id: "specimen-secondary") {
                            specimenLabel("Secondary", id: "specimen-secondary")
                        }
                        specimenButton(.ghost, id: "specimen-ghost") {
                            HStack(spacing: 6) {
                                specimenLabel("Ghost", id: "specimen-ghost")
                                Image(systemName: "arrow.right").accessibilityHidden(true)
                            }
                        }
                    }
                    HStack(spacing: 8) {
                        Text("States").font(.caption).foregroundStyle(theme.secondaryForeground)
                            .accessibilityIdentifier("specimen-state-label")
                        NativeButton(theme: theme, variant: .secondary, surface: configuration.surface,
                                     isLoading: false, action: { actionCount += 1 }) {
                            specimenLabel("Disabled", id: "specimen-disabled")
                        } loadingLabel: { Text("Working…") }
                        .disabled(true)
                        .accessibilityIdentifier("specimen-disabled")
                        .accessibilityValue(textRectangle(for: "specimen-disabled"))
                        NativeButton(theme: theme, variant: .primary, surface: configuration.surface,
                                     isLoading: true, action: { actionCount += 1 }) {
                            Text("Load")
                        } loadingLabel: { specimenLabel("Loading", id: "specimen-loading") }
                        .accessibilityIdentifier("specimen-loading")
                        .accessibilityValue(textRectangle(for: "specimen-loading"))
                    }
                    Text("44 pt targets · Adaptive capsules")
                        .font(.caption).foregroundStyle(theme.secondaryForeground)
                        .accessibilityIdentifier("specimen-caption")
                        .onHover { if $0 { pointerVisits.insert("specimen-caption") } }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .nativeSurface(theme: theme, style: configuration.surface, cornerRadius: 24, role: .card)
                Text(actionCount == 0 ? "Tap Save to try a native action." : "Example saved · \(actionCount)")
                    .font(.subheadline).foregroundStyle(theme.secondaryForeground)
                    .accessibilityIdentifier("specimen-feedback")
            }
        }
    }

    private func specimenButton<Content: View>(_ variant: NativeButtonVariant, id: String,
                                               @ViewBuilder content: () -> Content) -> some View {
        NativeButton(theme: theme, variant: variant, surface: configuration.surface,
                     isLoading: false, action: { actionCount += 1 }, label: content) {
            Text("Wait")
        }
        .fixedSize(horizontal: true, vertical: false)
        .accessibilityIdentifier(id)
        .accessibilityValue(textRectangle(for: id))
        .onHover {
            pointerTarget = $0 ? id : "none"
            if $0 {
                pointerEntries += 1
                pointerVisits.insert(id)
            }
        }
    }

    private func specimenLabel(_ text: String, id: String) -> some View {
        Text(text).background {
            GeometryReader { proxy in
                Color.clear.preference(key: SpecimenTextBounds.self, value: [id: proxy.frame(in: .global)])
            }
        }
    }

    private func textRectangle(for id: String) -> String {
        let rect = specimenTextBounds[id] ?? .zero
        return [rect.minX, rect.minY, rect.width, rect.height].map { String(Double($0)) }.joined(separator: ",")
    }

    /// Keep both public call sites real: the original branch deliberately omits
    /// `surface`, even when the fixture requests Glass for the other branch.
    @ViewBuilder
    private func behaviorButton<Label: View, LoadingLabel: View>(
        variant: NativeButtonVariant,
        isLoading: Bool,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label,
        @ViewBuilder loadingLabel: () -> LoadingLabel
    ) -> some View {
        if configuration.buttonInitializer == "original-solid" {
            NativeButton(theme: theme, variant: variant, isLoading: isLoading,
                         action: action, label: label, loadingLabel: loadingLabel)
        } else {
            NativeButton(theme: theme, variant: variant, surface: configuration.surface,
                         isLoading: isLoading, action: action, label: label, loadingLabel: loadingLabel)
        }
    }

    private var matrix: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(["primary", "secondary", "ghost"], id: \.self) { variant in
                VStack(alignment: .leading, spacing: 6) {
                    Text(variant.capitalized).font(.headline)
                    ForEach(["normal", "loading", "disabled"], id: \.self) { state in
                        HStack(spacing: 12) {
                            Text(state.capitalized).font(.caption)
                                .frame(width: 60, alignment: .leading)
                            behaviorButton(variant: variantValue(variant), isLoading: state == "loading",
                                           action: { actionCount += 1 }) {
                                Text(variant == "primary" ? "Continue" : variant == "secondary" ? "Save draft" : "Learn more")
                            } loadingLabel: { Text("Working…") }
                            .disabled(state == "disabled")
                            .accessibilityIdentifier("matrix-\(variant)-\(state)")
                        }
                    }
                }
            }
            Text("Synthetic review data · Normal / Loading / Disabled")
                .font(.caption).foregroundStyle(theme.secondaryForeground)
                .accessibilityIdentifier("matrix-end")
        }
    }

    private var interaction: some View {
        VStack(alignment: .leading, spacing: 20) {
            behaviorButton(variant: .primary, isLoading: isLoading, action: { actionCount += 1 }) {
                Text("Save")
            } loadingLabel: { Text("Saving all your changes…") }
            .disabled(isDisabled)
            .accessibilityIdentifier("action-target")
            .keyboardShortcut("s", modifiers: .command)
            Text("Actions: \(actionCount)").accessibilityIdentifier("action-count")
            fixtureControls
        }
    }

    private var longLabel: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                Text("320 pt narrow layout").font(.headline)
                behaviorButton(variant: .primary, isLoading: isLoading, action: { actionCount += 1 }) {
                    Text("confirm_selection")
                        .background {
                            GeometryReader { proxy in
                                Color.clear.preference(key: IdleLabelBounds.self,
                                                       value: proxy.frame(in: .named("long-board")))
                            }
                        }
                } loadingLabel: {
                    Text("saving_selection")
                        .background {
                            GeometryReader { proxy in
                                Color.clear.preference(key: LoadingLabelBounds.self,
                                                       value: proxy.frame(in: .named("long-board")))
                            }
                        }
                }
                .environment(\.dynamicTypeSize, configuration.textSize)
                .accessibilityIdentifier("long-target")
                .background {
                    GeometryReader { proxy in
                        Color.clear.preference(key: ButtonBounds.self,
                                               value: proxy.frame(in: .named("long-board")))
                    }
                }
                Text("Deutsch · \(configuration.textSize == .accessibility2 ? "accessibility2" : "large")")
                    .font(.caption).foregroundStyle(theme.secondaryForeground)
                Text("Text bounds: \(labelShapeSafety)").font(.caption)
                    .accessibilityIdentifier("shape-safety")
                    .accessibilityValue(Text(verbatim: shapeGeometryDescription))
            }
            .padding(24)
            .frame(width: 320, alignment: .leading)
            .coordinateSpace(name: "long-board")
            .onPreferenceChange(ButtonBounds.self) { buttonBounds = $0 }
            .onPreferenceChange(IdleLabelBounds.self) { idleLabelBounds = $0 }
            .onPreferenceChange(LoadingLabelBounds.self) { loadingLabelBounds = $0 }
            fixtureControls
        }
    }

    private var labelShapeSafety: String {
        labelSafety(in: NativeButtonShape().path(in: buttonBounds))
    }

    private var shapeGeometryDescription: String {
        "button=\(buttonBounds); label=\(isLoading ? loadingLabelBounds : idleLabelBounds); " +
        "capsule-control=\(labelSafety(in: Capsule().path(in: buttonBounds)))"
    }

    private func labelSafety(in path: Path) -> String {
        let label = isLoading ? loadingLabelBounds : idleLabelBounds
        guard !label.isEmpty, !buttonBounds.isEmpty else { return "pending" }
        let corners = [CGPoint(x: label.minX, y: label.minY), CGPoint(x: label.maxX, y: label.minY),
                       CGPoint(x: label.minX, y: label.maxY), CGPoint(x: label.maxX, y: label.maxY)]
        return corners.allSatisfy { path.contains($0) } ? "inside" : "outside"
    }

    private var fixtureControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(isLoading ? "Loading" : "Idle").accessibilityIdentifier("loading-state")
            Text(reduceMotion ? "Motion: reduced" : "Motion: standard")
                .accessibilityIdentifier("motion-preference")
            Button(isLoading ? "Stop loading" : "Start loading") { isLoading.toggle() }
                .accessibilityIdentifier("toggle-loading")
            Button(isDisabled ? "Enable action" : "Disable action") { isDisabled.toggle() }
                .accessibilityIdentifier("toggle-disabled")
        }
        .buttonStyle(.bordered)
    }

    private func variantValue(_ name: String) -> NativeButtonVariant {
        switch name {
        case "primary": .primary
        case "secondary": .secondary
        default: .ghost
        }
    }
}

/// Standard SwiftUI controls isolate event delivery from the library's styling.
/// This board requests view focus only; it never changes a system preference.
private struct ButtonInputDiagnostics: View {
    let theme: NativeDesignTheme
    @State private var visits: Set<String> = []
    @State private var currentHover = "none"
    @State private var input = ""
    @State private var standardActions = 0
    @State private var nativeActions = 0
    @State private var keys = ""
    @State private var focusRequests = "none"
    @FocusState private var focus: Target?
    private enum Target: String { case standard, native, field, probe }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Pointer sentinel").padding(20)
                .onHover { record("sentinel", inside: $0) }
                .accessibilityIdentifier("input-sentinel")
            Button("Standard action") { standardActions += 1 }
                .buttonStyle(.bordered)
                .focused($focus, equals: .standard)
                .onHover { record("standard", inside: $0) }
                .accessibilityIdentifier("input-standard")
            NativeButton(theme: theme, variant: .primary, surface: .glass, isLoading: false,
                         action: { nativeActions += 1 }) { Text("Native action") } loadingLabel: { Text("Working…") }
                .focused($focus, equals: .native)
                .onHover { record("native", inside: $0) }
                .accessibilityIdentifier("input-native")
            TextField("Keyboard event probe", text: $input)
                .textFieldStyle(.roundedBorder)
                .focused($focus, equals: .field)
                .accessibilityIdentifier("input-field")
            if #available(iOS 17.0, macOS 14.0, *) {
                Text("Focusable key probe").padding(20)
                    .focusable(interactions: .edit)
                    .focused($focus, equals: .probe)
                    .onKeyPress { press in
                        keys += "[\(press.characters)]"
                        return .ignored
                    }
                    .accessibilityIdentifier("input-key-probe")
                Button("Focus key probe") { request(.probe) }
                    .accessibilityIdentifier("input-focus-probe")
            }
            Button("Focus standard action") { request(.standard) }
                .accessibilityIdentifier("input-focus-standard")
            Button("Focus native action") { request(.native) }
                .accessibilityIdentifier("input-focus-native")
            Text("hover=\(currentHover);visited=\(visits.sorted().joined(separator: ","));focus=\(focus?.rawValue ?? "none");requested=\(focusRequests);standard=\(standardActions);native=\(nativeActions);keys=\(keys)")
                .accessibilityIdentifier("input-observation")
        }
    }

    private func record(_ target: String, inside: Bool) {
        currentHover = inside ? target : "none"
        if inside { visits.insert(target) }
    }

    private func request(_ target: Target) {
        focusRequests = target.rawValue
        focus = target
    }
}

private struct ButtonBounds: PreferenceKey {
    static let defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        let next = nextValue()
        if !next.isEmpty { value = next }
    }
}

private struct SpecimenTextBounds: PreferenceKey {
    static let defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, latest in latest })
    }
}

private struct IdleLabelBounds: PreferenceKey {
    static let defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        let next = nextValue()
        if !next.isEmpty { value = next }
    }
}

private struct LoadingLabelBounds: PreferenceKey {
    static let defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        let next = nextValue()
        if !next.isEmpty { value = next }
    }
}
