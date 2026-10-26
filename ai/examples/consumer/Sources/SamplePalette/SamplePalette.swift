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
}
