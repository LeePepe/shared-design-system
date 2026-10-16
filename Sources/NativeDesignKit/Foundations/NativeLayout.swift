import SwiftUI

/// Equal-width columns retain SwiftUI's lazy rendering, logical direction and child identity.
public struct NativeEqualGrid<Content: View>: View {
    private let columns: Int
    private let spacing: CGFloat
    private let content: Content

    public init(columns: Int, spacing: CGFloat, @ViewBuilder content: () -> Content) {
        precondition(columns > 0 && spacing.isFinite && spacing >= 0)
        self.columns = columns
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns),
                  alignment: .leading, spacing: spacing) { content }
    }
}

public struct NativeAdaptiveGrid<Content: View>: View {
    private let minimumWidth: CGFloat
    private let spacing: CGFloat
    private let content: Content

    public init(minimumWidth: CGFloat, spacing: CGFloat, @ViewBuilder content: () -> Content) {
        precondition(minimumWidth.isFinite && minimumWidth > 0 && spacing.isFinite && spacing >= 0)
        self.minimumWidth = minimumWidth
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: minimumWidth), spacing: spacing)],
                  alignment: .leading, spacing: spacing) { content }
    }
}

/// Shared deterministic packing used by the modern Layout and legacy measured adapter.
struct NativeFlowPacking {
    let rows: [[Int]]
    let frames: [CGRect]
    let size: CGSize

    init(sizes: [CGSize], width: CGFloat, horizontalSpacing: CGFloat, verticalSpacing: CGFloat) {
        let width = width.isFinite ? max(0, width) : .greatestFiniteMagnitude
        var rows: [[Int]] = []
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var row: [Int] = []
        var usedWidth: CGFloat = 0
        for (index, size) in sizes.enumerated() {
            let itemWidth = min(max(0, size.width), width)
            let itemHeight = max(0, size.height)
            if !row.isEmpty && x + itemWidth > width {
                rows.append(row)
                row = []
                x = 0
                y += rowHeight + verticalSpacing
                rowHeight = 0
            }
            frames.append(CGRect(x: x, y: y, width: itemWidth, height: itemHeight))
            row.append(index)
            usedWidth = max(usedWidth, x + itemWidth)
            x += itemWidth + horizontalSpacing
            rowHeight = max(rowHeight, itemHeight)
        }
        if !row.isEmpty { rows.append(row) }
        self.rows = rows
        self.frames = frames
        self.size = CGSize(width: usedWidth, height: sizes.isEmpty ? 0 : y + rowHeight)
    }
}

/// Native wrapping layout with remeasurement for oversized localized content.
@available(iOS 16, macOS 13, *)
public struct NativeFlowLayout: Layout {
    public let horizontalSpacing: CGFloat
    public let verticalSpacing: CGFloat
    /// Pass the SwiftUI environment direction; native layout placement mirrors it once.
    public let layoutDirection: LayoutDirection

    public init(horizontalSpacing: CGFloat, verticalSpacing: CGFloat, layoutDirection: LayoutDirection) {
        precondition(horizontalSpacing.isFinite && horizontalSpacing >= 0 &&
                     verticalSpacing.isFinite && verticalSpacing >= 0)
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.layoutDirection = layoutDirection
    }

    private func packing(proposal: ProposedViewSize, subviews: Subviews) -> NativeFlowPacking {
        let width = proposal.width ?? .greatestFiniteMagnitude
        let sizes = subviews.map { subview in
            let ideal = subview.sizeThatFits(.unspecified)
            return ideal.width > width
                ? subview.sizeThatFits(ProposedViewSize(width: width, height: nil)) : ideal
        }
        return NativeFlowPacking(sizes: sizes, width: width,
                                 horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing)
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        packing(proposal: proposal, subviews: subviews).size
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let packing = packing(proposal: ProposedViewSize(width: bounds.width, height: nil), subviews: subviews)
        for (index, frame) in packing.frames.enumerated() {
            // Layout coordinates are logical: SwiftUI mirrors placement in RTL.
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                                  anchor: .topLeading,
                                  proposal: ProposedViewSize(width: frame.width, height: frame.height))
        }
    }
}

