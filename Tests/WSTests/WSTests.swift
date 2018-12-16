import XCTest
@testable import WS

final class WSTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(WS().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
