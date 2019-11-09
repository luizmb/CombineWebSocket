import XCTest
@testable import CombineWebSocket

final class CombineWebSocketTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CombineWebSocket().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
