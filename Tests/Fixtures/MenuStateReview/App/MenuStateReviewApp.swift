import Strata
import SwiftUI

@main
struct MenuStateReviewApp: App {
    var body: some Scene {
        WindowGroup {
            MenuStateReviewBoard()
        }
    }
}

private struct MenuStateReviewBoard: View {
    @State private var brand = "strata-blue"
    @State private var mode = "light"
    @State private var selection = "all"
    @State private var menuResult = "Ready"
    @State private var stateResult = "Retry available"
    private let metrics = try! StrataComponentMetrics()

    private var theme: StrataTheme {
        try! StrataTheme(
            theme: mode == "dark" ? .dark : .light,
            brand: brand
        )
    }

    private let segments = [
        StrataSegmentedItem(id: "all", title: "All", badgeCount: 7),
        StrataSegmentedItem(id: "chest", title: "Chest", badgeCount: 3),
        StrataSegmentedItem(id: "legs", title: "Legs")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Menu and state components")
                .font(.title2.bold())
                .accessibilityIdentifier("board-title")

            themeControls

            HStack(spacing: 8) {
                statusLine("Theme: \(brand) · \(mode)", identifier: "theme-status")
                statusLine("Menu: \(menuResult)", identifier: "menu-result")
                statusLine("State: \(stateResult)", identifier: "state-result")
            }

            HStack(alignment: .center, spacing: 8) {
                StrataSegmentedBar(
                    theme: theme,
                    items: segments,
                    selection: $selection,
                    metrics: metrics
                )
                .accessibilityIdentifier("horizontal-segmented-bar")

                StrataMenu(
                    theme: theme,
                    label: "More actions",
                    actions: [
                        StrataMenuAction(
                            id: "copy",
                            title: "Copy set",
                            systemImage: "doc.on.doc"
                        ) {
                            menuResult = "Copied"
                        },
                        StrataMenuAction(
                            id: "delete",
                            title: "Delete set",
                            systemImage: "trash",
                            role: .destructive
                        ) {
                            menuResult = "Deleted"
                        }
                    ],
                    metrics: metrics
                )
            }

            HStack(alignment: .top, spacing: 12) {
                StrataSegmentedBar(
                    theme: theme,
                    items: segments,
                    selection: $selection,
                    axis: .vertical,
                    metrics: metrics
                )
                .accessibilityIdentifier("vertical-segmented-bar")

                VStack(spacing: 8) {
                    StrataStateView(
                        theme: theme,
                        kind: .empty,
                        title: "No matches",
                        message: "Clear filters.",
                        actionTitle: "Reset",
                        action: { stateResult = "reset" },
                        metrics: metrics
                    )
                    .accessibilityIdentifier("empty-state")

                    StrataStateView(
                        theme: theme,
                        kind: .loading,
                        title: "Syncing",
                        message: "Loading templates.",
                        metrics: metrics
                    )
                    .accessibilityIdentifier("loading-state")
                }
            }

            StrataStateView(
                theme: theme,
                kind: .error,
                title: "Could not load history",
                message: "Try again to refresh.",
                actionTitle: "Retry",
                action: { stateResult = "retried" },
                metrics: metrics
            )
            .accessibilityIdentifier("error-state")
        }
        .padding(8)
        .foregroundStyle(theme.foreground)
        .background(theme.canvas.ignoresSafeArea())
        .preferredColorScheme(mode == "dark" ? .dark : .light)
    }

    private var themeControls: some View {
        HStack(spacing: 4) {
            themeButton(brand: "strata-blue", mode: "light", title: "Blue L")
            themeButton(brand: "strata-blue", mode: "dark", title: "Blue D")
            themeButton(brand: "strata-purple", mode: "light", title: "Purple L")
            themeButton(brand: "strata-purple", mode: "dark", title: "Purple D")
        }
    }

    private func statusLine(_ value: String, identifier: String) -> some View {
        Text(value)
            .font(.caption2)
            .foregroundStyle(theme.secondaryForeground)
            .lineLimit(1)
            .accessibilityIdentifier(identifier)
    }

    private func themeButton(brand: String, mode: String, title: String) -> some View {
        Button(title) {
            self.brand = brand
            self.mode = mode
        }
        .accessibilityIdentifier("theme-\(brand.dropFirst(7))-\(mode)")
        .frame(minWidth: 44, minHeight: 36)
        .buttonStyle(.bordered)
        .tint(theme.accent)
    }
}
