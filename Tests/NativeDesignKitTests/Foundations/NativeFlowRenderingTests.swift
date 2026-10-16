import SwiftUI
import XCTest
@testable import NativeDesignKit
#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Hosts the actual legacy adapter on current runtimes; packing-only tests cannot detect
/// compressed proposals, double RTL mirroring, duplicate children or lost SwiftUI state.
@MainActor
final class NativeFlowRenderingTests: XCTestCase {
    func testForcedLegacyMeasuresNaturalLabelsAndWrapsWithoutCompression() async throws {
        let model = FlowRenderModel(width: 200, items: (0..<3).map {
            FlowRenderItem(id: $0, label: "Benachrichtigungen")
        })
        let host = FlowRenderHost(model)
        defer { host.close() }
        try await settle(model) {
            let frames = model.orderedFrames
            return frames.count == 3 && frames.allSatisfy { $0.width > 100 } &&
                frames[1].minY > frames[0].maxY && frames[2].minY > frames[1].maxY
        }
        assertContainedAndDisjoint(model)
        XCTAssertEqual(model.orderedFrames[1].minY - model.orderedFrames[0].maxY, 9, accuracy: 1)
        XCTAssertEqual(model.containerSize.height, model.orderedFrames[2].maxY, accuracy: 1)
        try attach(host, name: "legacy-natural-labels")
    }

    func testForcedLegacyRemeasuresNaturalWidthsWhenLabelsGrowInTheSameRow() async throws {
        let model = FlowRenderModel(width: 200, items: (0..<3).map {
            FlowRenderItem(id: $0, label: "A")
        })
        let host = FlowRenderHost(model)
        defer { host.close() }
        try await settle(model) {
            model.readings.count == 3 && model.orderedFrames.allSatisfy { $0.minY < 1 }
        }
        let identities = model.readings.mapValues(\.identity)
        // A localization/content update must remeasure ideal widths, not accept each
        // child's compressed share of the previously packed HStack as its new width.
        model.items = model.items.map { FlowRenderItem(id: $0.id, label: "Benachrichtigungen") }
        try await settle(model) {
            let frames = model.orderedFrames
            return frames.count == 3 && frames.allSatisfy { $0.width > 100 } &&
                frames[1].minY > frames[0].maxY && frames[2].minY > frames[1].maxY
        }
        XCTAssertEqual(model.readings.mapValues(\.identity), identities)
        assertContainedAndDisjoint(model)
        try attach(host, name: "legacy-labels-grow-from-one-row")
    }

    func testForcedLegacyRetainsInteractiveChildStateAcrossResizeAndReorder() async throws {
        let model = FlowRenderModel(width: 500, items: (0..<3).map {
            FlowRenderItem(id: $0, label: "Benachrichtigungen")
        })
        let host = FlowRenderHost(model)
        defer { host.close() }
        try await settle(model) { model.readings.count == 3 && model.orderedFrames.allSatisfy { $0.minY < 1 } }
        let identities = model.readings.mapValues(\.identity)
        // This is the same action closure supplied to each rendered native Button.
        for action in model.actions.values { action() }
        try await settle(model) { model.readings.values.allSatisfy { $0.count == 1 } }

        model.width = 200
        try await settle(model) {
            model.orderedFrames.count == 3 && model.orderedFrames[2].minY > model.orderedFrames[1].maxY
        }
        XCTAssertEqual(model.readings.mapValues(\.identity), identities)
        model.items.reverse()
        try await settle(model) { model.readings[2]!.frame.minY < model.readings[0]!.frame.minY }
        XCTAssertEqual(model.readings.mapValues(\.identity), identities)
        XCTAssertTrue(model.readings.values.allSatisfy { $0.count == 1 })
        assertContainedAndDisjoint(model)

        model.width = 500
        try await settle(model) { model.orderedFrames.allSatisfy { $0.minY < 1 } }
        XCTAssertEqual(model.readings.mapValues(\.identity), identities)
        XCTAssertTrue(model.readings.values.allSatisfy { $0.count == 1 })
        XCTAssertEqual(model.appearances, [0: 1, 1: 1, 2: 1])
        XCTAssertEqual(model.maximumLiveCopies, [0: 1, 1: 1, 2: 1])
        try attach(host, name: "legacy-state-after-resize-and-reorder")
    }

