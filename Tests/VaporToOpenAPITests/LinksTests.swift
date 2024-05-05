import SwiftOpenAPI
import Vapor
@testable import VaporToOpenAPI
import XCTest

final class LinkTests: XCTestCase {

	func testIdentifier() {
		let link = Link("example", in: .request(.query))
		XCTAssertEqual(link.identifier, "RequestQueryExample")
	}

	func testExpression() {
		let link = Link("example", in: .response(.body))
		XCTAssertEqual(link.expression, "$response.body#/example")
	}

	func testLocationDescription() {
		let requestLocation = Link.RequestLocation.path
		let responseLocation = Link.ResponseLocation.header
		let requestLink = Link("example", in: .request(requestLocation))
		let responseLink = Link("example", in: .response(responseLocation))
		XCTAssertEqual(requestLink.location.description, "request.path")
		XCTAssertEqual(responseLink.location.description, "response.header")
	}

	func testIsResponse() {
		let requestLink = Link("example", in: .request(.query))
		let responseLink = Link("example", in: .response(.header))
		XCTAssertFalse(requestLink.location.isResponse)
		XCTAssertTrue(responseLink.location.isResponse)
	}
}
