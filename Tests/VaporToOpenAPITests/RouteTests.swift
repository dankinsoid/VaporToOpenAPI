import CustomDump
import SwiftOpenAPI
import Vapor
@testable import VaporToOpenAPI
import XCTest

final class RouteTests: XCTestCase {

	private let path = "custom"

	func testOpenAPITags() {
		route {
			$0.openAPI(tags: "TAG")
		} testOperation: {
			XCTAssertEqual($0.tags, ["TAG"])
		}

		route {
			$0.openAPI()
		} testOperation: {
			XCTAssertEqual($0.tags, [path])
		}
	}

	func testOpenAPISummary() {
		route {
			$0.openAPI(summary: "summary")
		} testOperation: {
			XCTAssertEqual($0.summary, "summary")
		}
	}

	func testOpenAPIDescription() {
		route {
			$0.openAPI(description: "description")
		} testOperation: {
			XCTAssertEqual($0.description, "description")
		}
	}

	func testOpenAPIOperationID() {
		route {
			$0.openAPI(operationId: "operationId")
		} testOperation: {
			XCTAssertEqual($0.operationId, "operationId")
		}

		route {
			$0.openAPI()
		} testOperation: {
			XCTAssertEqual($0.operationId, "getCustom")
		}
	}

	func testOpenAPIExternalDocs() {
		let doc = ExternalDocumentationObject(url: URL(string: "google.com"))
		route {
			$0.openAPI(externalDocs: doc)
		} testOperation: {
			XCTAssertEqual($0.externalDocs, doc)
		}
	}

	func testOpenAPIQuery() {
		route {
			$0.openAPI(query: .type(TestType.self))
		} testOperation: {
			XCTAssertNoDifference($0.parameters, TestType.parameters(in: .query))
		}
	}

	func testOpenAPIHeader() {
		route {
			$0.openAPI(headers: .type(TestType.self))
		} testOperation: {
			XCTAssertNoDifference($0.parameters, TestType.parameters(in: .header))
		}
	}

	func testOpenAPIPath() {
		route {
			$0.openAPI(path: .type(TestType.self))
		} testOperation: {
			XCTAssertNoDifference($0.parameters, TestType.parameters(in: .path))
		}
	}

	func testOpenAPICookies() {
		route {
			$0.openAPI(cookies: .type(TestType.self))
		} testOperation: {
			XCTAssertNoDifference($0.parameters, TestType.parameters(in: .cookie))
		}
	}

	func testOpenAPIBody() {
		route {
			$0.openAPI(body: .type(TestType.self))
		} testOperation: {
			XCTAssertNoDifference(
				$0.requestBody?.object?.content,
				[
					.application(.json): MediaTypeObject(
						schema: .ref(components: \.schemas, "TestType"),
						examples: [
							"TestType": .ref(components: \.examples, "TestType"),
						]
					),
				]
			)
		} testDocument: { openAPIObject in
			XCTAssertNoDifference(
				openAPIObject.components?.schemas,
				["TestType": TestType.schema]
			)
			XCTAssertNoDifference(
				openAPIObject.components?.examples,
				["TestType": ["intValue": 0]]
			)
		}
	}

	func testOpenAPIContentType() {
		route {
			$0.openAPI(body: .schema(.string), contentType: .text(.html))
		} testOperation: {
			XCTAssertNoDifference(
				$0.requestBody?.object?.content.value.first?.key,
				.text(.html)
			)
		}

		route {
			$0.openAPI(body: .schema(.string), contentType: .text(.html), .application(.json))
		} testOperation: {
			XCTAssertEqual(
				Set($0.requestBody?.object?.content.value.keys.map { $0 } ?? []),
				[.text(.html), .application(.json)]
			)
		}

		route {
			$0.openAPI(contentType: .text(.html))
		} testOperation: {
			XCTAssert($0.requestBody == nil)
		}
	}

	func testOpenAPIResponse() {
		route {
			$0.openAPI(response: .type(GetStudentDTO.self))
		} testOperation: {
			XCTAssertNoDifference(
				$0.responses?[.ok]?.object?.content,
				[
					.application(.json): MediaTypeObject(
						schema: .ref(components: \.schemas, "GetStudentDTO")
					),
				]
			)
		} testDocument: { openAPIObject in
			XCTAssertNoDifference(
				openAPIObject.components?.schemas,
				["GetStudentDTO": GetStudentDTO.schema]
			)
			//            XCTAssertNoDifference(
			//                openAPIObject.components?.examples,
			//                ["TestType": ["intValue": 0]]
			//            )
		}
	}

	func testOpenAPIResponseContentType() {
		route {
			$0.openAPI(response: .schema(.string), responseContentType: .text(.html))
		} testOperation: {
			XCTAssertNoDifference(
				$0.responses?[.ok]?.object?.content?.value.keys.map { $0 },
				[.text(.html)]
			)
		}

		route {
			$0.openAPI(response: .schema(.string), responseContentType: .text(.html), .application(.json))
		} testOperation: {
			XCTAssertEqual(
				Set($0.responses?[.ok]?.object?.content?.value.keys.map { $0 } ?? []),
				[.text(.html), .application(.json)]
			)
		}

		route {
			$0.openAPI(responseContentType: .text(.html))
		} testOperation: {
			XCTAssert($0.responses == nil)
		}
	}

