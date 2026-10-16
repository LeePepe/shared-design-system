import DesignTokens
import NativeDesignKit
import SwiftUI

struct FixtureConfiguration {
    let dark: Bool
    let accessible: Bool
    let rtl: Bool
    let narrow: Bool
    let page: String
    let allowsGlass: Bool

    init(dark: Bool, accessible: Bool, rtl: Bool, narrow: Bool, page: String, allowsGlass: Bool) {
        self.dark = dark; self.accessible = accessible; self.rtl = rtl
        self.narrow = narrow; self.page = page; self.allowsGlass = allowsGlass
    }

    init() {
        let environment = ProcessInfo.processInfo.environment
        self.init(dark: environment["FIXTURE_APPEARANCE"] == "dark",
                  accessible: environment["FIXTURE_ACCESSIBILITY"] == "1",
                  rtl: environment["FIXTURE_RTL"] == "1",
                  narrow: environment["FIXTURE_WIDTH"] == "narrow",
                  page: environment["FIXTURE_PAGE"] ?? "Buttons", allowsGlass: true)
    }
}

struct FixtureResources {
    let theme: NativeDesignTheme
    let metrics: NativeControlMetrics
    let reviewMetrics: NativeControlMetrics
    let surface: NativeSurfaceMetrics
    let motion: NativeMotionSpec
    let primary: Color
    let secondary: Color
    let raised: Color
    let canvas: Color
    let accent: Color
    let gap: CGFloat
    let padding: CGFloat
    let grid: CGFloat
    let title: NativeTypography
    let heading: NativeTypography
    let reviewBody: NativeTypography
    let body: NativeTypography
    let caption: NativeTypography
    let number: NativeTypography
    let ring: CGFloat
    let line: CGFloat
    let avatar: CGFloat
    let stagger: Double

    init(config: FixtureConfiguration, bundle: Bundle) throws {
        let provider = try FixtureStyle(bundle: bundle)
        let explicitTheme: Theme = config.dark ? .dark : .light
        theme = try NativeDesignTheme(theme: explicitTheme)
        metrics = try provider.controlMetrics()
        #if os(macOS)
        let target = try provider.number("dimension.control.compact")
        #else
        let target = try provider.number("dimension.hit.minimum")
        #endif
        reviewMetrics = try NativeControlMetrics(padding: provider.number("spacing.sm"),
            spacing: provider.number("spacing.sm"), cornerRadius: provider.number("radius.small"),
            minimumHitSize: target, iconSize: provider.number("dimension.icon.medium"),
            borderWidth: provider.number("border.regular"), disabledOpacity: provider.number("opacity.disabled"))
        surface = try provider.surfaceMetrics()
        motion = try provider.motion()
        primary = try NativeTokenColor.resolve("product.text.primary", theme: explicitTheme)
        secondary = try NativeTokenColor.resolve("product.text.secondary", theme: explicitTheme)
        raised = try NativeTokenColor.resolve("product.surface.raised", theme: explicitTheme)
        canvas = try NativeTokenColor.resolve("product.surface.canvas", theme: explicitTheme)
        accent = try NativeTokenColor.resolve("status.info", theme: explicitTheme)
        gap = try provider.number("spacing.lg")
        padding = try provider.number("spacing.xl")
        grid = try provider.number("dimension.grid.minimum") * 2
        title = try provider.typography("typography.large-title")
        heading = try provider.typography("typography.headline")
        body = try provider.typography("typography.body")
        #if os(macOS)
        reviewBody = try provider.typography("typography.footnote")
        #else
        reviewBody = try provider.typography("typography.body")
        #endif
        caption = try provider.typography("typography.caption")
        number = try provider.typography("typography.number")
        ring = try provider.number("dimension.avatar.large")
        line = try provider.number("border.strong")
        avatar = try provider.number("dimension.avatar.medium")
        stagger = try provider.number("stagger.relaxed")
    }
}


struct FixtureEntry: View {
    let config: FixtureConfiguration
    private let resources: Result<FixtureResources, Error>

    init(config: FixtureConfiguration) {
        self.config = config
        resources = Result { try FixtureResources(config: config, bundle: .main) }
    }

    var body: some View {
        switch resources {
        case let .success(result):
            ReviewOrCatalog(resources: result, config: config)
                .preferredColorScheme(config.dark ? .dark : .light)
                .environment(\.dynamicTypeSize, config.accessible ? .accessibility3 : .large)
                .environment(\.layoutDirection, config.rtl ? .rightToLeft : .leftToRight)
        case let .failure(error):
            Text("Fixture setup failed: \(String(describing: error)). Run prepare.sh with a reviewed provider checkout.")
                .accessibilityIdentifier("fixture-error")
        }
    }
}

private struct FlowItem: Identifiable {
    let id: String
}

