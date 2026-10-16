import NativeDesignKit
import SwiftUI

/// Component-scoped native review, separate from the retained full catalog.
struct ReviewOrCatalog: View {
    let resources: FixtureResources
    let config: FixtureConfiguration
    var body: some View {
        if ["Button", "Toggle", "TextField"].contains(config.page) {
            ComponentReview(resources: resources, config: config)
        } else {
            Catalog(resources: resources, config: config)
        }
    }
}

struct ComponentReview: View {
    let resources: FixtureResources
    let config: FixtureConfiguration
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: resources.gap) {
                HStack {
                    Text(config.page).nativeTypography(resources.heading)
                    Spacer()
                    Text(config.dark ? "Dark" : "Light").nativeTypography(resources.caption)
                        .foregroundColor(resources.secondary)
                }
                .accessibilityIdentifier("component-heading")
                if config.page == "Button" { ButtonReviewBoard(r: resources, config: config) }
                if config.page == "Toggle" { ToggleReviewBoard(r: resources, config: config) }
                if config.page == "TextField" { TextFieldReviewBoard(r: resources, config: config) }
            }.padding(resources.padding).frame(maxWidth: .infinity, alignment: .leading)
        }.background(resources.canvas).foregroundColor(resources.primary)
            .nativeTypography(resources.body).accessibilityIdentifier("component-review")
    }
}

struct ReviewSection<Content: View>: View {
    let title: String
    let r: FixtureResources
    @ViewBuilder var content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: r.gap) {
            Text(title).nativeTypography(r.caption).foregroundColor(r.secondary)
            content()
        }.padding(r.gap).frame(maxWidth: .infinity, alignment: .leading)
            .background(r.raised)
            .clipShape(RoundedRectangle(cornerRadius: r.reviewMetrics.cornerRadius))
    }
}
