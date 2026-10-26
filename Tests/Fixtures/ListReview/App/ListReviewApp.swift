@testable import Strata
import SwiftUI

@main
struct ListReviewApp: App {
    private let configuration = Result { try ListConfiguration() }

    var body: some Scene {
        WindowGroup {
            switch configuration {
            case .success(let configuration):
                ListReviewBoard(configuration: configuration)
                    .preferredColorScheme(configuration.mode == "dark" ? .dark : .light)
            case .failure(let error):
                Text("Fixture configuration failed: \(String(describing: error))")
                    .padding().accessibilityIdentifier("fixture-error")
            }
        }
    }
}

private struct ListConfiguration {
    enum Invalid: Error { case input(String) }
    let theme: StrataTheme
    let surface: StrataSurfaceStyle
    let mode: String
    let scenario: String
    let size: DynamicTypeSize
    let reduceTransparency: Bool

    init() throws {
        let environment = ProcessInfo.processInfo.environment
        func required(_ key: String) throws -> String {
            guard let value = environment[key], !value.isEmpty else { throw Invalid.input(key) }
            return value
        }
        let brand = try required("NDK_BRAND")
        mode = try required("NDK_THEME")
        switch mode {
        case "light": theme = try StrataTheme(theme: .light, brand: brand)
        case "dark": theme = try StrataTheme(theme: .dark, brand: brand)
        default: throw Invalid.input("NDK_THEME")
        }
        switch try required("NDK_SURFACE") {
        case "solid": surface = .solid
        case "glass": surface = .glass
        default: throw Invalid.input("NDK_SURFACE")
        }
        scenario = try required("NDK_SCENARIO")
        guard ["specimen", "interaction", "multiple", "read-only", "long-label", "system-fallback"].contains(scenario) else {
            throw Invalid.input("NDK_SCENARIO")
        }
        switch try required("NDK_TEXT_SIZE") {
        case "large": size = .large
        case "accessibility2": size = .accessibility2
        default: throw Invalid.input("NDK_TEXT_SIZE")
        }
        switch try required("NDK_REDUCE_TRANSPARENCY") {
        case "0": reduceTransparency = false
        case "1": reduceTransparency = true
        default: throw Invalid.input("NDK_REDUCE_TRANSPARENCY")
        }
    }
}

private struct DesignNote: Identifiable {
    let id: String
    let title: String
    let detail: String
    let symbol: String
    let metadata: String

    static let samples = [
        DesignNote(id: "surface", title: "表面与层次", detail: "用明度建立空间秩序", symbol: "square.3.layers.3d", metadata: "04 项"),
        DesignNote(id: "color", title: "色彩与语义", detail: "品牌、状态与图表各司其职", symbol: "circle.lefthalf.filled", metadata: "05 色"),
        DesignNote(id: "type", title: "文字与节奏", detail: "让阅读轻松，让重点清晰", symbol: "textformat", metadata: "14 px")
    ]
}

private struct ListReviewBoard: View {
    let configuration: ListConfiguration
    @State private var selected: String? = "surface"
    @State private var selectedIDs: Set<String> = ["surface"]
    @State private var isDisabled = false
    @State private var isReversed = false
    @State private var writes = 0
    @State private var textFrames: [String: CGRect] = [:]
    @Environment(\.accessibilityReduceTransparency) private var systemReduceTransparency
    private var theme: StrataTheme { configuration.theme }
    private var isLong: Bool { configuration.scenario == "long-label" }
    private var items: [DesignNote] {
        if isLong {
            return [DesignNote(id: "surface", title: "Surface hierarchy with a complete, caller-owned descriptive title",
                               detail: "Supporting information wraps naturally and remains readable at accessibility sizes.",
                               symbol: "square.3.layers.3d", metadata: "4 notes")]
        }
        return isReversed ? DesignNote.samples.reversed() : DesignNote.samples
    }
    private var selection: StrataListSelection<String> {
        switch configuration.scenario {
        case "multiple":
            return .multiple(Binding(get: { selectedIDs }, set: { selectedIDs = $0; writes += 1 }))
        case "read-only": return .readOnly(["surface"])
        default:
            return .single(Binding(get: { selected }, set: { selected = $0; writes += 1 }))
        }
    }
    private var currentTitle: String {
        if configuration.scenario == "multiple" {
            let titles = DesignNote.samples.filter { selectedIDs.contains($0.id) }.map(\.title)
            return titles.isEmpty ? "无" : titles.joined(separator: "、")
        }
        if configuration.scenario == "read-only" { return DesignNote.samples[0].title }
        return DesignNote.samples.first(where: { $0.id == selected })?.title ?? "无"
    }
    private var selectedCount: Int {
        if configuration.scenario == "multiple" { return selectedIDs.count }
        if configuration.scenario == "read-only" { return 1 }
        return selected == nil ? 0 : 1
    }

