import SwiftUI

public enum NativeProgressPresentation: Sendable { case linear, ring, indeterminate }

/// `value == nil` is indeterminate. A determinate ring is clamped to 0...1 while its
/// accessible value remains the native ProgressView's value/total. `diameter` and `lineWidth`
/// are caller style inputs, including for the ring's track.
public struct NativeProgress<Label: View>: View {
    private let value: Double?
    private let total: Double
    private let presentation: NativeProgressPresentation
    private let theme: NativeDesignTheme
    private let diameter: CGFloat
    private let lineWidth: CGFloat
    private let accessibilityValue: Text
    private let label: Label

    public init(value: Double?, total: Double, presentation: NativeProgressPresentation,
                theme: NativeDesignTheme, diameter: CGFloat, lineWidth: CGFloat,
                accessibilityValue: Text, @ViewBuilder label: () -> Label) {
        precondition(total.isFinite && total > 0 && (value?.isFinite ?? true))
        precondition(diameter.isFinite && diameter > 0 && lineWidth.isFinite && lineWidth > 0)
        self.value = value; self.total = total; self.presentation = presentation
        self.theme = theme; self.diameter = diameter; self.lineWidth = lineWidth
        self.accessibilityValue = accessibilityValue; self.label = label()
    }

    public var body: some View {
        Group {
            if presentation == .indeterminate || value == nil {
                ProgressView { label }.progressViewStyle(.circular)
            } else if presentation == .ring, let value {
                ProgressView(value: value, total: total) { label }
                    .progressViewStyle(RingProgressStyle(theme: theme, diameter: diameter, lineWidth: lineWidth))
            } else {
                ProgressView(value: value, total: total) { label }.progressViewStyle(.linear)
            }
        }.tint(theme.statusInfo).foregroundColor(theme.textPrimary)
            .accessibilityValue(accessibilityValue)
    }
}

private struct RingProgressStyle: ProgressViewStyle {
    let theme: NativeDesignTheme
    let diameter: CGFloat
    let lineWidth: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            ZStack {
                Circle().stroke(theme.textSecondary, lineWidth: lineWidth)
                Circle().trim(from: 0, to: min(max(configuration.fractionCompleted ?? 0, 0), 1))
                    .stroke(theme.statusInfo, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }.frame(width: diameter, height: diameter).padding(lineWidth / 2)
                .accessibilityHidden(true)
            configuration.label
            configuration.currentValueLabel
        }
    }
}

public struct NativeBadge<Label: View>: View {
    private let theme: NativeDesignTheme
    private let metrics: NativeControlMetrics
    private let tone: NativeControlTone
    private let label: Label

    public init(theme: NativeDesignTheme, metrics: NativeControlMetrics, tone: NativeControlTone,
                @ViewBuilder label: () -> Label) {
        self.theme = theme; self.metrics = metrics; self.tone = tone; self.label = label()
    }

    public var body: some View {
        let colors = tone.colors(theme)
        label.padding(metrics.padding).foregroundColor(colors.foreground)
            .background(RoundedRectangle(cornerRadius: metrics.cornerRadius).fill(colors.background))
    }
}

/// A removable tag keeps the removal action as a distinct native accessible Button.
public struct NativeTag<Label: View>: View {
    private let theme: NativeDesignTheme
    private let metrics: NativeControlMetrics
    private let tone: NativeControlTone
    private let removeLabel: Text
    private let onRemove: () -> Void
    private let label: Label

    public init(theme: NativeDesignTheme, metrics: NativeControlMetrics, tone: NativeControlTone,
                removeLabel: Text, onRemove: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.theme = theme; self.metrics = metrics; self.tone = tone
        self.removeLabel = removeLabel; self.onRemove = onRemove; self.label = label()
    }

    public var body: some View {
        NativeBadge(theme: theme, metrics: metrics, tone: tone) {
            HStack(spacing: metrics.spacing) {
                label
                Button(action: onRemove) {
                    Image(systemName: "xmark").nativeMinimumHitTarget(metrics.minimumHitSize)
                }.buttonStyle(.plain).accessibilityLabel(removeLabel)
            }
        }
    }
}

public struct NativeIconLabel<Icon: View, Label: View>: View {
    private let theme: NativeDesignTheme
    private let metrics: NativeControlMetrics
    private let icon: Icon
    private let label: Label

    public init(theme: NativeDesignTheme, metrics: NativeControlMetrics,
                @ViewBuilder icon: () -> Icon, @ViewBuilder label: () -> Label) {
        self.theme = theme; self.metrics = metrics; self.icon = icon(); self.label = label()
    }

    public var body: some View {
        HStack(spacing: metrics.spacing) {
            icon.font(.system(size: metrics.iconSize)).accessibilityHidden(true)
            label
        }.foregroundColor(theme.textPrimary)
    }
}

/// Caller owns initials, image loading and content. This view performs no networking.
public struct NativeAvatar<Content: View>: View {
    private let theme: NativeDesignTheme
    private let diameter: CGFloat
    private let accessibilityLabel: Text
    private let content: Content

    public init(theme: NativeDesignTheme, diameter: CGFloat, accessibilityLabel: Text,
                @ViewBuilder content: () -> Content) {
        precondition(diameter.isFinite && diameter > 0)
        self.theme = theme; self.diameter = diameter
        self.accessibilityLabel = accessibilityLabel; self.content = content()
    }

    public var body: some View {
        content.frame(width: diameter, height: diameter).foregroundColor(theme.statusOnInfo)
            .background(theme.statusInfo).clipShape(Circle())
            .accessibilityElement(children: .ignore).accessibilityLabel(accessibilityLabel)
    }
}

/// Formatting is caller-owned. VoiceOver receives the complete target value immediately;
/// Reduce Motion removes interpolation and displays the complete target without a task.
public struct NativeAnimatedNumber: View {
    private let value: Double
    private let theme: NativeDesignTheme
    private let motion: NativeMotionSpec
    private let label: Text
    private let format: (Double) -> String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(value: Double, theme: NativeDesignTheme, motion: NativeMotionSpec,
                accessibilityLabel: Text, format: @escaping (Double) -> String) {
        precondition(value.isFinite)
        self.value = value; self.theme = theme; self.motion = motion
        label = accessibilityLabel; self.format = format
    }

    public var body: some View {
        Text("").modifier(NumberInterpolation(value: value, format: format))
            .foregroundColor(theme.textPrimary).monospacedDigit()
            .animation(motion.animation(reduceMotion: reduceMotion), value: value)
            .accessibilityElement(children: .ignore).accessibilityLabel(label)
            .accessibilityValue(Text(format(value)))
    }
}

private struct NumberInterpolation: AnimatableModifier {
    nonisolated var value: Double
    let format: (Double) -> String
    nonisolated var animatableData: Double {
        get { value }
        set { value = newValue }
    }
    func body(content: Content) -> some View { Text(format(value)) }
}
