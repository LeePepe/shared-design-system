import Strata
import SwiftUI

@main
struct AvatarReviewApp: App {
    private let configuration = Result { try AvatarConfiguration() }
    var body: some Scene {
        WindowGroup {
            switch configuration {
            case .success(let configuration):
                AvatarReviewBoard(configuration: configuration)
                    .preferredColorScheme(configuration.dark ? .dark : .light)
            case .failure(let error):
                Text(String(describing: error)).accessibilityIdentifier("fixture-error").padding()
            }
        }
    }
}

private struct AvatarConfiguration {
    enum ConfigurationError: Error { case missing(String), invalid(String) }
    let theme: StrataTheme
    let brand: String
    let mode: String
    let scenario: String
    let textSize: DynamicTypeSize
    var dark: Bool { mode == "dark" }

    init() throws {
        let environment = ProcessInfo.processInfo.environment
        func required(_ key: String) throws -> String {
            guard let value = environment[key], !value.isEmpty else { throw ConfigurationError.missing(key) }
            return value
        }
        brand = try required("NDK_BRAND")
        mode = try required("NDK_THEME")
        scenario = try required("NDK_SCENARIO")
        guard ["matrix", "narrow", "clipping", "composition"].contains(scenario) else {
            throw ConfigurationError.invalid("NDK_SCENARIO")
        }
        switch mode {
        case "light": theme = try StrataTheme(theme: .light, brand: brand)
        case "dark": theme = try StrataTheme(theme: .dark, brand: brand)
        default: throw ConfigurationError.invalid("NDK_THEME")
        }
        switch try required("NDK_TEXT_SIZE") {
        case "large": textSize = .large
        case "accessibility2": textSize = .accessibility2
        case "accessibility5": textSize = .accessibility5
        default: throw ConfigurationError.invalid("NDK_TEXT_SIZE")
        }
    }
}

private struct AvatarReviewBoard: View {
    let configuration: AvatarConfiguration
    @State private var actionCount = 0
    @State private var disabled = false
    @State private var alternative = false
    private let sizes = ["small", "medium", "large"]
    private var theme: StrataTheme { configuration.theme }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Strata Avatar").font(.title.bold())
                Text("\(configuration.brand.capitalized) · \(configuration.mode.capitalized) · iOS SwiftUI")
                    .font(.subheadline).foregroundStyle(theme.secondaryForeground)
                switch configuration.scenario {
                case "matrix": matrix
                case "narrow": narrow
                case "clipping": clipping
                default: composition
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityIdentifier("review-scroll")
        .foregroundStyle(theme.foreground)
        .background(theme.canvas.ignoresSafeArea())
        .dynamicTypeSize(.large)
    }

