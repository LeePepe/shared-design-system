import DesignTokens
import Strata
import SwiftUI

public enum SamplePalette {
    public static func color(_ id: String, theme: Theme) throws -> Color {
        try StrataTokenColor.resolve(id, theme: theme)
    }

    @MainActor
    public static func searchField(theme: StrataTheme, text: Binding<String>) throws -> some View {
        let configuration = try StrataSearchFieldConfiguration(
            label: "Search", placeholder: "Find an item", clearLabel: "Clear search")
        return StrataSearchField(theme: theme, text: text, configuration: configuration)
    }

    @MainActor
    public static func numberSlot(theme: StrataTheme) throws -> some View {
        let configuration = try StrataNumberSlotConfiguration(
            label: "Weight", displayValue: "20", unitLabel: "kg")
        return StrataNumberSlot(theme: theme, configuration: configuration, action: {})
    }

    @MainActor
    public static func dockedHeader(theme: StrataTheme) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            StrataSectionHeader(theme: theme, title: "Equipment") {
                Button("More") {}
            }
            StrataDockedBar(theme: theme) {
                Button("Done") {}
            }
        }
    }

    @MainActor
    public static func menu(theme: StrataTheme) throws -> some View {
        try StrataMenu(
            theme: theme,
            label: "More actions",
            actions: [
                StrataMenuAction(id: "copy", title: "Copy set", systemImage: "doc.on.doc") {},
                StrataMenuAction(
                    id: "delete",
                    title: "Delete set",
                    systemImage: "trash",
                    role: .destructive
                ) {}
            ]
        )
    }

    @MainActor
    public static func segmentedBar(theme: StrataTheme) throws -> some View {
        try StrataSegmentedBar(
            theme: theme,
            items: [
                StrataSegmentedItem(id: "all", title: "All", badgeCount: 3),
                StrataSegmentedItem(id: "legs", title: "Legs")
            ],
            selection: .constant("all")
        )
    }

    @MainActor
    public static func stateView(theme: StrataTheme) throws -> some View {
        try StrataStateView(
            theme: theme,
            kind: .empty,
            title: "No matches",
            message: "Try a different search.",
            actionTitle: "Reset",
            action: {}
        )
    }
}
