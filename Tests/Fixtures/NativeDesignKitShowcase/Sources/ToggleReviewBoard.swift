import NativeDesignKit
import SwiftUI

/// Live native switches. The system owns press, pointer and keyboard feedback.
struct ToggleReviewBoard: View {
    let r: FixtureResources
    let config: FixtureConfiguration
    @State private var on = true
    @State private var off = false
    @State private var includeDetails = false
    @State private var retainOptions = false

    var body: some View {
        VStack(alignment: .leading, spacing: r.gap) {
            ReviewSection(title: "States", r: r) {
                row("Keep Changes", helper: "Starts on. Available to change.",
                    isOn: $on, identifier: "review-toggle-on")
                row("Include Notes", helper: "Starts off. Available to change.",
                    isOn: $off, identifier: "review-toggle-off")
                row("Restore Options", helper: "On and unavailable in this sample.",
                    isOn: .constant(true), identifier: "review-toggle-disabled-on")
                    .disabled(true)
                row("Share Options", helper: "Off and unavailable in this sample.",
                    isOn: .constant(false), identifier: "review-toggle-disabled-off")
                    .disabled(true)
            }

            ReviewSection(title: "Sample preferences", r: r) {
                row("Include Details", helper: "Add optional details to the sample copy.",
                    isOn: $includeDetails, identifier: "review-toggle-context")
                Text(includeDetails ? "Details included" : "Details excluded")
                    .nativeTypography(r.caption).foregroundColor(r.secondary)
                    .nativeGrowingText().accessibilityIdentifier("review-toggle-result")
            }

            ReviewSection(title: "Long label", r: r) {
                row("在所有设备上保留本次修改，并在下次打开时恢复这些选项",
                    helper: "仅用于检查长标签与大字体的换行。",
                    isOn: $retainOptions, identifier: "review-toggle-long")
            }
        }
        .controlSize(.regular)
    }

    private func row(_ title: String, helper: String, isOn: Binding<Bool>,
                     identifier: String) -> some View {
        NativeToggle(isOn: isOn, theme: r.theme, metrics: r.reviewMetrics) {
            VStack(alignment: .leading, spacing: r.reviewMetrics.spacing) {
                Text(title).nativeTypography(r.reviewBody).nativeGrowingText()
                Text(helper).nativeTypography(r.caption).foregroundColor(r.secondary)
                    .nativeGrowingText()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text(helper))
        .accessibilityIdentifier(identifier)
        .help(helper)
    }
}