	func testOpenAPIResponseHeaders() {
		route {
			$0.openAPI(response: .schema(.string), responseHeaders: .type(TestType.self))
		} testOperation: {
			XCTAssertNoDifference(
				$0.responses?[.ok]?.object?.headers,
				TestType.headers
			)
		}

		route {
			$0.openAPI(responseHeaders: .type(TestType.self))
		} testOperation: {
			XCTAssert($0.responses == nil)
		}
	}

	func testOpenAPIResponseDescription() {
		route {
			$0.openAPI(responseDescription: "description")
		} testOperation: {
			XCTAssertEqual(
				$0.responses?[.ok]?.object?.description,
				"description"
			)
		}
	}

	func testOpenAPIResponseStatusCode() {
		route {
			$0.openAPI(responseDescription: "description", statusCode: .notFound)
		} testOperation: {
			XCTAssertEqual(
				$0.responses?.value.keys.map { $0 },
				[.notFound]
			)
		}

		route {
			$0.openAPI(statusCode: .notFound)
		} testOperation: {
			XCTAssert($0.responses == nil)
		}
	}

	func testOpenAPILinks() {
		route {
			$0.openAPI(
				links: [
					Link("ids", in: .request): IDLink.self,
					Link("id", in: .response): IDLink.self,
				]
			)
		} testDocument: {
			XCTAssertNoDifference(
				$0.components?.links,
				[
					"ResponseBodyIdGetCustomRequestBodyIds": .value(
						LinkObject(
							operationId: "getCustom",
							parameters: ["ids": .expression("$response.body#/id")]
						)
					),
				]
			)
		}
	}

	func testOpenAPIDeprecated() {
		route {
			$0.openAPI(deprecated: true)
		} testOperation: {
			XCTAssertEqual($0.deprecated, true)
		}
	}

	func testOpenAPIAuth() {
		let name = "basic"
		route {
			$0.openAPI(auth: .basic(id: name))
		} testOperation: {
			XCTAssertNoDifference($0.security, [SecurityRequirementObject(name)])
		} testDocument: { doc in
			XCTAssertNoDifference(doc.components?.securitySchemes, [name: .basic])
		}
	}

	func testServers() {
		let name = "server"
		route {
			$0.openAPI(servers: [ServerObject(url: name)])
		} testOperation: {
			XCTAssertNoDifference($0.servers, [ServerObject(url: name)])
		}
	}

	func testSpectificationExtensions() {
		let extensions: SpecificationExtensions = ["some-value": 1]
		route {
			$0.openAPI(extensions: extensions)
		} testOperation: {
			XCTAssertNoDifference($0.specificationExtensions, extensions)
		}
		route {
			$0.openAPI(extensions: [:])
		} testOperation: {
			XCTAssertNoDifference($0.specificationExtensions, nil)
		}
	}

	func testCallbacks() {
		let value: [String: ReferenceOr<CallbackObject>] = [
			"callback": [
				"$expression": .ref(components: \.pathItems, "path"),
			],
		]
		route {
			$0.openAPI(callbacks: value)
		} testOperation: {
			XCTAssertNoDifference($0.callbacks, value)
		}
	}

	func testDefaultContentType() {
		route {
			$0.openAPI(response: .type(String.self))
		} testOperation: {
			XCTAssertNoDifference($0.responses?[.ok]?.object?.content?.value.keys.map { $0 }, [.text(.plain)])
		}
		route {
			$0.openAPI(response: .type(Data.self))
		} testOperation: {
			XCTAssertNoDifference($0.responses?[.ok]?.object?.content?.value.keys.map { $0 }, [.text("binary")])
		}
	}

	private func route(
		openAPI: (Route) -> Route,
		testOperation: (OperationObject) -> Void = { _ in },
		testDocument: (OpenAPIObject) -> Void = { _ in }
	) {
		let routes = Routes()
		_ = openAPI(routes.get(.constant(path), use: { _ in "custom" }))
		let openAPI = routes.openAPI(info: InfoObject(title: "Title", version: "1.0.0"))
		testDocument(openAPI)
		guard let operation = openAPI.paths?[.init(path)]?[.get] else {
			XCTFail("There is no operation")
			return
		}
		testOperation(operation)
		Route.examples = [:]
	}
}

struct TestType: Codable, WithExample {

	var intValue = 0

	static let example = TestType()

	static func parameters(in location: ParameterObject.Location) -> ParametersList {
		[
			.value(
				ParameterObject(
					name: CodingKeys.intValue.stringValue,
					in: location,
					required: true,
					schema: .integer,
					example: 0
				)
			),
		]
	}

	static var headers: ComponentsMap<HeaderObject> {
		[
			CodingKeys.intValue.stringValue: .value(HeaderObject(required: true, schema: .integer, example: 0)),
		]
	}

	static var schema: ReferenceOr<SchemaObject> {
		.object(properties: [CodingKeys.intValue.stringValue: .integer], required: [CodingKeys.intValue.stringValue])
	}
}

enum IDLink: LinkKey {}

struct GetStudentDTO: Content {
	var id: UUID
	var courseOfStudy: String
	var email: String

	static var schema: ReferenceOr<SchemaObject> {
		.value(
			.object(
				properties: [
					"id": .uuid,
					"courseOfStudy": .string,
					"email": .string,
				],
				required: ["id", "courseOfStudy", "email"]
			)
		)
	}
}
