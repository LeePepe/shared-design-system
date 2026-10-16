import SwiftUI
import XCTest
@testable import NativeDesignKit

final class NativeFoundationTests: XCTestCase {
    func testFlowWrapsAtBoundaryAndPreservesInputOrder() {
        let packing = NativeFlowPacking(sizes: [CGSize(width: 40, height: 20),
                                                CGSize(width: 50, height: 30),
                                                CGSize(width: 10, height: 15)],
                                        width: 100, horizontalSpacing: 10, verticalSpacing: 8)
        XCTAssertEqual(packing.rows, [[0, 1], [2]])
        XCTAssertEqual(packing.frames[1], CGRect(x: 50, y: 0, width: 50, height: 30))
        XCTAssertEqual(packing.frames[2], CGRect(x: 0, y: 38, width: 10, height: 15))
        XCTAssertEqual(packing.size, CGSize(width: 100, height: 53))
    }

    func testFlowClampsOversizedItemAndHasNoTrailingSpacing() {
        let packing = NativeFlowPacking(sizes: [CGSize(width: 500, height: 48),
                                                CGSize(width: 20, height: 12)],
                                        width: 80, horizontalSpacing: 4, verticalSpacing: 6)
        XCTAssertEqual(packing.rows, [[0], [1]])
        XCTAssertEqual(packing.frames[0].width, 80)
        XCTAssertEqual(packing.size.height, 66)
        XCTAssertEqual(NativeFlowPacking(sizes: [], width: 80,
                                         horizontalSpacing: 4, verticalSpacing: 6).size, .zero)
    }

    func testInterpolationClampsAndEndsExactlyWithoutOvershoot() {
        XCTAssertEqual(NativeInterpolation.value(from: 100, to: 5, progress: -1), 100)
        XCTAssertEqual(NativeInterpolation.value(from: 100, to: 5, progress: 2), 5)
        XCTAssertEqual(NativeInterpolation.value(from: 100, to: 0, progress: 0.25), 75)
        XCTAssertEqual(NativeInterpolation.progress(value: 200, total: 100), 1)
        XCTAssertEqual(NativeInterpolation.progress(value: 20, total: 0), 0)
        XCTAssertEqual(NativeInterpolation.progress(value: .nan, total: 100), 0)
        XCTAssertEqual(NativeInterpolation.clampedProgress(.infinity), 1)
    }

    func testReducedMotionSuppressesEveryAnimationFamily() {
        let curve = NativeMotionSpec.cubicBezier(duration: 1, x1: 0.2, y1: 0.7, x2: 0.2, y2: 1)
        let spring = NativeMotionSpec.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)
        XCTAssertNil(curve.animation(reduceMotion: true))
        XCTAssertNil(spring.animation(reduceMotion: true))
        XCTAssertNotNil(curve.animation(reduceMotion: false))
        XCTAssertNotNil(spring.animation(reduceMotion: false))
    }

    func testStaggerUsesTimeNotDisplayFrameRate() {
        let schedule = NativeStaggerSchedule(count: 3, interval: 0.1)
        XCTAssertEqual(schedule.offset(for: 0), 0)
        XCTAssertEqual(schedule.offset(for: 2), 0.2)
        XCTAssertNil(schedule.offset(for: -1))
        XCTAssertNil(schedule.offset(for: 3))
    }

    @MainActor func testReducedMotionAndSynchronousReplayReachCompleteEndState() async {
        let sequence = NativeMotionSequence()
        await sequence.replay(schedule: NativeStaggerSchedule(count: 53, interval: 1), reduceMotion: true)
        XCTAssertEqual(sequence.visibleCount, 53)
        await sequence.replay(schedule: NativeStaggerSchedule(count: 12, interval: 0), reduceMotion: false)
        XCTAssertEqual(sequence.visibleCount, 12)
        await sequence.replay(schedule: NativeStaggerSchedule(count: 0, interval: 1), reduceMotion: false)
        XCTAssertEqual(sequence.visibleCount, 0)
    }

    @MainActor func testReplayPreventsOldSequencePublishingIntoNewRun() async {
        let sequence = NativeMotionSequence()
        let first = Task { await sequence.replay(schedule: NativeStaggerSchedule(count: 3, interval: 0.02),
                                                 reduceMotion: false) }
        for _ in 0..<100 where sequence.visibleCount == 0 { await Task.yield() }
        XCTAssertEqual(sequence.visibleCount, 1)
        await sequence.replay(schedule: NativeStaggerSchedule(count: 7, interval: 0), reduceMotion: false)
        await first.value
        XCTAssertEqual(sequence.visibleCount, 7)
    }

    @MainActor func testExplicitCancellationAndTaskCancellationStopFurtherReveals() async {
        let sequence = NativeMotionSequence()
        let task = Task { await sequence.replay(schedule: NativeStaggerSchedule(count: 10, interval: 0.02),
                                                reduceMotion: false) }
        for _ in 0..<100 where sequence.visibleCount == 0 { await Task.yield() }
        XCTAssertEqual(sequence.visibleCount, 1)
        sequence.cancel()
        await task.value
        XCTAssertEqual(sequence.visibleCount, 1)

        let cancelled = Task { await sequence.replay(schedule: NativeStaggerSchedule(count: 10, interval: 1),
                                                     reduceMotion: false) }
        for _ in 0..<100 where sequence.visibleCount != 1 { await Task.yield() }
        cancelled.cancel()
        await cancelled.value
        XCTAssertLessThan(sequence.visibleCount, 10)
    }
}