struct Catalog: View {
    let r: FixtureResources
    let config: FixtureConfiguration
    @State private var page: String
    @State private var actionCount = 0
    @State private var enabled = true
    @State private var checked = false
    @State private var choice = "First"
    private enum EntryField: Hashable { case name, secure, search }
    @FocusState private var focusedField: EntryField?
    @State private var text = ""
    @State private var secret = ""
    @State private var notes = "A short note that can grow with Dynamic Type."
    @State private var query = ""
    @State private var level = 40.0
    @State private var count = 2
    @State private var numberValue = 128.0
    @State private var date = Date(timeIntervalSince1970: 1_735_732_800)
    @State private var tagVisible = true
    @StateObject private var sequence = NativeMotionSequence()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(resources: FixtureResources, config: FixtureConfiguration) {
        r = resources; self.config = config
        _page = State(initialValue: config.page)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: r.padding) {
                header
                NativePicker(selection: $page, theme: r.theme, metrics: r.metrics,
                             presentation: config.accessible ? .menu : .segmented) {
                    Text("Catalog section")
                } content: {
                    ForEach(["Buttons", "Entry", "Values", "Motion"], id: \.self) { Text($0).tag($0) }
                }.accessibilityIdentifier("catalog-page")
                if page == "Buttons" { buttons }
                if page == "Entry" { entry }
                if page == "Values" { values }
                if page == "Motion" { motion }
                Text("Synthetic data · Explicit theme · Native semantics")
                    .nativeTypography(r.caption).foregroundColor(r.secondary)
            }.padding(r.padding).frame(maxWidth: .infinity, alignment: .leading)
        }.nativeKeyboardDismissal(.immediately).background(r.canvas).foregroundColor(r.primary)
            .nativeTypography(r.body)
            .accessibilityIdentifier("catalog")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: r.gap) {
            HStack(spacing: r.gap) {
                Image(systemName: "square.stack.3d.up.fill").foregroundColor(r.accent)
                Text("NATIVE DESIGN KIT").nativeTypography(r.caption)
                Spacer(minLength: 0)
                Text(config.dark ? "DARK" : "LIGHT").nativeTypography(r.caption).foregroundColor(r.secondary)
            }
            Text("Small pieces.\nNative possibilities.").nativeTypography(r.title).nativeGrowingText()
            Text("A working catalog of controls, surfaces and motion.")
                .foregroundColor(r.secondary).nativeGrowingText()
        }
    }

    private func panel<Content: View>(_ eyebrow: String, _ title: String,
                                      @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: r.gap) {
            Text(eyebrow).nativeTypography(r.caption).foregroundColor(r.secondary)
            Text(title).nativeTypography(r.heading).nativeGrowingText()
            content()
        }.frame(maxWidth: .infinity, alignment: .leading).padding(r.padding)
            .nativeSurface(theme: r.theme, metrics: r.surface, style: .opaque)
    }

    private var buttons: some View {
        NativeAdaptiveGrid(minimumWidth: r.grid, spacing: r.gap) {
            panel("C01 / ACTION", "One action, many expressions") {
                NativeButton(theme: r.theme, metrics: r.metrics, presentation: .prominent,
                             isLoading: false, loadingLabel: Text("Loading"), action: { actionCount += 1 }) {
                    Label("Run action", systemImage: "arrow.right")
                }.accessibilityIdentifier("run-action")
                HStack(spacing: r.gap) {
                    NativeButton(theme: r.theme, metrics: r.metrics, presentation: .bordered,
                                 isLoading: false, loadingLabel: Text("Loading"), action: { actionCount += 1 }) {
                        Text("Text button")
                    }
                    NativeButton(theme: r.theme, metrics: r.metrics, presentation: .plain,
                                 isLoading: false, loadingLabel: Text("Loading"), action: { actionCount += 1 }) {
                        Image(systemName: "heart")
                    }.accessibilityLabel("Favorite").accessibilityIdentifier("icon-action")
                }
                NativeButton(theme: r.theme, metrics: r.metrics, presentation: (config.accessible || !config.allowsGlass) ? .bordered : .glass,
                             isLoading: false, loadingLabel: Text("Loading"), action: { actionCount += 1 }) {
                    Label("Glass action", systemImage: "sparkles")
                }
                NativeButton(theme: r.theme, metrics: r.metrics, presentation: .bordered,
                             isLoading: true, loadingLabel: Text("Loading"), action: { actionCount += 100 }) {
                    Text("Loading action")
                }.accessibilityIdentifier("loading-action")
                NativeButton(theme: r.theme, metrics: r.metrics, presentation: .bordered,
                             isLoading: false, loadingLabel: Text("Loading"), action: { actionCount += 100 }) {
                    Text("Disabled action")
                }.disabled(true).accessibilityIdentifier("disabled-action")
                Text("Actions: \(actionCount)").accessibilityIdentifier("action-count")
            }
            panel("C02 + C04 / SELECTION", "State stays with the caller") {
                NativeToggle(isOn: $enabled, theme: r.theme, metrics: r.metrics) { Text("Enable option") }
                    .accessibilityIdentifier("enable-option")
                NativeCheckbox(isOn: $checked, theme: r.theme, metrics: r.metrics,
                               checkedValue: Text("Checked"), uncheckedValue: Text("Unchecked")) {
                    Text("Include details")
                }.accessibilityIdentifier("include-details")
                Text(checked ? "Details included" : "Details excluded").accessibilityIdentifier("checkbox-state")
                NativePicker(selection: $choice, theme: r.theme, metrics: r.metrics, presentation: .segmented) {
                    Text("Choice")
                } content: {
                    Text("First").tag("First"); Text("Second").tag("Second")
                }.accessibilityIdentifier("choice-picker")
                Text("Selection: \(choice)").accessibilityIdentifier("choice-state")
                NativeRadioGroup(selection: $choice, theme: r.theme, metrics: r.metrics) {
                    Text("Radio options")
                } content: {
                    Text("First option").tag("First"); Text("Second option").tag("Second")
                }
            }
        }
    }

    private var entry: some View {
        NativeAdaptiveGrid(minimumWidth: r.grid, spacing: r.gap) {
            panel("C03 / TEXT ENTRY", "Room for words") {
                NativeTextField("Display name", text: $text, theme: r.theme, metrics: r.metrics)
                    .focused($focusedField, equals: .name).onSubmit { focusedField = nil }
                    .accessibilityIdentifier("display-name")
                Text("Name: \(text)").accessibilityIdentifier("name-state")
                NativeSecureField("Private phrase", text: $secret, theme: r.theme, metrics: r.metrics)
                    .focused($focusedField, equals: .secure).onSubmit { focusedField = nil }
                    .accessibilityIdentifier("private-phrase")
                NativeSearchField("Search catalog", text: $query, theme: r.theme, metrics: r.metrics,
                                  clearLabel: Text("Clear search"))
                    .focused($focusedField, equals: .search).onSubmit { focusedField = nil }
                    .accessibilityIdentifier("search-catalog")
                NativeTextEditor(text: $notes, theme: r.theme, metrics: r.metrics,
                                 accessibilityLabel: Text("Notes")) { Text("Notes") }
                    .frame(minHeight: r.ring * 3)
            }
            panel("C06 / DATE & TIME", "Platform-native precision") {
                NativeDatePicker(selection: $date, in: dateBounds, displayedComponents: .date,
                                 theme: r.theme, metrics: r.metrics) { Text("Date") }
                NativeDatePicker(selection: $date, in: dateBounds, displayedComponents: .hourAndMinute,
                                 theme: r.theme, metrics: r.metrics) { Text("Time") }
                NativeDatePicker(selection: $date, in: dateBounds, displayedComponents: [.date, .hourAndMinute],
                                 theme: r.theme, metrics: r.metrics) { Text("Date and time") }
                Text("Locale, calendar and time zone remain caller-owned.").foregroundColor(r.secondary)
                NativePicker(selection: $choice, theme: r.theme, metrics: r.metrics, presentation: .menu) {
                    Text("Menu choice")
                } content: {
                    Text("First").tag("First"); Text("Second").tag("Second")
                }
            }
        }
    }

    private var dateBounds: ClosedRange<Date> {
        Date(timeIntervalSince1970: 1_704_067_200)...Date(timeIntervalSince1970: 1_767_225_600)
    }

    private var values: some View {
        NativeAdaptiveGrid(minimumWidth: r.grid, spacing: r.gap) {
            panel("C05 + C07 / VALUES", "Make progress visible") {
                Text("Level: \(Int(level))").accessibilityIdentifier("level-state")
                NativeSlider(value: $level, in: 0...100, step: 10, theme: r.theme, metrics: r.metrics,
                             onEditingChanged: { _ in }) { Text("Level") }.accessibilityIdentifier("level-slider")
                NativeStepper(value: $count, in: 0...5, step: 1, theme: r.theme, metrics: r.metrics) {
                    Text("Count: \(count)")
                }.accessibilityIdentifier("count-stepper")
                Text("Count value: \(count)").accessibilityIdentifier("count-state")
                NativeProgress(value: level, total: 100, presentation: .linear, theme: r.theme,
                               diameter: r.ring, lineWidth: r.line,
                               accessibilityValue: Text("\(Int(level)) percent")) { Text("Linear progress") }
                    .accessibilityIdentifier("linear-progress")
                HStack(alignment: .top, spacing: r.padding) {
                    NativeProgress(value: level, total: 100, presentation: .ring, theme: r.theme,
                                   diameter: r.ring, lineWidth: r.line,
                                   accessibilityValue: Text("\(Int(level)) percent")) { Text("Ring") }
                        .accessibilityIdentifier("ring-progress")
                    NativeProgress(value: nil, total: 100, presentation: .indeterminate, theme: r.theme,
                                   diameter: r.ring, lineWidth: r.line,
                                   accessibilityValue: Text("In progress")) { Text("Working") }
                }
            }
            panel("C08 / COMPOSITION", "Clear identity and status") {
                NativeAvatar(theme: r.theme, diameter: r.avatar, accessibilityLabel: Text("Sample avatar, NK")) {
                    // Initials are graphic content in a fixed-size avatar; the full identity is its AX label.
                    Text("NK").font(.system(size: r.metrics.iconSize))
                }
                NativeIconLabel(theme: r.theme, metrics: r.metrics) { Image(systemName: "checkmark.seal") } label: {
                    Text("A generic icon and label")
                }
                NativeFlow(items: NativeControlTone.allCases.enumerated().map { FlowItem(id: String($0.offset)) },
                           horizontalSpacing: r.gap, verticalSpacing: r.gap) { item in
                    NativeBadge(theme: r.theme, metrics: r.metrics,
                                tone: NativeControlTone.allCases[Int(item.id)!]) {
                        Text(["Neutral", "Info", "Warning", "Critical"][Int(item.id)!])
                    }
                }
                if tagVisible {
                    NativeTag(theme: r.theme, metrics: r.metrics, tone: .neutral,
                              removeLabel: Text("Remove sample tag"), onRemove: { tagVisible = false }) {
                        Text("Sample tag")
                    }.accessibilityIdentifier("sample-tag")
                }
                NativeAnimatedNumber(value: numberValue, theme: r.theme, motion: r.motion,
                                     accessibilityLabel: Text("Animated total"), format: { String(Int($0.rounded())) })
                    .nativeTypography(r.number).accessibilityIdentifier("animated-number")
                NativeButton(theme: r.theme, metrics: r.metrics, presentation: .bordered, isLoading: false,
                             loadingLabel: Text("Loading"), action: { numberValue = 256 }) {
                    Text("Animate to 256")
                }.accessibilityIdentifier("animate-number")
            }
        }
    }

    private var motion: some View {
        NativeAdaptiveGrid(minimumWidth: r.grid, spacing: r.gap) {
            panel("FOUNDATIONS / MOTION", "An intentional final state") {
                Text(config.accessible ? "Reduced motion · Opaque surfaces" :
                     (config.allowsGlass ? "Native motion · Glass surface" : "Bitmap rendering · Opaque surfaces"))
                    .foregroundColor(r.secondary).accessibilityIdentifier("accessibility-mode")
                NativeButton(theme: r.theme, metrics: r.metrics, presentation: (config.accessible || !config.allowsGlass) ? .bordered : .glass, isLoading: false,
                             loadingLabel: Text("Loading"), action: {
                    Task { await sequence.replay(schedule: NativeStaggerSchedule(count: 3, interval: r.stagger),
                                                 reduceMotion: config.accessible || reduceMotion) }
                }) { Label("Replay sequence", systemImage: "play.fill") }
                    .accessibilityIdentifier("replay-sequence")
                ForEach(0..<sequence.visibleCount, id: \.self) { index in
                    Text("Step \(index + 1) complete").frame(maxWidth: .infinity, alignment: .leading)
                        .padding(r.gap).nativeSurface(theme: r.theme, metrics: r.surface, style: (config.accessible || !config.allowsGlass) ? .opaque : .glass)
                        .transition(NativeTransition.opacity.transition(reduceMotion: reduceMotion))
                }
                Text("Visible steps: \(sequence.visibleCount)").accessibilityIdentifier("sequence-state")
                Button("Cancel sequence") { sequence.cancel() }
                Text("Long labels remain readable, wrap naturally, and follow the caller's layout direction.")
                    .nativeGrowingText()
            }
            panel("FOUNDATIONS / LAYOUT", "Equal, adaptive and flowing") {
                NativeEqualGrid(columns: 2, spacing: r.gap) {
                    ForEach(["One", "Two", "Three", "Four"], id: \.self) { value in
                        Text(value).frame(maxWidth: .infinity).padding(r.gap)
                            .nativeSurface(theme: r.theme, metrics: r.surface, style: .opaque)
                    }
                }
                NativeFlow(items: ["Flow", "Longer label", "Wrap", "RTL ready"].map { FlowItem(id: $0) },
                           horizontalSpacing: r.gap, verticalSpacing: r.gap) { item in
                    NativeBadge(theme: r.theme, metrics: r.metrics, tone: .neutral) { Text(item.id) }
                }
                Text("Touch targets, keyboard focus and native safe-area behavior stay available.")
                    .foregroundColor(r.secondary).nativeGrowingText()
            }
        }
    }
}
