import NativeDesignKit
import SwiftUI

struct ButtonReviewBoard: View {
    let r: FixtureResources
    let config: FixtureConfiguration
    @State private var count = 0
    var body: some View {
        ReviewSection(title: "Actions", r: r) {
            ForEach(NativeButtonPresentation.allCases, id: \.self) { style in
                NativeButton(theme: r.theme, metrics: r.reviewMetrics, presentation: style == .glass && !config.allowsGlass ? .bordered : style,
                    isLoading: false, loadingLabel: Text("Saving"), action: { count += 1 }) {
                    Text("Save Changes")
                }
            }
            NativeButton(theme: r.theme, metrics: r.reviewMetrics, presentation: .prominent,
                isLoading: true, loadingLabel: Text("Saving"), action: {}) { Text("Save Changes") }
            NativeButton(theme: r.theme, metrics: r.reviewMetrics, presentation: .bordered,
                isLoading: false, loadingLabel: Text("Saving"), action: {}) { Text("Save Changes") }.disabled(true)
            Text("Actions: \(count)")
        }
    }
}
