import NativeDesignKit
import SwiftUI

struct TextFieldReviewBoard: View {
    let r: FixtureResources
    let config: FixtureConfiguration
    @State private var empty = ""
    @State private var filled = "Studio Notes"
    @State private var longName = "用于长文本输入和中文排版验证的文稿名称，可以移动光标继续编辑完整标题"
    @State private var documentTitle = ""
    @State private var needsTitle = false
    @State private var result = "Not submitted"
    @FocusState private var focusedField: ReviewField?

    private let titleHelp = "Enter a title, then press Return to submit."
    private let titleError = "Title is empty. Enter a title, then press Return."

    var body: some View {
        VStack(alignment: .leading, spacing: r.gap) {
            ReviewSection(title: "Editing", r: r) {
                labeledField("Name", id: "empty") {
                    NativeTextField("Example: Studio Notes", text: $empty,
                        theme: r.theme, metrics: r.reviewMetrics)
                        .accessibilityLabel(Text("Name"))
                        .accessibilityIdentifier("review-field-empty")
                        .focused($focusedField, equals: .empty)
                        .onTapGesture { focusedField = .empty }
                }
                Text("Use a short, recognizable name.")
                    .nativeTypography(r.caption).foregroundColor(r.secondary)
                    .nativeGrowingText().accessibilityIdentifier("review-field-helper")
                labeledField("Display Name", id: "filled") {
                    NativeTextField("Example: Studio Notes", text: $filled,
                        theme: r.theme, metrics: r.reviewMetrics)
                        .accessibilityLabel(Text("Display Name"))
                        .accessibilityIdentifier("review-field-filled")
                        .focused($focusedField, equals: .filled)
                        .onTapGesture { focusedField = .filled }
                }
                labeledField("Unavailable Name", id: "disabled") {
                    NativeTextField("Unavailable name", text: .constant("Read Only"),
                        theme: r.theme, metrics: r.reviewMetrics)
                        .disabled(true)
                        .accessibilityLabel(Text("Unavailable Name"))
                        .accessibilityIdentifier("review-field-disabled")
                }
            }

            ReviewSection(title: "Document title", r: r) {
                labeledField("Title", id: "context") {
                    NativeTextField("Example: Draft", text: $documentTitle,
                        theme: r.theme, metrics: r.reviewMetrics)
                        .focused($focusedField, equals: .context)
                        .onTapGesture { focusedField = .context }
                        .submitLabel(.done)
                        .onSubmit(submitTitle)
                        .accessibilityLabel(Text("Title"))
                        .accessibilityHint(Text(needsTitle ? titleError : titleHelp))
                        .accessibilityIdentifier("review-field-context")
                }
                titleMessage
                Text(result).nativeTypography(r.caption).nativeGrowingText()
                    .foregroundColor(r.secondary)
                    .accessibilityIdentifier("review-field-result")
            }

            ReviewSection(title: "Long text and growing labels", r: r) {
                labeledField("文稿名称（保留完整标题，便于稍后识别和查找）", id: "long") {
                    NativeTextField("输入文稿名称", text: $longName,
                        theme: r.theme, metrics: r.reviewMetrics)
                        .accessibilityLabel(Text("文稿名称（保留完整标题，便于稍后识别和查找）"))
                        .accessibilityIdentifier("review-field-long")
                        .focused($focusedField, equals: .long)
                        .onTapGesture { focusedField = .long }
                }
                Text("移动光标可编辑完整名称；输入框使用原生单行横向滚动。")
                    .nativeTypography(r.caption).foregroundColor(r.secondary)
                    .nativeGrowingText().accessibilityIdentifier("review-field-long-helper")
            }
        }
        .controlSize(.regular)
    }

    private func labeledField<Content: View>(_ label: String, id: String,
                                             @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: r.reviewMetrics.spacing) {
            Text(label).nativeGrowingText()
                .accessibilityIdentifier("review-field-\(id)-label")
            content()
        }
    }

    private var titleMessage: some View {
        // Measure both actual strings at the current width and text size. The
        // invisible copies reserve geometry; the visible message stays accessible.
        ZStack(alignment: .topLeading) {
            ZStack(alignment: .topLeading) {
                Text(titleHelp).nativeGrowingText()
                Label(titleError, systemImage: "exclamationmark.circle.fill")
                    .nativeGrowingText()
            }
            .hidden().accessibilityHidden(true)
            if needsTitle {
                Label(titleError, systemImage: "exclamationmark.circle.fill")
                    .nativeGrowingText().foregroundColor(r.primary)
                    .accessibilityIdentifier("review-field-context-error")
            } else {
                Text(titleHelp).nativeGrowingText().foregroundColor(r.secondary)
                    .accessibilityIdentifier("review-field-context-helper")
            }
        }
        .nativeTypography(r.caption)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func submitTitle() {
        guard !documentTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            needsTitle = true
            result = "Not submitted"
            focusedField = .context
            return
        }
        needsTitle = false
        result = "Submitted: \(documentTitle)"
    }
}

private enum ReviewField: Hashable {
    case empty, filled, context, long
}
