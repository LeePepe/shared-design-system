@testable import NativeDesignKit
import SwiftUI

/// Synthetic evidence composition; include this source explicitly in fixture targets.
struct StrataSpecimen<Content: View>: View {
    let theme: NativeDesignTheme
    let surface: NativeSurfaceStyle
    let title: String
    private let content: Content
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.nativeReduceTransparencyOverride) private var reduceTransparencyOverride

    init(theme: NativeDesignTheme, surface: NativeSurfaceStyle, title: String,
         @ViewBuilder content: () -> Content) {
        self.theme = theme; self.surface = surface; self.title = title; self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Strata · 岩层").font(.largeTitle.bold()).foregroundStyle(theme.foreground)
                VStack(alignment: .leading, spacing: 16) {
                    Text(title).font(.headline).foregroundStyle(theme.foreground)
                    content
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .nativeSurface(theme: theme, style: surface, cornerRadius: 32, role: .region)
            }
            .padding(16)
            .frame(maxWidth: 640, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .background {
            ZStack(alignment: .topLeading) {
                theme.canvas
                if surface == .glass && !(reduceTransparencyOverride ?? reduceTransparency) {
                    Ellipse()
                        .fill(theme.material.ambientSoft)
                        .frame(width: 360, height: 150)
                        .rotationEffect(.degrees(-24))
                        .offset(x: -90, y: 160)
                    Ellipse()
                        .stroke(theme.material.ambientEdge.opacity(0.65), lineWidth: 32)
                        .frame(width: 380, height: 180)
                        .rotationEffect(.degrees(-24))
                        .offset(x: -120, y: 145)
                }
            }
            .ignoresSafeArea()
        }
        .environment(\.colorScheme, theme.mode == .light ? .light : .dark)
    }
}
