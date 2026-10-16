import NativeDesignKit
import SwiftUI

/// Synthetic integration fixture. Configuration errors are visible, never replaced.
@main
struct CardReviewApp: App {
    private let configuration = Result { try CardReviewConfiguration() }

    var body: some Scene {
        WindowGroup {
            switch configuration {
            case .success(let configuration):
                NativeCardBehaviorFixture(configuration: configuration)
                    .preferredColorScheme(configuration.mode == "dark" ? .dark : .light)
            case .failure(let error):
                VStack(alignment: .leading, spacing: 16) {
                    Text("Fixture configuration failed").font(.title)
                    Text(String(describing: error)).accessibilityIdentifier("fixture-error")
                }
                .padding()
            }
        }
    }
}

struct CardReviewConfiguration {
    enum ConfigurationError: Error { case missing(String), invalid(String) }
    let theme: NativeDesignTheme
    let mode: String
    let brand: String
    let scenario: String
    let surface: NativeSurfaceStyle
    let reduceTransparency: Bool
    let textSize: DynamicTypeSize

    init() throws {
        let environment = ProcessInfo.processInfo.environment
        func required(_ name: String) throws -> String {
            guard let value = environment[name], !value.isEmpty else {
                throw ConfigurationError.missing(name)
            }
            return value
        }
        brand = try required("NDK_BRAND")
        mode = try required("NDK_THEME")
        switch mode {
        case "light": theme = try NativeDesignTheme(theme: .light, brand: brand)
        case "dark": theme = try NativeDesignTheme(theme: .dark, brand: brand)
        default: throw ConfigurationError.invalid("NDK_THEME")
        }
        scenario = try required("NDK_SCENARIO")
        guard ["four-slot", "long", "content-only", "empty-slots"].contains(scenario) else {
            throw ConfigurationError.invalid("NDK_SCENARIO")
        }
        switch try required("NDK_SURFACE") {
        case "solid": surface = .solid
        case "glass": surface = .glass
        default: throw ConfigurationError.invalid("NDK_SURFACE")
        }
        switch try required("NDK_REDUCE_TRANSPARENCY") {
        case "off": reduceTransparency = false
        case "on": reduceTransparency = true
        default: throw ConfigurationError.invalid("NDK_REDUCE_TRANSPARENCY")
        }
        switch try required("NDK_TEXT_SIZE") {
        case "large": textSize = .large
        case "accessibility3": textSize = .accessibility3
        default: throw ConfigurationError.invalid("NDK_TEXT_SIZE")
        }
    }
}
