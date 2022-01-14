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
		app.on(.GET, "users", "some", types: .empty) { _ in
			return ""
		}

		app.on(.POST, "users", "eee", types: .content(SomeContent.self)) { _ in
			return ""
		}
		
//		app.webSocket(<#T##path: PathComponent...##PathComponent#>, maxFrameSize: <#T##WebSocketMaxFrameSize#>, shouldUpgrade: <#T##((Request) -> EventLoopFuture<HTTPHeaders?>)##((Request) -> EventLoopFuture<HTTPHeaders?>)##(Request) -> EventLoopFuture<HTTPHeaders?>#>, onUpgrade: <#T##(Request, WebSocket) -> ()#>)
		
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

struct SomeContent: OpenAPIObject {
	var id: UUID = UUID()
	var name: [[Int]] = []
	var decimal: Decimal = 2.43
	
	init() {}
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
