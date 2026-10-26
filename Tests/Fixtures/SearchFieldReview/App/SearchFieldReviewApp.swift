import Strata
import SwiftUI

@main
struct SearchFieldReviewApp: App {
    var body: some Scene {
        WindowGroup {
            SearchFieldReviewMatrix()
        }
    }
}

private struct SearchFieldReviewMatrix: View {
    private struct Combination: Identifiable {
        let brand: String
        let mode: String
        var id: String { "\(brand)-\(mode)" }
    }

    private let combinations = [
        Combination(brand: "ocean", mode: "light"),
        Combination(brand: "ocean", mode: "dark"),
        Combination(brand: "graphite", mode: "light"),
        Combination(brand: "graphite", mode: "dark")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Search and number slots").font(.title.bold())
                ForEach(combinations) { combination in
                    SearchFieldReviewBoard(mode: combination.mode, brand: combination.brand)
                }
            }
            .padding(16)
        }
    }
}

private struct SearchFieldReviewBoard: View {
    let mode: String
    let brand: String
    @State private var query = "Squat"
    @State private var empty = ""
    @State private var clearCount = 0

    private var theme: StrataTheme {
        try! StrataTheme(theme: mode == "dark" ? .dark : .light,
                         brand: brand == "graphite" ? "graphite" : "ocean")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("\(brand.capitalized) \(mode.capitalized)")
                .font(.headline)
            StrataSearchField(theme: theme, text: $query,
                              configuration: try! .init(label: "Search exercises \(brand) \(mode)",
                                                         placeholder: "Find an exercise",
                                                         clearLabel: "Clear search",
                                                         resultSummary: "12 results"),
                              onClear: { clearCount += 1 })
                .accessibilityIdentifier("populated-search-\(brand)-\(mode)")
            StrataSearchField(theme: theme, text: $empty,
                              configuration: try! .init(label: "Empty search \(brand) \(mode)",
                                                         placeholder: "Find an exercise",
                                                         clearLabel: "Clear search",
                                                         validationMessage: ""))
                .accessibilityIdentifier("empty-search-\(brand)-\(mode)")
            StrataSearchField(theme: theme, text: .constant("Unavailable"),
                              configuration: try! .init(label: "Disabled search \(brand) \(mode)",
                                                         clearLabel: "Clear search",
                                                         isDisabled: true))
                .accessibilityIdentifier("disabled-search-\(brand)-\(mode)")
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
            }
            Text("Clears: \(brand.capitalized) \(mode.capitalized): \(clearCount)")
                .accessibilityIdentifier("clear-count-\(brand)-\(mode)")
        }
        .padding(12)
        .foregroundStyle(theme.foreground)
        .background(theme.canvas, in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("review-\(brand)-\(mode)")
    }
}