    var body: some View {
        Group {
            if isLong {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        list
                        specimenNote
                    }
                    .padding(16)
                }
                .background(theme.canvas)
            } else {
                specimen
            }
        }
        .frame(width: isLong ? 320 : nil)
        .frame(maxWidth: .infinity, alignment: .top)
        .accessibilityIdentifier("review-scroll")
        .onPreferenceChange(ListTextFrames.self) { textFrames = $0 }
        .dynamicTypeSize(.large)
        .environment(\.nativeReduceTransparencyOverride, configuration.reduceTransparency ? true : nil)
    }

    private var specimenNote: some View {
        Text("悬停轻提亮；选中加深表面，并显示「✓ 已选」。")
            .font(.caption).foregroundStyle(theme.secondaryForeground)
            .accessibilityIdentifier("specimen-note")
            .background(measure("note"))
            .accessibilityValue(frameJSON)
    }

    private var specimen: some View {
        StrataSpecimen(theme: theme, surface: configuration.surface, title: "03  List 列表") {
            list
            specimenNote
            if ["interaction", "multiple", "read-only"].contains(configuration.scenario) {
                behaviorControls
            }
            if configuration.scenario == "system-fallback" {
                Text(systemReduceTransparency ? "System transparency: reduced" : "System transparency: full")
                    .font(.caption).accessibilityIdentifier("system-transparency")
            }
        }
    }

    private var list: some View {
        StrataList(
            theme: theme, surface: configuration.surface, items: items, id: \.id,
            selection: selection, selectedLabel: Text("已选"),
            isRowEnabled: { configuration.scenario != "interaction" || $0.id != "type" }
        ) {
            if isLong {
                Text("长文本示例").font(.caption)
                    .accessibilityIdentifier("list-heading").background(measure("heading"))
            } else {
                HStack {
                    Text("设计笔记").accessibilityIdentifier("list-heading").background(measure("heading"))
                    Spacer(minLength: 8)
                    Text("示例列表").background(measure("badge")).font(.caption).foregroundStyle(theme.secondaryForeground)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(theme.surface(.inset), in: Capsule())
                }
            }
        } leading: { note in
            Image(systemName: note.symbol)
        } primary: { note in
            Text(note.title).accessibilityIdentifier("primary-\(note.id)")
                .background(measure("primary-" + note.id))
        } secondary: { note in
            Text(note.detail).accessibilityIdentifier("secondary-\(note.id)")
                .background(measure("secondary-" + note.id))
        } trailing: { note in
            Text(note.metadata).background(measure("metadata-" + note.id))
        } footer: {
            VStack(alignment: .leading, spacing: 4) {
                if !isLong {
                    HStack(alignment: .top) {
                        Text("当前：\(currentTitle)").accessibilityIdentifier("selection-context").background(measure("context"))
                        Spacer(minLength: 8)
                        Text("点击切换").background(measure("instruction"))
                    }
                }
                Text("\(selectedCount) 项已选").accessibilityIdentifier("selected-count").background(measure("count"))
            }
        }
        .disabled(isDisabled)
        .dynamicTypeSize(configuration.size)
    }

    private var frameJSON: String {
        var payload = textFrames.mapValues { [$0.minX, $0.minY, $0.width, $0.height] }
        payload["_systemReduced"] = [systemReduceTransparency ? 1 : 0]
        guard let data = try? JSONSerialization.data(withJSONObject: payload, options: [.sortedKeys]),
              let text = String(data: data, encoding: .utf8) else { return "{}" }
        return text
    }

    private func measure(_ name: String) -> some View {
        GeometryReader { proxy in
            Color.clear.preference(key: ListTextFrames.self, value: [name: proxy.frame(in: .global)])
        }
    }

    private var behaviorControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Writes: \(writes)").accessibilityIdentifier("selection-writes")
            Button("Toggle disabled") { isDisabled.toggle() }.accessibilityIdentifier("toggle-disabled")
            Button("Reverse items") { isReversed.toggle() }.accessibilityIdentifier("reverse-items")
            Button("Select color externally") {
                selected = "color"
                selectedIDs = ["color"]
            }.accessibilityIdentifier("external-selection")
        }
        .font(.body)
        .buttonStyle(.bordered)
    }
}

private struct ListTextFrames: PreferenceKey {
    static let defaultValue: [String: CGRect] = [:]
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, next in next })
    }
}
