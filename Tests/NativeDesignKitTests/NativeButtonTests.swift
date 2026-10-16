import XCTest
@testable import NativeDesignKit

final class NativeButtonTests: XCTestCase {
    func testLoadingAndDisabledBlockEveryActionDispatch() {
        for enabled in [false, true] {
            for loading in [false, true] {
                var count = 0
                for _ in 0..<3 {
                    NativeButtonActivation.perform(isEnabled: enabled, isLoading: loading) { count += 1 }
                }
                XCTAssertEqual(count, enabled && !loading ? 3 : 0)
            }
        }
    }
}
