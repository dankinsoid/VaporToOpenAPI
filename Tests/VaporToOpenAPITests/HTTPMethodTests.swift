import SwiftOpenAPI
import Vapor
@testable import VaporToOpenAPI
import XCTest

final class HTTPMethodTests: XCTestCase {

	func testOpenAPI() {
		XCTAssertEqual(HTTPMethod.GET.openAPI, .get)
		XCTAssertEqual(HTTPMethod.POST.openAPI, .post)
		XCTAssertEqual(HTTPMethod.PUT.openAPI, .put)
		XCTAssertEqual(HTTPMethod.PATCH.openAPI, .patch)
		XCTAssertEqual(HTTPMethod.DELETE.openAPI, .delete)
		XCTAssertEqual(HTTPMethod.HEAD.openAPI, .head)
		XCTAssertEqual(HTTPMethod.OPTIONS.openAPI, .options)
		XCTAssertEqual(HTTPMethod.TRACE.openAPI, .trace)
		XCTAssertEqual(HTTPMethod.CONNECT.openAPI, .init(rawValue: "connect"))
	}
}