private struct FlowMeasurement<ID: Hashable>: Equatable {
    var sizes: [ID: CGSize] = [:]
    var width: CGFloat?
}

private struct FlowMeasurements<ID: Hashable>: PreferenceKey {
    static var defaultValue: FlowMeasurement<ID> { FlowMeasurement() }
    static func reduce(value: inout FlowMeasurement<ID>, nextValue: () -> FlowMeasurement<ID>) {
        let next = nextValue()
        value.sizes.merge(next.sizes, uniquingKeysWith: { _, new in new })
        if let width = next.width { value.width = width }
    }
}

/// Full-range adapter, internal so current-runtime rendering tests can force the old-OS path.
/// Each child receives the whole container's width, rather than a share of an HStack.
/// Text retains its ideal width when it fits and grows vertically when it must wrap.
struct NativeLegacyFlow<Item: Identifiable, Content: View>: View {
    let items: [Item]
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    @ViewBuilder let content: (Item) -> Content
    @State private var measurement = FlowMeasurement<Item.ID>()

    var body: some View {
        let packing = NativeFlowPacking(
            sizes: items.map { measurement.sizes[$0.id] ?? .zero }, width: measurement.width ?? 0,
            horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing)
        let frames = Dictionary(uniqueKeysWithValues: zip(items.map(\.id), packing.frames))
        ZStack(alignment: .topLeading) {
            ForEach(items) { item in
                let frame = frames[item.id, default: .zero]
                content(item)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(GeometryReader { child in
                        Color.clear.preference(key: FlowMeasurements<Item.ID>.self,
                                               value: FlowMeasurement(sizes: [item.id: child.size]))
                    })
                    // SwiftUI mirrors both leading alignment and offsets in RTL.
                    .offset(x: frame.minX, y: frame.minY)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        // Derive height directly from the same packing as placement. A second measured
        // height/state pass can retain an old height when content changes rapidly.
        .frame(height: packing.size.height, alignment: .topLeading)
        .background(GeometryReader { geometry in
            Color.clear.preference(key: FlowMeasurements<Item.ID>.self,
                                   value: FlowMeasurement(width: geometry.size.width))
        })
        .onPreferenceChange(FlowMeasurements<Item.ID>.self) { measurement = $0 }
    }
}

/// Data-based flow works on the full deployment range. The legacy adapter measures and
/// positions a single stable collection; it never duplicates interactive children for sizing.
public struct NativeFlow<Item: Identifiable, Content: View>: View {
    private let items: [Item]
    private let horizontalSpacing: CGFloat
    private let verticalSpacing: CGFloat
    private let content: (Item) -> Content
    @Environment(\.layoutDirection) private var layoutDirection

    public init(items: [Item], horizontalSpacing: CGFloat, verticalSpacing: CGFloat,
                @ViewBuilder content: @escaping (Item) -> Content) {
        precondition(horizontalSpacing.isFinite && horizontalSpacing >= 0 &&
                     verticalSpacing.isFinite && verticalSpacing >= 0)
        self.items = items
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.content = content
    }

    public var body: some View {
        if #available(iOS 16, macOS 13, *) {
            NativeFlowLayout(horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing,
                             layoutDirection: layoutDirection) {
                ForEach(items) { content($0) }
            }
        } else {
            NativeLegacyFlow(items: items, horizontalSpacing: horizontalSpacing,
                             verticalSpacing: verticalSpacing, content: content)
        }
    }
}

public enum NativeKeyboardDismissal: Sendable {
    case immediately
    case interactively
    case never
}

public extension View {
    /// Native scroll keyboard dismissal where supported; older OS behavior stays native.
    @ViewBuilder func nativeKeyboardDismissal(_ policy: NativeKeyboardDismissal) -> some View {
        if #available(iOS 16, macOS 13, *) {
            switch policy {
            case .immediately: scrollDismissesKeyboard(.immediately)
            case .interactively: scrollDismissesKeyboard(.interactively)
            case .never: scrollDismissesKeyboard(.never)
            }
        } else { self }
    }
}