    func testForcedLegacyRemeasuresOversizedLocalizedLabelsAndChangedContent() async throws {
        let longLabel = "Datenschutzeinstellungen und Benachrichtigungsberechtigungen für alle Geräte verwalten. "
        let model = FlowRenderModel(width: 190, items: [
            FlowRenderItem(id: 0, label: longLabel + longLabel),
            FlowRenderItem(id: 1, label: "Weiter")
        ])
        model.dynamicTypeSize = .accessibility3
        let host = FlowRenderHost(model)
        defer { host.close() }
        try await settle(model) {
            model.readings.count == 2 && model.readings[0]!.frame.height > 100 &&
                model.readings[1]!.frame.minY > model.readings[0]!.frame.maxY
        }
        let narrowHeight = model.readings[0]!.frame.height
        assertContainedAndDisjoint(model)
        try attach(host, name: "legacy-long-localized-large-type-narrow")

        model.width = 480
        try await settle(model) { model.readings[0]!.frame.height < narrowHeight - 20 }
        assertContainedAndDisjoint(model)
        // Same ID and parent: invalidate the size through the actual rendered content,
        // including a label growing again after it has previously become short.
        model.items[0].label = "Kurz"
        try await settle(model) { model.readings[0]!.frame.width < 150 && model.readings[1]!.frame.minY < 1 }
        model.items[0].label = longLabel + longLabel
        model.width = 190
        try await settle(model) { model.readings[0]!.frame.height >= narrowHeight - 1 }
        assertContainedAndDisjoint(model)
    }

    func testRenderedRTLPlacementForForcedLegacyAndModernFlow() async throws {
        for legacy in [true, false] {
            let model = FlowRenderModel(width: 300, items: [
                FlowRenderItem(id: 0, label: "أول"), FlowRenderItem(id: 1, label: "ثان")
            ])
            model.legacy = legacy
            model.direction = .rightToLeft
            let host = FlowRenderHost(model)
            defer { host.close() }
            try await settle(model) {
                model.readings.count == 2 && model.readings[0]!.frame.minX > model.readings[1]!.frame.maxX
            }
            XCTAssertEqual(model.readings[0]!.frame.maxX, model.containerSize.width, accuracy: 1)
            XCTAssertEqual(model.readings[0]!.frame.minX - model.readings[1]!.frame.maxX, 7, accuracy: 1)
            assertContainedAndDisjoint(model)
            model.direction = .leftToRight
            try await settle(model) { model.readings[0]!.frame.maxX < model.readings[1]!.frame.minX }
            XCTAssertEqual(model.readings[0]!.frame.minX, 0, accuracy: 1)
            model.direction = .rightToLeft

            let arabic = "إعدادات الخصوصية وإدارة أذونات الإشعارات لجميع الأجهزة المتصلة "
            model.items = [FlowRenderItem(id: 0, label: arabic + arabic + arabic),
                           FlowRenderItem(id: 1, label: "متابعة")]
            model.width = 180
            model.dynamicTypeSize = .accessibility3
            try await settle(model) {
                model.readings[0]!.frame.height > 100 &&
                    model.readings[1]!.frame.minY > model.readings[0]!.frame.maxY
            }
            assertContainedAndDisjoint(model)
            XCTAssertEqual(model.readings[1]!.frame.maxX, model.containerSize.width, accuracy: 1)
            try attach(host, name: legacy ? "legacy-rtl-long-label" : "modern-rtl-long-label")
        }
    }

    private func settle(_ model: FlowRenderModel, until predicate: () -> Bool,
                        file: StaticString = #filePath, line: UInt = #line) async throws {
        let deadline = Date().addingTimeInterval(5)
        var stablePasses = 0
        while Date() < deadline {
            if predicate() && model.readings.count == model.items.count && model.containerSize.height > 0 {
                stablePasses += 1
                if stablePasses == 3 { return }
            } else { stablePasses = 0 }
            try? await Task.sleep(nanoseconds: 20_000_000)
        }
        XCTFail("Rendered flow did not settle: \(model.readings); container \(model.containerSize)",
                file: file, line: line)
        throw FlowRenderFailure.didNotSettle
    }

    private func assertContainedAndDisjoint(_ model: FlowRenderModel,
                                           file: StaticString = #filePath, line: UInt = #line) {
        let frames = model.orderedFrames
        for (index, frame) in frames.enumerated() {
            XCTAssertGreaterThan(frame.width, 0, file: file, line: line)
            XCTAssertGreaterThan(frame.height, 0, file: file, line: line)
            XCTAssertGreaterThanOrEqual(frame.minX, -1, file: file, line: line)
            XCTAssertLessThanOrEqual(frame.maxX, model.width + 1, file: file, line: line)
            XCTAssertGreaterThanOrEqual(frame.minY, -1, file: file, line: line)
            XCTAssertLessThanOrEqual(frame.maxY, model.containerSize.height + 1, file: file, line: line)
            for other in frames.dropFirst(index + 1) {
                XCTAssertFalse(frame.intersects(other), "Overlapping rendered children", file: file, line: line)
            }
        }
    }

    private func attach(_ host: FlowRenderHost, name: String) throws {
        let png = try XCTUnwrap(host.png())
        let attachment = XCTAttachment(data: png, uniformTypeIdentifier: "public.png")
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        // Optional external evidence, never a recorded baseline or a pixel comparison gate.
        if let path = ProcessInfo.processInfo.environment["NDK_FLOW_EVIDENCE_DIR"] {
            let directory = URL(fileURLWithPath: path, isDirectory: true)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try png.write(to: directory.appendingPathComponent(name + ".png"))
        }
    }
}

