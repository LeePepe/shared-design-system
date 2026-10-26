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
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Menu and state components")
                    .font(.title2.bold())
                    .accessibilityIdentifier("board-title")
                Text("\(brand) · \(mode)")
                    .font(.caption)
                    .foregroundStyle(theme.secondaryForeground)
                    .accessibilityIdentifier("theme-label")

                themeControls

                HStack(alignment: .center, spacing: 8) {
                    Text("Set actions")
                        .font(.headline)
                    Spacer()
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
                        ]
                    )
                }
                Text("Menu result: \(menuResult)")
                    .font(.caption)
                    .foregroundStyle(theme.secondaryForeground)
                    .accessibilityIdentifier("menu-result")

                StrataSegmentedBar(
                    theme: theme,
                    items: segments,
                    selection: $selection
                )
                .accessibilityIdentifier("horizontal-segmented-bar")

                HStack(alignment: .top, spacing: 12) {
                    Text("Muscle groups")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    StrataSegmentedBar(
                        theme: theme,
                        items: segments,
                        selection: $selection,
                        axis: .vertical
                    )
                    .accessibilityIdentifier("vertical-segmented-bar")
                }

                StrataStateView(
                    theme: theme,
                    kind: .error,
                    title: "Could not load history",
                    message: "Try again to refresh this workout.",
                    actionTitle: "Retry",
                    isActionLoading: stateResult == "Retrying",
                    action: {
                        stateResult = "Retrying"
                        DispatchQueue.main.async {
                            stateResult = "Retry available"
                        }
                    }
                )
                .accessibilityIdentifier("error-state")
                Text("State: \(stateResult)")
                    .font(.caption)
                    .foregroundStyle(theme.secondaryForeground)
                    .accessibilityIdentifier("state-result")
            }
            .padding(16)
        }
        .foregroundStyle(theme.foreground)
        .background(theme.canvas.ignoresSafeArea())
        .preferredColorScheme(mode == "dark" ? .dark : .light)
    }

    private var themeControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Review theme").font(.headline)
            HStack(spacing: 8) {
                themeButton(brand: "strata-blue", mode: "light", title: "Blue light")
                themeButton(brand: "strata-blue", mode: "dark", title: "Blue dark")
            }
            HStack(spacing: 8) {
                themeButton(brand: "strata-purple", mode: "light", title: "Purple light")
                themeButton(brand: "strata-purple", mode: "dark", title: "Purple dark")
            }
        }
    }

    private func themeButton(brand: String, mode: String, title: String) -> some View {
        Button(title) {
            self.brand = brand
            self.mode = mode
        }
        .accessibilityIdentifier("theme-\(brand.dropFirst(7))-\(mode)")
        .frame(minWidth: 44, minHeight: 44)
        .buttonStyle(.bordered)
        .tint(theme.accent)
    }
}
