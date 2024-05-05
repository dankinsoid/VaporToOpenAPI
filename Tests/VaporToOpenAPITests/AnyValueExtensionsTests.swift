import CustomDump
import SwiftOpenAPI
import Vapor
@testable import VaporToOpenAPI
import XCTest

final class AnyValueTests: XCTestCase {

	func testFirstDifferentKey() {
		let a = AnyValue.object(["a": 1, "b": "hello", "c": true])
		let b = AnyValue.object(["a": 1, "b": "hello", "c": false])
		XCTAssertEqual(a.firstDifferentKey(with: b), "c")
	}

	func testPathUpTo() {
		let a = AnyValue.object(["a": 1, "b": "hello", "c": true])
		let b = AnyValue.object(["d": 2, "e": "world", "f": false])
		let c = AnyValue.object(["g": 1, "h": b, "j": a])
		XCTAssertNoDifference(c.path(upTo: "a"), ["j", "a"])
		XCTAssertNoDifference(c.path(upTo: "f"), ["h", "f"])
		XCTAssertNoDifference(c.path(upTo: "c"), ["j", "c"])
	}
}