private enum FlowRenderFailure: Error { case didNotSettle }

private struct FlowRenderItem: Identifiable {
    let id: Int
    var label: String
}

private struct FlowReading: Equatable {
    let frame: CGRect
    let identity: UUID
    let count: Int
}

private struct FlowReadings: PreferenceKey {
    static var defaultValue: [Int: FlowReading] { [:] }
    static func reduce(value: inout [Int: FlowReading], nextValue: () -> [Int: FlowReading]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

@MainActor
private final class FlowRenderModel: ObservableObject {
    @Published var width: CGFloat
    @Published var items: [FlowRenderItem]
    @Published var direction: LayoutDirection = .leftToRight
    @Published var dynamicTypeSize: DynamicTypeSize = .large
    var legacy = true
    var readings: [Int: FlowReading] = [:]
    var containerSize = CGSize.zero
    var actions: [Int: () -> Void] = [:]
    var appearances: [Int: Int] = [:]
    var liveCopies: [Int: Int] = [:]
    var maximumLiveCopies: [Int: Int] = [:]

    init(width: CGFloat, items: [FlowRenderItem]) {
        self.width = width
        self.items = items
    }

    var orderedFrames: [CGRect] { items.compactMap { readings[$0.id]?.frame } }
}

private struct FlowRenderChild: View {
    let item: FlowRenderItem
    @ObservedObject var model: FlowRenderModel
    @State private var identity = UUID()
    @State private var count = 0

    var body: some View {
        Button(action: increment) { Text(item.label).font(.body).padding(4) }
            .buttonStyle(.plain)
            .background(GeometryReader { geometry in
                Color.clear.preference(key: FlowReadings.self, value: [
                    item.id: FlowReading(frame: geometry.frame(in: .named("flow")), identity: identity, count: count)
                ])
            })
            .onAppear {
                model.appearances[item.id, default: 0] += 1
                model.liveCopies[item.id, default: 0] += 1
                model.maximumLiveCopies[item.id] = max(model.maximumLiveCopies[item.id, default: 0],
                                                        model.liveCopies[item.id, default: 0])
                model.actions[item.id] = increment
            }
            .onDisappear { model.liveCopies[item.id, default: 0] -= 1 }
    }

    private func increment() { count += 1 }
}

private struct FlowRenderRoot: View {
    @ObservedObject var model: FlowRenderModel

    var body: some View {
        flow
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(GeometryReader { geometry in
                Color.clear
                    .onAppear { model.containerSize = geometry.size }
                    .onChange(of: geometry.size) { model.containerSize = $0 }
            })
            .coordinateSpace(name: "flow")
            .frame(width: model.width, alignment: .leading)
            .environment(\.layoutDirection, model.direction)
            .environment(\.dynamicTypeSize, model.dynamicTypeSize)
            .environment(\.locale, Locale(identifier: model.direction == .rightToLeft ? "ar" : "de_DE"))
            .environment(\.colorScheme, .light)
            .onPreferenceChange(FlowReadings.self) { model.readings = $0 }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @ViewBuilder private var flow: some View {
        if model.legacy {
            NativeLegacyFlow(items: model.items, horizontalSpacing: 7, verticalSpacing: 9) {
                FlowRenderChild(item: $0, model: model)
            }
        } else {
            NativeFlow(items: model.items, horizontalSpacing: 7, verticalSpacing: 9) {
                FlowRenderChild(item: $0, model: model)
            }
        }
    }
}

@MainActor
private final class FlowRenderHost {
    #if os(macOS)
    private let window: NSWindow
    private let view: NSHostingView<FlowRenderRoot>
    #else
    private let window: UIWindow
    private let controller: UIHostingController<FlowRenderRoot>
    #endif

    init(_ model: FlowRenderModel) {
        let bounds = CGRect(x: 0, y: 0, width: 700, height: 1600)
        #if os(macOS)
        _ = NSApplication.shared
        view = NSHostingView(rootView: FlowRenderRoot(model: model))
        window = NSWindow(contentRect: bounds, styleMask: [.borderless], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = view
        window.orderFront(nil)
        view.layoutSubtreeIfNeeded()
        #else
        controller = UIHostingController(rootView: FlowRenderRoot(model: model))
        window = UIWindow(frame: bounds)
        window.rootViewController = controller
        window.isHidden = false
        controller.view.frame = bounds
        controller.view.layoutIfNeeded()
        #endif
    }

    func close() {
        #if os(macOS)
        window.close()
        #else
        window.isHidden = true
        #endif
    }

    func png() -> Data? {
        #if os(macOS)
        view.layoutSubtreeIfNeeded()
        guard let bitmap = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return nil }
        view.cacheDisplay(in: view.bounds, to: bitmap)
        return bitmap.representation(using: .png, properties: [:])
        #else
        let view = controller.view!
        return UIGraphicsImageRenderer(bounds: view.bounds).pngData { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
        #endif
    }
}
