import SwiftUI

public struct StrataIndexRailItem: Identifiable, Sendable, Equatable {
    public let id: String
    public let shortLabel: String
    public let fullTitle: String

    public init(id: String, shortLabel: String, fullTitle: String) {
        self.id = id
        self.shortLabel = shortLabel
        self.fullTitle = fullTitle
    }
}

/// A compact caller-driven index with full-name accessibility labels and HUD feedback.
public struct StrataIndexRail: View {
    private let theme: StrataTheme
    private let items: [StrataIndexRailItem]
    private let activeID: String?
    private let showsHUD: Bool
    private let onSelect: (String) -> Void
    @State private var railHeight: CGFloat = 0

    public init(
        theme: StrataTheme,
        items: [StrataIndexRailItem],
        activeID: String?,
        showsHUD: Bool = false,
        onSelect: @escaping (String) -> Void
    ) {
        self.theme = theme
        self.items = items
        self.activeID = activeID
        self.showsHUD = showsHUD
        self.onSelect = onSelect
    }

    public var body: some View {
        if items.isEmpty {
            EmptyView()
        } else {
            ZStack(alignment: .trailing) {
                VStack(spacing: 0) {
                    ForEach(items) { item in
                        let isActive = item.id == activeID
                        Button {
                            onSelect(item.id)
                        } label: {
                            Text(item.shortLabel)
                                .font(.caption.weight(.semibold))
                                .frame(width: 24)
                                .frame(minHeight: 44)
                                .foregroundStyle(isActive ? theme.onAccent : theme.secondaryForeground)
                                .background {
                                    if isActive {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(theme.accent)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(item.fullTitle)
                    }
                }
                .frame(width: 24)
                .background(theme.surface(.inset), in: Capsule())
                .contentShape(Capsule())
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                railHeight = proxy.size.height
                            }
                            .onChange(of: proxy.size.height) { newHeight in
                                railHeight = newHeight
                            }
                    }
                )
                .simultaneousGesture(DragGesture(minimumDistance: 4).onChanged { value in
                    selectItem(at: value.location.y)
                })

                if showsHUD, let activeItem {
                    Text(activeItem.fullTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(theme.onAccent)
                        .padding(.horizontal, 12)
                        .frame(minHeight: 44)
                        .background(theme.accent, in: Capsule())
                        .fixedSize()
                        .offset(x: -32)
                        .allowsHitTesting(false)
                }
            }
            .accessibilityElement(children: .contain)
            .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
        }
    }

    private var activeItem: StrataIndexRailItem? {
        guard let activeID else { return nil }
        return items.first { $0.id == activeID }
    }

    static func itemIndex(at y: CGFloat, railHeight: CGFloat, itemCount: Int) -> Int? {
        guard itemCount > 0 else { return nil }
        let effectiveHeight = railHeight > 0 ? railHeight : CGFloat(itemCount) * 44
        let itemHeight = max(effectiveHeight / CGFloat(itemCount), 1)
        return min(max(Int(y / itemHeight), 0), itemCount - 1)
    }

    private func selectItem(at y: CGFloat) {
        guard let index = Self.itemIndex(at: y, railHeight: railHeight, itemCount: items.count) else {
            return
        }
        onSelect(items[index].id)
    }
}