    private var matrix: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 0) {
                Text("Caller visual").frame(width: 104, alignment: .leading)
                ForEach([32, 44, 64], id: \.self) { diameter in Text("\(diameter) pt").frame(width: 76) }
            }.font(.caption).foregroundStyle(theme.secondaryForeground)
            ForEach(["initials", "symbol", "fill", "fit", "empty", "disabled"], id: \.self) { kind in
                HStack(spacing: 0) {
                    Text(rowTitle(kind)).font(.caption).frame(width: 104, alignment: .leading)
                    ForEach(sizes, id: \.self) { size in avatar(kind: kind, size: size).frame(width: 76) }
                }.frame(height: 64)
            }
            Text("Synthetic visuals · full labels supplied by caller")
                .font(.caption).foregroundStyle(theme.secondaryForeground).accessibilityIdentifier("matrix-end")
        }
    }

    private func avatar(kind: String, size: String) -> some View {
        StrataAvatar(theme: theme, size: avatarSize(size),
                     accessibilityLabel: Text(verbatim: "\(rowTitle(kind)), \(size) example visual")) {
            switch kind {
            case "symbol": Image(systemName: "person.fill").accessibilityLabel("Redundant symbol glyph")
            case "fill": artwork.resizable().scaledToFill().accessibilityLabel("Redundant image glyph")
            case "fit": artwork.resizable().scaledToFit().accessibilityLabel("Redundant image glyph")
            case "empty": EmptyView()
            default: Text("AB").accessibilityLabel("Redundant initials glyph")
            }
        }
        .disabled(kind == "disabled")
        .accessibilityIdentifier("avatar-\(kind)-\(size)")
    }

    private var artwork: Image { Image("Artwork").renderingMode(.template) }

    private var narrow: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("280 pt · caller text outside the circle").font(.headline)
            HStack(alignment: .top, spacing: 12) {
                StrataAvatar(theme: theme, size: .small, accessibilityLabel: Text("Example member with a full accessible name")) {
                    Text("AB")
                }.accessibilityIdentifier("narrow-avatar")
                Text("Example member with a long display name that wraps naturally beside a small avatar.")
                    .font(.body).fixedSize(horizontal: false, vertical: true).accessibilityIdentifier("long-label")
            }
            HStack(spacing: 20) {
                ForEach(sizes, id: \.self) { size in
                    StrataAvatar(theme: theme, size: avatarSize(size), accessibilityLabel: Text(verbatim: "\(size) scalable visual")) {
                        Text("AB")
                    }.accessibilityIdentifier("scalable-\(size)")
                }
            }
            Text("Fixed visual bounds · semantic fonts · complete accessible names")
                .font(.caption).foregroundStyle(theme.secondaryForeground).accessibilityIdentifier("narrow-end")
        }
        .environment(\.dynamicTypeSize, configuration.textSize)
        .frame(width: 280, alignment: .leading)
    }

    private var clipping: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Oversized caller content must stay circular").font(.headline)
            HStack(spacing: 16) {
                VStack {
                    StrataAvatar(theme: theme, size: .large, accessibilityLabel: Text("Clipped oversized visual")) {
                        Rectangle().fill(theme.accent).frame(width: 200, height: 120)
                    }
                }
                .frame(width: 88, height: 88).background(theme.canvas)
                .contentShape(Rectangle())
                .accessibilityElement(children: .contain).accessibilityIdentifier("clipping-actual")
                VStack {
                    Circle().fill(theme.accent).frame(width: 64, height: 64).accessibilityLabel("Circular reference")
                }
                .frame(width: 88, height: 88).background(theme.canvas)
                .contentShape(Rectangle())
                .accessibilityElement(children: .contain).accessibilityIdentifier("clipping-reference")
            }
            Text("Actual avatar / circular reference · same token color and background")
                .font(.caption).foregroundStyle(theme.secondaryForeground).accessibilityIdentifier("clipping-end")
        }
    }

    private var composition: some View {
        VStack(alignment: .leading, spacing: 20) {
            StrataAvatar(theme: theme, size: .medium, accessibilityLabel: Text(alternative ? "Changed example visual" : "Original example visual")) {
                Text(alternative ? "CD" : "AB")
            }.accessibilityIdentifier("caller-owned-avatar")
            Button { actionCount += 1 } label: {
                StrataAvatar(theme: theme, size: .small, accessibilityLabel: Text("Example member")) {
                    Image(systemName: "person.fill")
                }
                .padding(6).frame(minWidth: 44, minHeight: 44).contentShape(Rectangle())
            }
            .buttonStyle(.plain).disabled(disabled)
            .accessibilityLabel("Open example member").accessibilityIdentifier("composed-action")
            Text("Actions: \(actionCount)").accessibilityIdentifier("action-count")
            Button("Change fixture visual") { alternative.toggle() }.accessibilityIdentifier("change-content")
            Button(disabled ? "Enable wrapper" : "Disable wrapper") { disabled.toggle() }.accessibilityIdentifier("toggle-disabled")
        }.buttonStyle(.bordered)
    }

    private func avatarSize(_ name: String) -> StrataAvatarSize {
        switch name {
        case "small": .small
        case "medium": .medium
        default: .large
        }
    }

    private func rowTitle(_ kind: String) -> String {
        switch kind {
        case "initials": "Initials"
        case "symbol": "SF Symbol"
        case "fill": "Local image fill"
        case "fit": "Local image fit"
        case "empty": "Empty visual"
        default: "Disabled env."
        }
    }
}
