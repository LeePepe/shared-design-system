import XCTest
@testable import Strata

final class StrataTests: XCTestCase {
    func testStrataTargetExecutes() {
        XCTAssertEqual(StrataFixture.name, "Strata")
    }
}
