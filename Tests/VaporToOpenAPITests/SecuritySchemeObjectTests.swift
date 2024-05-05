import CustomDump
import SwiftOpenAPI
import Vapor
@testable import VaporToOpenAPI
import XCTest

final class AuthSchemeObjectTests: XCTestCase {

	func testInit() {
		let scheme = SecuritySchemeObject.basic(description: "Basic authentication")
		let authScheme = AuthSchemeObject(id: "basic", scopes: ["read", "write"], scheme: scheme)
		XCTAssertEqual(authScheme.id, "basic")
		XCTAssertEqual(authScheme.scopes, ["read", "write"])
		XCTAssertEqual(authScheme.scheme, scheme)
	}

	func testScopes() {
		let scheme = SecuritySchemeObject.bearer(format: "JWT")
		let authScheme = AuthSchemeObject(id: "bearer", scheme: scheme)
		let newAuthScheme = authScheme.scopes("read", "write")
		XCTAssertEqual(newAuthScheme.scopes, ["read", "write"])
	}
}
