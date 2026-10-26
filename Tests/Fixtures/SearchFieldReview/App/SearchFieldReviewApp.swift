import Strata
import SwiftUI

@main
struct SearchFieldReviewApp: App {
    private let configuration = ReviewConfiguration()

    var body: some Scene {
        WindowGroup {
            SearchFieldReviewBoard(configuration: configuration)
        }
    }
}

private struct ReviewConfiguration {
    let brand: String
    let mode: String

    init() {
        let environment = ProcessInfo.processInfo.environment
        brand = environment["NDK_BRAND"] ?? "ocean"
        mode = environment["NDK_THEME"] ?? "light"
    }
}

private struct SearchFieldReviewBoard: View {
    let configuration: ReviewConfiguration
    @State private var query = "Squat"
    @State private var empty = ""
    @State private var clearCount = 0

    private var theme: StrataTheme {
        try! StrataTheme(theme: configuration.mode == "dark" ? .dark : .light,
                         brand: configuration.brand == "graphite" ? "graphite" : "ocean")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Search and number slots").font(.title.bold())
                Text("\(configuration.brand.capitalized) \(configuration.mode.capitalized)")
                    .font(.headline)
                StrataSearchField(theme: theme, text: $query,
                                  configuration: try! .init(label: "Search exercises",
                                                             placeholder: "Find an exercise",
                                                             clearLabel: "Clear search",
                                                             resultSummary: "12 results"),
                                  onClear: { clearCount += 1 })
                    .accessibilityIdentifier("populated-search")
                StrataSearchField(theme: theme, text: $empty,
                                  configuration: try! .init(label: "Empty search",
                                                             placeholder: "Find an exercise",
                                                             clearLabel: "Clear search",
                                                             validationMessage: "Enter at least 2 characters"))
                    .accessibilityIdentifier("error-search")
                StrataSearchField(theme: theme, text: .constant("Unavailable"),
                                  configuration: try! .init(label: "Disabled search",
                                                             clearLabel: "Clear search",
                                                             isDisabled: true))
                    .accessibilityIdentifier("disabled-search")
                HStack {
                    StrataNumberSlot(theme: theme, configuration: try! .init(label: "Left weight",
                                                                              displayValue: "20",
                                                                              prefixBadge: "L",
                                                                              unitLabel: "kg",
                                                                              isActive: true), action: {})
                    StrataNumberSlot(theme: theme, configuration: try! .init(label: "Right weight",
                                                                              displayValue: "",
                                                                              prefixBadge: "R",
                                                                              unitLabel: "kg",
                                                                              isInvalid: true), action: {})
                    StrataNumberSlot(theme: theme, configuration: try! .init(label: "Completed weight",
                                                                              displayValue: "18",
                                                                              unitLabel: "kg",
                                                                              isCompleted: true), action: {})
                    StrataNumberSlot(theme: theme, configuration: try! .init(label: "Disabled weight",
                                                                              displayValue: "60",
                                                                              unitLabel: "kg",
                                                                              isDisabled: true), action: {})
                }
                Text("Clears: \(clearCount)")
                    .accessibilityIdentifier("clear-count")
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(theme.foreground)
        .background(theme.canvas, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("review-\(configuration.brand)-\(configuration.mode)")
    }
}
