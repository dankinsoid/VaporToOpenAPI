import CustomDump
import SwiftOpenAPI
import Vapor
@testable import VaporToOpenAPI
import XCTest

final class CollectionTests: XCTestCase {

	func testNilIfEmpty() {
		let emptyArray: [Int] = []
		let nonEmptyArray = [1, 2, 3]
		let emptyDict: [String: Int] = [:]
		let nonEmptyDict = ["a": 1, "b": 2, "c": 3]
		XCTAssertNil(emptyArray.nilIfEmpty)
		XCTAssertEqual(nonEmptyArray.nilIfEmpty, nonEmptyArray)
		XCTAssertNil(emptyDict.nilIfEmpty)
		XCTAssertEqual(nonEmptyDict.nilIfEmpty, nonEmptyDict)
	}

	func testRemoveEquals() {
		let array1 = [1, 2, 3, 2, 4, 5, 4, 6]
		let array2 = ["a", "A", "A", "a", "b", "C", "c", "C"]
		XCTAssertEqual(array1.removeEquals, [1, 2, 3, 4, 5, 6])
		XCTAssertNoDifference(array2.removeEquals { $0.lowercased() }, ["a", "b", "C"])
	}

	func testMapKeys() {
		let dict = ["a": 1, "b": 2, "c": 3]
		XCTAssertNoDifference(dict.mapKeys { $0.uppercased() }, ["A": 1, "B": 2, "C": 3])
		XCTAssertNoDifference(dict.mapKeys({ $0.uppercased() }, values: { $0 * 2 }), ["A": 2, "B": 4, "C": 6])
	}
}
