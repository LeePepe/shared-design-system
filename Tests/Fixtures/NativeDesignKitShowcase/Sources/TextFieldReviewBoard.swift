import NativeDesignKit
import SwiftUI

struct TextFieldReviewBoard: View {
    let r: FixtureResources
    let config: FixtureConfiguration
    @State private var empty = ""
    @State private var filled = "Studio Notes"
    var body: some View {
        ReviewSection(title: "Document", r: r) {
            Text("Name")
            NativeTextField("Document name", text: $empty, theme: r.theme, metrics: r.reviewMetrics)
            Text("Display Name")
            NativeTextField("Display name", text: $filled, theme: r.theme, metrics: r.reviewMetrics)
            NativeTextField("Unavailable", text: .constant("Read Only"), theme: r.theme, metrics: r.reviewMetrics).disabled(true)
            NativeTextField("名称", text: .constant("用于长文本输入和中文排版验证的文稿名称"), theme: r.theme, metrics: r.reviewMetrics)
        }
    }
}
