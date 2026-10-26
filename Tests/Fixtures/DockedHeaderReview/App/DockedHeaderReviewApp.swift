import Strata
import SwiftUI

@main
struct DockedHeaderReviewApp: App {
    private let configuration = ReviewConfiguration()

    var body: some Scene {
        WindowGroup {
            DockedHeaderReviewBoard(configuration: configuration)
                .preferredColorScheme(configuration.mode == "dark" ? .dark : .light)
        }
    }
}

private struct ReviewConfiguration {
    let brand: String
    let mode: String

    init() {
        let environment = ProcessInfo.processInfo.environment
        brand = environment["NDK_BRAND"] ?? "strata-blue"
        mode = environment["NDK_THEME"] ?? "light"
    }
}

private struct DockedHeaderReviewBoard: View {
    let configuration: ReviewConfiguration
    @State private var activeID: String? = "bar"
    @State private var selectedID = "none"

    private var theme: StrataTheme {
        try! StrataTheme(theme: configuration.mode == "dark" ? .dark : .light, brand: configuration.brand)
    }

    private let items = [
        StrataIndexRailItem(id: "bar", shortLabel: "B", fullTitle: "Barbell"),
        StrataIndexRailItem(id: "dumbbell", shortLabel: "D", fullTitle: "Dumbbell"),
        StrataIndexRailItem(id: "machine", shortLabel: "M", fullTitle: "Machine"),
        StrataIndexRailItem(id: "cable", shortLabel: "C", fullTitle: "Cable"),
        StrataIndexRailItem(id: "bodyweight", shortLabel: "W", fullTitle: "Bodyweight")
    ]

    var body: some View {
        ZStack(alignment: .trailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Docked header components")
                        .font(.title.bold())
                        .accessibilityIdentifier("board-title")
                    Text("\(configuration.brand) · \(configuration.mode)")
                        .font(.caption)
                    StrataSectionHeader(theme: theme, title: "Barbell", subtitle: "Chest and shoulders", badgeText: "3") {
                        Button("More") { selectedID = "more" }
                            .accessibilityIdentifier("section-more")
                    }
                    .accessibilityIdentifier("section-header")
                    StrataDockedBar(theme: theme) {
                        HStack {
                            Text("Add exercise")
                            Spacer()
                            Button("Done") { selectedID = "done" }
                                .accessibilityIdentifier("docked-done")
                        }
                    }
                    .accessibilityIdentifier("docked-bar")
                    Text("Selected: \(selectedID)")
                        .accessibilityIdentifier("selection")
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .accessibilityIdentifier("review-scroll")
            StrataIndexRail(theme: theme, items: items, activeID: activeID, showsHUD: true) {
                activeID = $0
                selectedID = $0
            }
            .accessibilityIdentifier("index-rail")
            .padding(.trailing, 8)
        }
        .foregroundStyle(theme.foreground)
        .background(theme.canvas.ignoresSafeArea())
    }
}
