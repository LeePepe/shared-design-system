import DesignTokens
@testable import NativeDesignKit
import SwiftUI

@main
struct FoundationReviewApp: App {
    let theme: NativeDesignTheme
    let surface: NativeSurfaceStyle
    let reduceTransparency: Bool

    init() {
        let args = ProcessInfo.processInfo.arguments
        func value(_ flag: String) -> String {
            guard let i = args.firstIndex(of: flag), args.indices.contains(i + 1) else {
                fatalError("Explicit specimen argument required: \(flag)")
            }
            return args[i + 1]
        }
        guard let mode = Theme(rawValue: value("--mode")) else { fatalError("Invalid explicit mode") }
        let material = value("--surface")
        guard ["glass", "solid"].contains(material) else { fatalError("Invalid explicit surface") }
        surface = material == "glass" ? .glass : .solid
        reduceTransparency = args.contains("--reduce-transparency")
        do { theme = try NativeDesignTheme(theme: mode, brand: value("--brand")) }
        catch { fatalError("Provider resolution failed: \(error)") }
    }

    var body: some Scene {
        WindowGroup {
            StrataSpecimen(theme: theme, surface: surface, title: "A quiet reading plane") {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "square.stack.3d.up")
                            .font(.title3)
                            .foregroundStyle(theme.brandText)
                            .frame(width: 44, height: 44)
                            .background(theme.accentSubtle, in: RoundedRectangle(cornerRadius: 16))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Layered, calm, clear").font(.headline)
                            Text("Synthetic example").font(.subheadline).foregroundStyle(theme.secondaryForeground)
                        }
                    }
                    Text("A denser inner surface keeps reading comfortable while the outer shell carries the glass.")
                        .font(.body)
                    Text("Surface hierarchy stays the same in each palette.")
                        .font(.subheadline).foregroundStyle(theme.secondaryForeground)
                    HStack {
                        Text("Updated just now").font(.caption).foregroundStyle(theme.secondaryForeground)
                        Spacer()
                        Text("View details →").font(.subheadline.weight(.semibold)).foregroundStyle(theme.brandText)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .nativeSurface(theme: theme, style: surface, cornerRadius: 24, role: .card)
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(theme.surface(index == 0 ? .inset : index == 1 ? .hover : .selected))
                            .frame(height: 44)
                            .overlay {
                                Text(["Inset", "Hover", "Selected"][index])
                                    .font(.caption).foregroundStyle(theme.secondaryForeground)
                            }
                    }
                }
                HStack(spacing: 12) {
                    Circle().fill(theme.brandSeed).frame(width: 28, height: 28)
                    Text("One small accent").font(.subheadline).foregroundStyle(theme.brandText)
                }
            }
            .environment(\.nativeReduceTransparencyOverride, reduceTransparency)
        }
    }
}
