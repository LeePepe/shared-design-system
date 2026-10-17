import XCTest
@testable import NativeDesignKit

final class NativeDesignKitTests: XCTestCase {
    func testNativeDesignKitTargetExecutes() {
        XCTAssertEqual(NativeDesignKitFixture.name, "NativeDesignKit")
    }
}
