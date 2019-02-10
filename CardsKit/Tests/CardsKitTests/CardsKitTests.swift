import XCTest
@testable import CardsKit

final class CardsKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CardsKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
