@testable import NativeDesignKit
import SwiftUI

/// Caller-owned demonstration content, composed through the real Card and shared shell.
struct StrataCardSpecimen: View {
    let configuration: CardReviewConfiguration
    @State private var detailViews = 0
    @Environment(\.accessibilityReduceTransparency) private var systemReduceTransparency
    private var theme: NativeDesignTheme { configuration.theme }
    private var isLong: Bool { configuration.scenario == "specimen-long" }
    private var isAccessibilitySize: Bool { configuration.textSize.isAccessibilitySize }

    var body: some View {
        StrataSpecimen(theme: theme, surface: configuration.surface, title: "02  Card") {
            VStack(alignment: .leading, spacing: 12) {
                contentCard
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("specimen-content-card")
                statisticsCard
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("specimen-stat-card")
                Text(detailViews == 0
                     ? "Content and statistics are synthetic examples."
                     : "Details viewed: \(detailViews) · caller-owned action")
                    .font(.footnote)
                    .foregroundStyle(theme.secondaryForeground)
                    .accessibilityIdentifier("specimen-feedback")
                if configuration.systemTransparency {
                    Text("System Reduce Transparency: \(systemReduceTransparency ? "on" : "off")")
                        .font(.footnote)
                        .foregroundStyle(theme.secondaryForeground)
                        .accessibilityIdentifier("system-transparency")
                }
            }
        }
        .frame(maxWidth: isLong ? 328 : .infinity)
        .environment(\.nativeReduceTransparencyOverride,
                     configuration.systemTransparency ? nil : configuration.reduceTransparency)
        .environment(\.dynamicTypeSize, configuration.textSize)
        .accessibilityIdentifier("specimen-scroll")
        .background(theme.canvas.ignoresSafeArea())
    }

    private var contentCard: some View {
        NativeCard(theme: theme, surface: configuration.surface) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center, spacing: 12) {
                    Image(systemName: "square.3.layers.3d")
                        .font(.body)
                        .foregroundStyle(theme.brandText)
                        .frame(width: 44, height: 44)
                        .background(theme.accentSubtle, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .accessibilityHidden(true)
                    Spacer(minLength: 0)
                    contextPill("Example content", identifier: "specimen-context")
                }
                Text(isLong
                     ? "Let meaningful content emerge clearly as the available width narrows"
                     : "Let content emerge")
                    .accessibilityIdentifier("specimen-title")
            }
        } content: {
            Text(isLong
                 ? "Light and color pass through the outer surface while this denser reading plane keeps every sentence clear. This caller-owned example wraps naturally without truncation or a fixed card height."
                 : "Light and color pass through. Words stay clear, and layers fall into place.")
                .foregroundStyle(theme.secondaryForeground)
                .accessibilityIdentifier("specimen-body")
        } supporting: {
            EmptyView()
        } actions: {
            footer
        }
    }

    @ViewBuilder
    private var footer: some View {
        if isAccessibilitySize {
            VStack(alignment: .leading, spacing: 4) {
                footerLabel
                detailAction
            }
        } else {
            HStack(alignment: .center, spacing: 8) {
                footerLabel
                Spacer(minLength: 0)
                detailAction
            }
        }
    }

    private var footerLabel: some View {
        Text("Content card")
            .font(.subheadline)
            .foregroundStyle(theme.secondaryForeground)
            .accessibilityIdentifier("specimen-footer")
    }

    private var detailAction: some View {
        Button { detailViews += 1 } label: {
            HStack(spacing: 4) {
                Text("View details")
                Image(systemName: "arrow.right").accessibilityHidden(true)
            }
            .font(.subheadline.weight(.semibold))
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(CardDetailStyle(theme: theme))
        .accessibilityIdentifier("specimen-detail-action")
    }

    private var statisticsCard: some View {
        NativeCard(theme: theme, surface: configuration.surface) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Theme exploration")
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryForeground)
                    .accessibilityIdentifier("specimen-stat-title")
                Spacer(minLength: 0)
                contextPill("Synthetic data", identifier: "specimen-data-context")
            }
        } content: {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("72").font(.largeTitle.weight(.semibold)).monospacedDigit()
                        .accessibilityIdentifier("specimen-metric")
                    Text("%").font(.title3).foregroundStyle(theme.secondaryForeground)
                        .accessibilityIdentifier("specimen-percent")
                }
                GeometryReader { geometry in
                    Capsule().fill(theme.surface(.hover))
                        .overlay(alignment: .leading) {
                            Capsule().fill(theme.chartPrimary).frame(width: geometry.size.width * 0.72)
                        }
                }
                .frame(height: 8)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Synthetic exploration progress")
                .accessibilityValue("72 percent")
            }
        } supporting: {
            if isAccessibilitySize {
                VStack(alignment: .leading, spacing: 8) { statusPill; itemCount }
            } else {
                HStack(spacing: 8) { statusPill; Spacer(minLength: 0); itemCount }
            }
        } actions: {
            if isAccessibilitySize {
                VStack(alignment: .leading, spacing: 4) { statisticFooter }
            } else {
                HStack(spacing: 8) { statisticFooter }
            }
        }
    }

    private var statusPill: some View {
        Label("On track", systemImage: "checkmark")
            .font(.caption)
            .foregroundStyle(theme.success)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(theme.successSurface, in: Capsule())
            .accessibilityIdentifier("specimen-status")
    }

    private var itemCount: some View {
        Text("18 / 25 items")
            .font(.subheadline)
            .accessibilityIdentifier("specimen-item-count")
    }

    @ViewBuilder
    private var statisticFooter: some View {
        Text("Statistics card").font(.subheadline).foregroundStyle(theme.secondaryForeground)
            .accessibilityIdentifier("specimen-stat-kind")
        if !isAccessibilitySize { Spacer(minLength: 0) }
        Text("Visual example only").font(.subheadline).foregroundStyle(theme.secondaryForeground)
            .accessibilityIdentifier("specimen-stat-note")
    }

    private func contextPill(_ label: String, identifier: String) -> some View {
        Text(label)
            .font(.caption)
            .foregroundStyle(theme.secondaryForeground)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(theme.surface(.inset), in: Capsule())
            .accessibilityIdentifier(identifier)
    }
}

private struct CardDetailStyle: ButtonStyle {
    let theme: NativeDesignTheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(theme.brandText)
            .background {
                if configuration.isPressed { Capsule().fill(theme.accentSubtle) }
            }
    }
}
