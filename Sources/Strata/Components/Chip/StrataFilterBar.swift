import SwiftUI

/// A typed filter option displayed by ``StrataFilterBar``.
public struct StrataFilterItem<ID: Hashable & Sendable>: Identifiable, Equatable, Sendable {
    public let id: ID
    public let title: String
    public let count: Int?

    public init(id: ID, title: String, count: Int? = nil) {
        self.id = id
        self.title = title
        self.count = count
    }
}

/// A single-line, horizontally scrolling collection of filter chips.
public struct StrataFilterBar<ID: Hashable & Sendable>: View {
    private let theme: StrataTheme
    private let items: [StrataFilterItem<ID>]
    private let allTitle: String?
    private let selectedID: () -> ID?
    private let onSelect: (ID?) -> Void

    /// Creates a filter rail backed by caller-owned optional selection.
    public init(
        theme: StrataTheme,
        items: [StrataFilterItem<ID>],
        selection: Binding<ID?>,
        allTitle: String? = "All"
    ) {
        self.init(
            theme: theme,
            items: items,
            allTitle: allTitle,
            selectedID: { selection.wrappedValue },
            onSelect: { selection.wrappedValue = $0 }
        )
    }

    /// Creates a filter rail with callback-based selection.
    public init(
        theme: StrataTheme,
        items: [StrataFilterItem<ID>],
        selectedID: ID?,
        allTitle: String? = "All",
        onSelect: @escaping (ID?) -> Void
    ) {
        self.init(
            theme: theme,
            items: items,
            allTitle: allTitle,
            selectedID: { selectedID },
            onSelect: onSelect
        )
    }

    private init(
        theme: StrataTheme,
        items: [StrataFilterItem<ID>],
        allTitle: String?,
        selectedID: @escaping () -> ID?,
        onSelect: @escaping (ID?) -> Void
    ) {
        self.theme = theme
        self.items = items
        self.allTitle = allTitle
        self.selectedID = selectedID
        self.onSelect = onSelect
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let allTitle {
                    chip(
                        title: allTitle,
                        count: nil,
                        isSelected: selectedID() == nil,
                        action: { onSelect(nil) }
                    )
                }

                ForEach(items) { item in
                    chip(
                        title: item.title,
                        count: item.count,
                        isSelected: selectedID() == item.id,
                        action: { onSelect(item.id) }
                    )
                }
            }
            .padding(.horizontal, 12)
        }
        .frame(minHeight: 44)
        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
    }

    private func chip(
        title: String,
        count: Int?,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .lineLimit(1)
                if let count {
                    Text("\(count)")
                        .monospacedDigit()
                }
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(isSelected ? theme.onInteractiveAccent : theme.foreground)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 12)
            .frame(minHeight: 44)
            .background(
                isSelected ? theme.interactiveAccent : theme.surface(.card),
                in: Capsule()
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
