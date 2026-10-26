import SwiftUI

/// Selection is owned by the caller. Single selection never deselects on repeat activation.
public enum StrataListSelection<ID: Hashable> {
    case single(Binding<ID?>)
    case multiple(Binding<Set<ID>>)
    case readOnly(Set<ID>)

    var isInteractive: Bool {
        if case .readOnly = self { return false }
        return true
    }

    func contains(_ id: ID) -> Bool {
        switch self {
        case .single(let value): value.wrappedValue == id
        case .multiple(let values): values.wrappedValue.contains(id)
        case .readOnly(let values): values.contains(id)
        }
    }

    func activate(_ id: ID, isEnabled: Bool) {
        guard isEnabled else { return }
        switch self {
        case .single(let value):
            if value.wrappedValue != id { value.wrappedValue = id }
        case .multiple(let values):
            var next = values.wrappedValue
            if !next.insert(id).inserted { next.remove(id) }
            values.wrappedValue = next
        case .readOnly:
            break
        }
    }
}

/// A readable collection with native button rows and explicit caller-owned selection.
/// Row builders supply content, not nested interactive controls.
public struct StrataList<
    Data: RandomAccessCollection, ID: Hashable, Header: View,
    Leading: View, Primary: View, Secondary: View, Trailing: View, Footer: View
>: View {
    private let theme: StrataTheme
    private let surface: StrataSurfaceStyle
    private let items: Data
    private let id: KeyPath<Data.Element, ID>
    private let selection: StrataListSelection<ID>
    private let selectedLabel: Text
    private let isRowEnabled: (Data.Element) -> Bool
    private let header: Header
    private let leading: (Data.Element) -> Leading
    private let primary: (Data.Element) -> Primary
    private let secondary: (Data.Element) -> Secondary
    private let trailing: (Data.Element) -> Trailing
    private let footer: Footer

    public init(
        theme: StrataTheme,
        surface: StrataSurfaceStyle,
        items: Data,
        id: KeyPath<Data.Element, ID>,
        selection: StrataListSelection<ID>,
        selectedLabel: Text = Text("Selected"),
        isRowEnabled: @escaping (Data.Element) -> Bool = { _ in true },
        @ViewBuilder header: () -> Header,
        @ViewBuilder leading: @escaping (Data.Element) -> Leading,
        @ViewBuilder primary: @escaping (Data.Element) -> Primary,
        @ViewBuilder secondary: @escaping (Data.Element) -> Secondary,
        @ViewBuilder trailing: @escaping (Data.Element) -> Trailing,
        @ViewBuilder footer: () -> Footer
    ) {
        self.theme = theme
        self.surface = surface
        self.items = items
        self.id = id
        self.selection = selection
        self.selectedLabel = selectedLabel
        self.isRowEnabled = isRowEnabled
        self.header = header()
        self.leading = leading
        self.primary = primary
        self.secondary = secondary
        self.trailing = trailing
        self.footer = footer()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
                .font(.headline)
                .foregroundStyle(theme.foreground)
                .accessibilityAddTraits(.isHeader)
            VStack(spacing: 4) {
                ForEach(items, id: id) { item in
                    let itemID = item[keyPath: id]
                    StrataListItem(
                        theme: theme,
                        isSelected: selection.contains(itemID),
                        isInteractive: selection.isInteractive,
                        isRowEnabled: isRowEnabled(item),
                        action: { selection.activate(itemID, isEnabled: isRowEnabled(item)) }
                    ) {
                        StrataListItemContent(
                            theme: theme, isSelected: selection.contains(itemID),
                            selectedLabel: selectedLabel,
                            leading: leading(item), primary: primary(item),
                            secondary: secondary(item), trailing: trailing(item)
                        )
                    }
                }
            }
            footer
                .font(.caption)
                .foregroundStyle(theme.secondaryForeground)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .strataSurface(theme: theme, style: surface, cornerRadius: 24, role: .card)
        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
    }
}

