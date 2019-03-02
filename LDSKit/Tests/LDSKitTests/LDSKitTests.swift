import XCTest
@testable import LDSKit

final class LDSKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(LDSKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
