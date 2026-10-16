import SwiftUI

@main
struct ShowcaseApp: App {
    private let config = FixtureConfiguration()
    var body: some Scene {
        WindowGroup {
            FixtureEntry(config: config)
                #if os(macOS)
                .frame(width: config.narrow ? 480 : 1120, height: 850)
                #endif
        }
    }
}
