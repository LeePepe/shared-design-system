import SwiftUI

/// Animation descriptions adapt explicit provider data, without defining another timing scale.
public enum NativeMotionSpec: Sendable, Equatable {
    case cubicBezier(duration: Double, x1: Double, y1: Double, x2: Double, y2: Double)
    case spring(response: Double, dampingFraction: Double, blendDuration: Double)

    public func animation(reduceMotion: Bool) -> Animation? {
        guard !reduceMotion else { return nil }
        switch self {
        case let .cubicBezier(duration, x1, y1, x2, y2):
            return .timingCurve(x1, y1, x2, y2, duration: duration)
        case let .spring(response, dampingFraction, blendDuration):
            return .spring(response: response, dampingFraction: dampingFraction, blendDuration: blendDuration)
        }
    }
}

public indirect enum NativeTransition {
    case opacity
    case move(Edge)
    case scale(CGFloat)
    case combined(NativeTransition, NativeTransition)
    case asymmetric(insertion: NativeTransition, removal: NativeTransition)

    /// Reduced motion retains the whole content in its intended final state.
    public func transition(reduceMotion: Bool) -> AnyTransition {
        guard !reduceMotion else { return .identity }
        switch self {
        case .opacity: return .opacity
        case let .move(edge): return .move(edge: edge)
        case let .scale(scale): return .scale(scale: scale)
        case let .combined(first, second):
            return first.transition(reduceMotion: false).combined(with: second.transition(reduceMotion: false))
        case let .asymmetric(insertion, removal):
            return .asymmetric(insertion: insertion.transition(reduceMotion: false),
                               removal: removal.transition(reduceMotion: false))
        }
    }
}

public enum NativeInterpolation {
    public static func clampedProgress(_ progress: Double) -> Double {
        guard progress.isFinite else { return progress == .infinity ? 1 : 0 }
        return min(max(progress, 0), 1)
    }

    public static func value(from start: Double, to end: Double, progress: Double) -> Double {
        let progress = clampedProgress(progress)
        if progress == 0 { return start }
        if progress == 1 { return end }
        return start + (end - start) * progress
    }

    /// Empty or invalid totals represent no progress. Negative progress clamps to zero.
    public static func progress(value: Double, total: Double) -> Double {
        guard total.isFinite && total > 0 else { return 0 }
        return clampedProgress(value / total)
    }
}

/// Animates a scalar through SwiftUI's animation system. The content closure can render a
/// formatted number, a progress indicator, or `Shape.trim(from:to:)` without a second timer.
public struct NativeAnimationProgress<Content: View>: View, Animatable {
    public var animatableData: Double
    private let content: (Double) -> Content

    public init(value: Double, @ViewBuilder content: @escaping (Double) -> Content) {
        animatableData = value
        self.content = content
    }

    public var body: some View { content(animatableData) }
}

public struct NativeStaggerSchedule: Sendable, Equatable {
    public let count: Int
    public let interval: Double

    public init(count: Int, interval: Double) {
        precondition(count >= 0 && interval.isFinite && interval >= 0)
        self.count = count
        self.interval = interval
    }

    public func offset(for index: Int) -> Double? {
        guard (0..<count).contains(index) else { return nil }
        return Double(index) * interval
    }
}

/// Caller owns the `.task` lifetime. Replay invalidates the previous run; cancellation never
/// allows a stale task to publish. A zero interval is a synchronous reveal.
@MainActor public final class NativeMotionSequence: ObservableObject {
    @Published public private(set) var visibleCount = 0
    private var generation = UUID()
    private var pending: Task<Void, Never>?

    public init() {}

    public func cancel() {
        generation = UUID()
        pending?.cancel()
        pending = nil
    }

    public func replay(schedule: NativeStaggerSchedule, reduceMotion: Bool) async {
        pending?.cancel()
        let run = UUID()
        generation = run
        visibleCount = 0
        guard !Task.isCancelled else { return }
        if reduceMotion || schedule.interval == 0 {
            visibleCount = schedule.count
            pending = nil
            return
        }
        let task = Task { [weak self] in
            for index in 0..<schedule.count {
                if index > 0 {
                    do {
                        var remaining = schedule.interval
                        while remaining > 0 {
                            let chunk = min(remaining, 3600)
                            try await Task.sleep(nanoseconds: UInt64(chunk * 1_000_000_000))
                            remaining -= chunk
                        }
                    } catch { return }
                }
                guard !Task.isCancelled, let self, self.generation == run else { return }
                self.visibleCount = index + 1
            }
        }
        pending = task
        await withTaskCancellationHandler {
            await task.value
        } onCancel: {
            task.cancel()
        }
        if generation == run { pending = nil }
    }
}

private struct MotionModifier<Value: Equatable>: ViewModifier {
    let motion: NativeMotionSpec
    let value: Value
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    func body(content: Content) -> some View {
        content.animation(motion.animation(reduceMotion: reduceMotion), value: value)
    }
}

public extension View {
    func nativeMotion<Value: Equatable>(_ motion: NativeMotionSpec, value: Value) -> some View {
        modifier(MotionModifier(motion: motion, value: value))
    }
}
