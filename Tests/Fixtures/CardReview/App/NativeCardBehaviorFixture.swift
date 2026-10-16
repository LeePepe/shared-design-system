@testable import NativeDesignKit
import SwiftUI

/// Only this internal behavior fixture accesses the nil-default test preference.
/// The public-import construction tests remain independent of internal symbols.
struct NativeCardBehaviorFixture: View {
    let configuration: CardReviewConfiguration
    @State private var activations = 0
    private var theme: NativeDesignTheme { configuration.theme }
    private var isLong: Bool { configuration.scenario == "long" }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Native Card").font(.title.bold())
                Text("\(configuration.brand.capitalized) · \(configuration.mode.capitalized) · synthetic content")
                    .font(.subheadline).foregroundStyle(theme.secondaryForeground)
                Text(surfaceDescription)
                    .font(.subheadline)
                    .frame(height: 40, alignment: .topLeading)
                cardRegion
                Text("Actions: \(activations)").accessibilityIdentifier("action-count")
                Text("Preference forced through an internal fixture input. Production follows the system.\(configuration.textSize == .accessibility3 ? " Dynamic Type: accessibility3." : "")")
                    .font(.footnote).foregroundStyle(theme.secondaryForeground)
                    .accessibilityIdentifier("fixture-note")
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityIdentifier("review-scroll")
        .foregroundStyle(theme.foreground)
        .background(theme.canvas.ignoresSafeArea())
        .dynamicTypeSize(.large)
    }

    private var cardRegion: some View {
        VStack(spacing: 0) {
            reviewedCard
                .frame(width: 320)
                .environment(\.dynamicTypeSize, configuration.textSize)
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("review-card")
        }
        .padding(16)
        .nativeSurface(theme: theme, style: configuration.surface, cornerRadius: 32, role: .region)
        .environment(\.nativeReduceTransparencyOverride,
                     configuration.systemTransparency ? nil : configuration.reduceTransparency)
        .background(alignment: .trailing) {
            // Preserve the original token-colored backdrop. The outer region
            // supplies the one blur; Card remains the dense reading plane.
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.accent.opacity(0.35))
                .frame(width: 90)
                .padding(.vertical, 12)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("review-region")
    }

    @ViewBuilder
    private var reviewedCard: some View {
        switch configuration.scenario {
        case "content-only":
            NativeCard(theme: theme, surface: configuration.surface) {
                Text("Only content").accessibilityIdentifier("card-body")
            }
        case "empty-slots":
            NativeCard(theme: theme, surface: configuration.surface) {
                EmptyView()
            } content: {
                Text("Only content").accessibilityIdentifier("card-body")
            } supporting: {
                EmptyView()
            } actions: {
                EmptyView()
            }
        default:
            NativeCard(theme: theme, surface: configuration.surface) {
                Text(isLong ? "A longer title remains clear as the available width narrows" : "A clear place to begin")
                    .accessibilityIdentifier("card-title")
            } content: {
                Text(isLong
                     ? "This deliberately long sample explains the content without truncation. It stays in reading order, wraps at the proposed width and lets the card grow. No product data, formatting or navigation is owned by the component."
                     : "A quiet surface keeps caller-owned content in focus.")
                    .accessibilityIdentifier("card-body")
            } supporting: {
                Text(isLong
                     ? "Supporting context uses a separate semantic text style. This is synthetic content for layout validation."
                     : "Synthetic example · no business meaning")
                    .accessibilityIdentifier("card-supporting")
            } actions: {
                VStack(alignment: .leading, spacing: 0) {
                    Button { activations += 1 } label: {
                        Text("Continue").frame(minHeight: 44).contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("card-action")
                    Button { activations += 100 } label: {
                        Text("Unavailable action").frame(minHeight: 44).contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(true)
                    .accessibilityIdentifier("card-disabled-action")
                }
            }
        }
    }

    private var surfaceDescription: String {
        if configuration.surface == .solid { return "Solid · Reduce Transparency \(configuration.reduceTransparency ? "on" : "off")" }
        return configuration.reduceTransparency
            ? "Glass → solid · Reduce Transparency on"
            : "Glass · Reduce Transparency off"
    }
}
