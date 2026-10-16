import NativeDesignKit
import SwiftUI

struct ToggleReviewBoard: View {
    let r: FixtureResources
    let config: FixtureConfiguration
    @State private var enabled = true
    @State private var off = false
    var body: some View {
        ReviewSection(title: "Preferences", r: r) {
            NativeToggle(isOn: $enabled, theme: r.theme, metrics: r.reviewMetrics) { Text("Keep Changes") }
            NativeToggle(isOn: $off, theme: r.theme, metrics: r.reviewMetrics) { Text("Include Details") }
            NativeToggle(isOn: .constant(true), theme: r.theme, metrics: r.reviewMetrics) { Text("Unavailable") }.disabled(true)
            NativeToggle(isOn: .constant(false), theme: r.theme, metrics: r.reviewMetrics) {
                Text("在所有设备上保留本次修改，并在下次打开时恢复这些选项")
            }
        }
    }
}
