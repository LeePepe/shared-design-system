import NativeDesignKit
import SwiftUI

/// Live native controls. Pointer, keyboard focus and pressed states are never simulated.
struct ButtonReviewBoard: View {
    let r: FixtureResources
    let config: FixtureConfiguration
    @State private var count = 0
    @State private var isSaving = false
    @State private var result = "No changes saved"
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        VStack(alignment: .leading, spacing: r.gap) {
            ReviewSection(title: "Styles", r: r) {
                NativeFlow(items: ButtonExample.allCases, horizontalSpacing: r.gap,
                           verticalSpacing: r.gap) { example in
                    NativeButton(theme: r.theme, metrics: r.reviewMetrics,
                        presentation: example.presentation, isLoading: false,
                        loadingLabel: Text("Saving"), action: recordAction) {
                        if example == .icon {
                            Image(systemName: "plus")
                                .frame(width: r.reviewMetrics.iconSize, height: r.reviewMetrics.iconSize)
                        } else {
                            Text(example.title).nativeGrowingText()
                        }
                    }
                    .accessibilityLabel(Text(example.title))
                    .accessibilityIdentifier(example.identifier)
                    .help(example.title)
                }
            }

            ReviewSection(title: "Availability and progress", r: r) {
                NativeButton(theme: r.theme, metrics: r.reviewMetrics, presentation: .bordered,
                    isLoading: false, loadingLabel: Text("Saving"), action: recordAction) {
                    Text("Save Changes").nativeGrowingText()
                }
                .disabled(true).accessibilityIdentifier("review-disabled")
                NativeButton(theme: r.theme, metrics: r.reviewMetrics, presentation: .bordered,
                    isLoading: true, loadingLabel: Text("Saving changes"), action: recordAction) {
                    Text("Save Changes").nativeGrowingText()
                }
                .accessibilityIdentifier("review-loading")
                NativeButton(theme: r.theme, metrics: r.reviewMetrics, presentation: .bordered,
                    isLoading: isSaving, loadingLabel: Text("Saving a copy"), action: startSaving) {
                    Text("Save a Copy").nativeGrowingText()
                }
                .accessibilityIdentifier("review-start-loading")
                Text(result).nativeTypography(r.caption).foregroundColor(r.secondary)
                    .nativeGrowingText().accessibilityIdentifier("review-result")
                Text("Actions: \(count)").nativeTypography(r.caption)
                    .accessibilityIdentifier("review-count")
            }

            ReviewSection(title: "Roles", r: r) {
                NativeButton(theme: r.theme, metrics: r.reviewMetrics, presentation: .bordered,
                    role: .cancel, isLoading: false, loadingLabel: Text("Cancelling"), action: {
                        count += 1
                        result = "Changes cancelled"
                    }) {
                    Text("Cancel").nativeGrowingText()
                }
                .accessibilityIdentifier("review-cancel")
                NativeButton(theme: r.theme, metrics: r.reviewMetrics, presentation: .bordered,
                    role: .destructive, isLoading: false, loadingLabel: Text("Deleting"), action: {
                        count += 1
                        result = "Sample copy deleted"
                    }) {
                    Label("Delete Copy", systemImage: "trash").nativeGrowingText()
                }
                .accessibilityIdentifier("review-delete")
            }

            ReviewSection(title: glassCaption, r: r) {
                VStack(alignment: .leading, spacing: r.reviewMetrics.spacing) {
                    Text("Project notes").nativeTypography(r.heading)
                    Text("Keep the original draft. Review the title and summary before sharing a copy.")
                        .nativeGrowingText()
                    Text("Next step: prepare the document for review.")
                        .nativeGrowingText()
                    Text("The original remains available in the document list.")
                        .nativeGrowingText()
                }
                .padding(r.padding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(r.canvas)
                .overlay(alignment: .bottomTrailing) {
                    NativeButton(theme: r.theme, metrics: r.reviewMetrics,
                        presentation: config.allowsGlass ? .glass : .bordered,
                        isLoading: false, loadingLabel: Text("Adding note"), action: recordAction) {
                        Label("Add Note", systemImage: "square.and.pencil").nativeGrowingText()
                    }
                    .accessibilityIdentifier("review-glass")
                    .padding(r.gap)
                }
            }

            ReviewSection(title: "Localized document action", r: r) {
                Text("文稿副本").nativeTypography(r.heading)
                Text("保留原稿，并创建一份供稍后审阅的副本。")
                    .nativeGrowingText().foregroundColor(r.secondary)
                NativeButton(theme: r.theme, metrics: r.reviewMetrics, presentation: .bordered,
                    isLoading: false, loadingLabel: Text("正在保存文稿副本"), action: recordAction) {
                    Text("保存这份包含较长名称的文稿副本").nativeGrowingText()
                }
                .accessibilityIdentifier("review-localized")
            }
        }
        .controlSize(.regular)
        .task(id: isSaving) {
            guard isSaving else { return }
            do {
                try await Task.sleep(nanoseconds: 1_500_000_000)
                try Task.checkCancellation()
                result = "Copy saved"
                isSaving = false
            } catch {
                // A removed review board owns no surviving work or result publication.
            }
        }
    }

    private var glassCaption: String {
        #if compiler(>=6.2)
        if #available(iOS 26, macOS 26, *), !reduceTransparency, config.allowsGlass {
            return "Floating native Glass control"
        }
        #endif
        return "Floating control, bordered fallback"
    }

    private func recordAction() {
        count += 1
        result = "Changes saved"
    }

    private func startSaving() {
        guard !isSaving else { return }
        count += 1
        result = "Saving a copy…"
        isSaving = true
    }
}

private enum ButtonExample: String, CaseIterable, Identifiable {
    case prominent, secondary, plain, icon

    var id: Self { self }
    var identifier: String {
        switch self {
        case .prominent: return "review-save"
        case .secondary: return "review-secondary"
        case .plain: return "review-plain"
        case .icon: return "review-icon"
        }
    }
    var title: String {
        switch self {
        case .prominent: return "Save Changes"
        case .secondary: return "Duplicate"
        case .plain: return "Show Details"
        case .icon: return "Add Note"
        }
    }
    var presentation: NativeButtonPresentation {
        switch self {
        case .prominent: return .prominent
        case .secondary: return .bordered
        case .plain, .icon: return .plain
        }
    }
}