public extension StrataList where Header == EmptyView, Footer == EmptyView {
    init(
        theme: StrataTheme,
        surface: StrataSurfaceStyle,
        items: Data,
        id: KeyPath<Data.Element, ID>,
        selection: StrataListSelection<ID>,
        selectedLabel: Text = Text("Selected"),
        isRowEnabled: @escaping (Data.Element) -> Bool = { _ in true },
        @ViewBuilder leading: @escaping (Data.Element) -> Leading,
        @ViewBuilder primary: @escaping (Data.Element) -> Primary,
        @ViewBuilder secondary: @escaping (Data.Element) -> Secondary,
        @ViewBuilder trailing: @escaping (Data.Element) -> Trailing
    ) {
        self.init(
            theme: theme, surface: surface, items: items, id: id,
            selection: selection, selectedLabel: selectedLabel, isRowEnabled: isRowEnabled,
            header: { EmptyView() }, leading: leading, primary: primary,
            secondary: secondary, trailing: trailing, footer: { EmptyView() }
        )
    }
}

private struct StrataListItem<Content: View>: View {
    let theme: StrataTheme
    let isSelected: Bool
    let isInteractive: Bool
    let isRowEnabled: Bool
    let action: () -> Void
    @ViewBuilder let content: () -> Content
    @FocusState private var isFocused: Bool

    var body: some View {
        Group {
            if isInteractive {
                Button(action: action, label: content)
                    .buttonStyle(StrataListButtonStyle(theme: theme, isSelected: isSelected))
                    .disabled(!isRowEnabled)
                    .focused($isFocused)
                    .overlay {
                        if isFocused {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(theme.accent, lineWidth: 2)
                                .allowsHitTesting(false)
                        }
                    }
            } else {
                content()
                    .padding(12)
                    .frame(minWidth: 44, minHeight: 44, alignment: .leading)
                    .background(isSelected ? theme.surface(.selected) : .clear,
                                in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .accessibilityElement(children: .combine)
            }
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct StrataListButtonStyle: ButtonStyle {
    let theme: StrataTheme
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        StrataListButtonBody(theme: theme, isSelected: isSelected, configuration: configuration)
    }
}

private struct StrataListButtonBody: View {
    let theme: StrataTheme
    let isSelected: Bool
    let configuration: ButtonStyleConfiguration
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovered = false

    var body: some View {
        configuration.label
            .padding(12)
            .frame(minWidth: 44, minHeight: 44, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? theme.surface(.selected) :
                            (isEnabled && (isHovered || configuration.isPressed) ? theme.surface(.hover) : .clear))
            }
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .onHover { isHovered = $0 }
    }
}

private struct StrataListItemContent<Leading: View, Primary: View, Secondary: View, Trailing: View>: View {
    let theme: StrataTheme
    let isSelected: Bool
    let selectedLabel: Text
    let leading: Leading
    let primary: Primary
    let secondary: Secondary
    let trailing: Trailing
    @Environment(\.dynamicTypeSize) private var typeSize
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Group {
            if typeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 8) {
                    copy
                    HStack(spacing: 12) {
                        leadingContent
                        Spacer(minLength: 0)
                        rowEnd
                    }
                }
            } else {
                HStack(spacing: 12) {
                    copyWithIcon
                    rowEnd
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var copyWithIcon: some View {
        HStack(alignment: .top, spacing: 12) {
            leadingContent
            copy
        }
    }

    private var leadingContent: some View {
        leading
            .font(.body)
            .foregroundStyle(theme.secondaryForeground)
            .frame(width: 28)
            .frame(minHeight: 28)
            .accessibilityHidden(true)
    }

    private var copy: some View {
        VStack(alignment: .leading, spacing: 4) {
            primary.font(.body.weight(.semibold))
                .foregroundStyle(isEnabled ? theme.foreground : theme.secondaryForeground)
            secondary.font(.subheadline).foregroundStyle(theme.secondaryForeground)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder private var rowEnd: some View {
        Group {
            if isSelected {
                Label { selectedLabel } icon: { Image(systemName: "checkmark") }
            } else {
                trailing
            }
        }
        .font(.caption)
        .foregroundStyle(theme.secondaryForeground)
        .fixedSize(horizontal: false, vertical: true)
    }
}
