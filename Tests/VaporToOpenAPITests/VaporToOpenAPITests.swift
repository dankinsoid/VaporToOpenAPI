//
//  File.swift
//  
//
//  Created by Данил Войдилов on 08.02.2021.
//

import XCTest
import Vapor
import Swiftgger
import VDCodable
@testable import VaporToOpenAPI

final class VDTests: XCTestCase {
	
	func tests() {
		let app = Application()
		defer { app.shutdown() }
		app.get("users", "some") { _ in
			return ""
		}
		.openAPI(
			content: String.self
		)

		app.post("users", "eee") { req in
			req.view.render(app.directory.publicDirectory + "Swagger/index.html")
		}
		.openAPI(
			content: SomeContent.self
		)
		
		let openAPI = app.routes.openAPI(title: "My Server API", version: "1.0.0", description: "It's our generated API")
		
		print(APIBodyType(type: String.self, example: nil))
		
		print(Mirror(reflecting: SomeContent()).children.map { $0.label ?? "" })
		
		do {
			let data = try VDJSONEncoder().encodeToJSON(openAPI)
			print(data)
		} catch {
			print(openAPI)
			XCTAssert(false, error.localizedDescription)
		}
	}
	
	static var allTests = [
		("tests", tests),
	]
}

public struct SomeContent: OpenAPIObject {
	public var id: UUID = UUID()
	public var name: [[Int]] = []
	public var decimal: Decimal? = 2.43
	
	public init() {}
}

@propertyWrapper
struct W<T> {
	var wrappedValue: T
}

extension W: Decodable where T: Decodable {
	init(from decoder: Decoder) throws {
		wrappedValue = try T.init(from: decoder)
	}
}
extension W: Encodable where T: Encodable {
	func encode(to encoder: Encoder) throws {
		try wrappedValue.encode(to: encoder)
	}
}
