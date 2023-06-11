import CustomDump
import SwiftOpenAPI
import Vapor
@testable import VaporToOpenAPI
import XCTest

final class VDTests: XCTestCase {

	func testGlobal() throws {
		let routes = Routes()
		routes
			.groupedOpenAPI(auth: .basic, .apiKey())
			.groupedOpenAPIResponse(
				statusCode: 401,
				body: .type(of: ErrorResponse.example)
			)
			.get("pets") { _ -> [Pet] in
				[]
			}
			.openAPI(
				description: "Get all pets",
				query: .type(PetQuery.self),
				response: .type([Pet].self)
			)

		let api = routes.openAPI(
			info: InfoObject(
				title: "Pets API",
				version: Version(1, 0, 0)
			)
		)

		XCTAssertNoDifference(
			api,
			OpenAPIObject(
				info: InfoObject(
					title: "Pets API",
					version: Version(1, 0, 0)
				),
				paths: [
					"/pets": .value(
						PathItemObject(
							[
								.get: OperationObject(
									tags: ["pets"],
									description: "Get all pets",
									operationId: "getPets",
									parameters: [
										.value(ParameterObject(name: "filter", in: .query, required: false, schema: .string.with(\.nullable, true), example: .string(PetQuery.example.filter ?? ""))),
									],
									responses: [
										200: .value(
											ResponseObject(
												description: "OK",
												content: [
													.application(.json): MediaTypeObject(
														schema: .array(of: .ref(components: \.schemas, Pet.self)),
														examples: ["ArrayPet": .ref(components: \.examples, "ArrayPet")]
													),
												]
											)
										),
										401: .value(
											ResponseObject(
												description: "Unauthorized",
												content: [
													.application(.json): MediaTypeObject(
														schema: .ref(components: \.schemas, ErrorResponse.self),
														examples: ["ErrorResponse": .ref(components: \.examples, ErrorResponse.self)]
													),
												]
											)
										),
									],
									security: [
										SecurityRequirementObject("http_basic", []),
										SecurityRequirementObject("apiKey_header", []),
									]
								).extended(with: [:]),
							]
						)
					),
				],
				components: ComponentsObject(
					schemas: [
						"ErrorResponse": .object(
							properties: [
								"error": .boolean,
								"reason": .string,
							],
							required: ["error", "reason"]
						),
						"Pet": Pet.schema,
					],
					examples: [
						"ErrorResponse": .value(
							ExampleObject(
								value: [
									"error": .bool(ErrorResponse.example.error),
									"reason": .string(ErrorResponse.example.reason),
								]
							)
						),
						"ArrayPet": .value(ExampleObject(value: [Pet.exampleObject.object?.value ?? [:]])),
					],
					securitySchemes: [
						"http_basic": .basic,
						"apiKey_header": .apiKey(),
					]
				),
				tags: ["pets"]
			).extended(with: [:])
		)
	}

	func testIssue1() {
		let authenticated = Routes()

		let groups = authenticated.grouped("groups")

		groups.get { _ in [GroupDTO]() }
			.openAPI(
				summary: "List \(Group.self)s",
				description: "List all the \(Group.self)s of the current \(Account.self)",
				response: .type([GroupDTO].self)
			)

		groups.get("blublublu") { _ in [GroupDTO]() }
			.openAPI(
				summary: "List \(Group.self)s",
				description: "List all the \(Group.self)s of the current \(Account.self)",
				response: .type([GroupDTO].self),
				links: [Link("id", in: .request(.path)): GroupDTOID.self]
			)

		groups.get(":id") { _ in GroupDTO() }
			.openAPI(
				summary: "Get a \(Group.self) details",
				description: "Get details for a specific \(Group.self)s in the current \(Account.self)",
				response: .type(GroupDTO.self),
				links: [Link("id", in: .request(.path)): GroupDTOID.self]
			)
			.response(
				statusCode: 404,
				body: .type(of: ErrorResponse(error: true, reason: "Not found"))
			)

		groups.post { _ in GroupDTO() }
			.openAPI(
				summary: "Create a \(Group.self)",
				description: "Create a new users \(Group.self) in the current \(Account.self)",
				body: .type(CreateGroup.self),
				response: .type(GroupDTO.self),
				links: [
					Link(\GroupDTO.id, in: .response): GroupDTOID.self,
				]
			)
			.response(
				statusCode: 422,
				body: .type(of: ErrorResponse(error: true, reason: "Error details"))
			)
			.response(
				statusCode: 409,
				body: .type(of: ErrorResponse(error: true, reason: "Already exists"))
			)

		groups.put(":id") { _ in GroupDTO() }
			.openAPI(
				summary: "Update a \(Group.self)",
				description: "Update a \(Group.self) in the current \(Account.self)",
				body: .type(CreateGroup.self),
				response: .type(GroupDTO.self),
				links: [
					Link("id", in: .request(.path)): GroupDTOID.self,
					Link("id", in: .response): GroupDTOID.self,
				]
			)

		let api = authenticated.openAPI(
			info: InfoObject(title: "Some API", version: "1.0.0")
		)
		XCTAssertEqual(authenticated.all.count, api.paths?.value.values.flatMap { $0.object?.operations ?? [:] }.count ?? 0)
	}

	func testOpenAPIBodyDecodable() throws {
		var schemas: ComponentsMap<SchemaObject> = [:]
		var examples: ComponentsMap<ExampleObject> = [:]
		let body: OpenAPIBody = .type(PetNoExample.self)

		// Test type
		switch body.value {
		case let .type(type):
			XCTAssert(type is PetNoExample.Type)
		default:
			XCTFail("Expected .type(PetNoExample.self)")
		}

		// Test schema
		_ = try body.value.schema(schemas: &schemas)
		XCTAssertNoDifference(schemas, ["PetNoExample": Pet.schema])
		schemas = [:]

		// Test parameters
		let params = try body.value.parameters(in: .query, schemas: &schemas)
		XCTAssertNoDifference(params, Pet.parameters)
		schemas = [:]

		// Test headers
		let headers = try body.value.headers(schemas: &schemas)
		XCTAssertNoDifference(headers, Pet.headers)
		schemas = [:]

		// Test media object
		let media = try body.value.mediaTypeObject(schemas: &schemas, examples: &examples)
		XCTAssertNoDifference(media, MediaTypeObject(schema: .ref(components: \.schemas, "PetNoExample")))
		XCTAssertNoDifference(examples, [:])
		schemas = [:]
		examples = [:]
	}

	func testBodyExample() throws {
		let body: OpenAPIBody = .type(Pet.self)
		var schemas: ComponentsMap<SchemaObject> = [:]
		var examples: ComponentsMap<ExampleObject> = [:]

		// Test type
		switch body.value {
		case let .example(example):
			if let pet = example as? Pet {
				XCTAssertNoDifference(pet, Pet.example)
			} else {
				XCTFail("Expected Pet.example")
			}
		default:
			XCTFail("Expected .example(Pet.example)")
		}

		// Test schema
		_ = try body.value.schema(schemas: &schemas)
		XCTAssertNoDifference(
			schemas,
			[
				"Pet": .object(
					properties: [
						"id": .string(format: .uuid),
						"name": .string,
						"age": .integer(format: .int64, range: 0...),
					],
					required: ["id", "name", "age"]
				),
			]
		)
		schemas = [:]

		// Test parameters
		let params = try body.value.parameters(in: .query, schemas: &schemas)
		XCTAssertNoDifference(
			params,
			[
				.value(ParameterObject(name: "id", in: .query, required: true, schema: .string(format: .uuid), example: .string(Pet.example.id.uuidString))),
				.value(ParameterObject(name: "name", in: .query, required: true, schema: .string, example: .string(Pet.example.name))),
				.value(ParameterObject(name: "age", in: .query, required: true, schema: .integer(format: .int64, range: 0...), example: .int(Int(Pet.example.age)))),
			]
		)
		schemas = [:]

		// Test headers
		let headers = try body.value.headers(schemas: &schemas)
		XCTAssertNoDifference(
			headers,
			[
				"id": .value(HeaderObject(required: true, schema: .string(format: .uuid), example: .string(Pet.example.id.uuidString))),
				"name": .value(HeaderObject(required: true, schema: .string, example: .string(Pet.example.name))),
				"age": .value(HeaderObject(required: true, schema: .integer(format: .int64, range: 0...), example: .int(Int(Pet.example.age)))),
			]
		)
		schemas = [:]

		// Test media object
		let media = try body.value.mediaTypeObject(schemas: &schemas, examples: &examples)
		XCTAssertNoDifference(media, MediaTypeObject(schema: .ref(components: \.schemas, "Pet"), examples: ["Pet": .ref(components: \.examples, "Pet")]))
		XCTAssertNoDifference(examples, ["Pet": Pet.exampleObject])
		schemas = [:]
		examples = [:]
	}

	func testBodyOneOf() throws {
		var schemas: ComponentsMap<SchemaObject> = [:]
		let body: OpenAPIBody = .one(of: .type(Pet.self), .type(GroupDTO.self))

		// Test schema
		let schema = try body.value.schema(schemas: &schemas)
		XCTAssertNoDifference(
			schema,
			.one(of:
				.ref(components: \.schemas, Pet.self),
				.ref(components: \.schemas, GroupDTO.self))
		)
		XCTAssertNoDifference(
			schemas,
			[
				"Pet": Pet.schema,
				"GroupDTO": .object(
					properties: [
						"id": .string(format: .uuid),
						"description": .string,
					],
					required: ["id", "description"]
				),
			]
		)
		schemas = [:]
	}

	func testParametersOneOf() throws {
		var schemas: ComponentsMap<SchemaObject> = [:]
		let parameters: OpenAPIParameters = .all(of: .type(Pet.self), .type(ErrorResponse.self))
		let params = try parameters.value.parameters(in: .query, schemas: &schemas)
		XCTAssertNoDifference(
			params,
			[
				.value(ParameterObject(name: "id", in: .query, required: true, schema: .string(format: .uuid), example: .string(Pet.example.id.uuidString))),
				.value(ParameterObject(name: "name", in: .query, required: true, schema: .string, example: .string(Pet.example.name))),
				.value(ParameterObject(name: "age", in: .query, required: true, schema: .integer(format: .int64, range: 0...), example: .int(Int(Pet.example.age)))),
				.value(ParameterObject(name: "error", in: .query, required: true, schema: .boolean, example: .bool(ErrorResponse.example.error))),
				.value(ParameterObject(name: "reason", in: .query, required: true, schema: .string, example: .string(ErrorResponse.example.reason))),
			]
		)
	}

	func testGroupedOpenAPITags() throws {
		let tag: TagObject = "test.com"
		let routes = Routes()
		let builder = routes.groupedOpenAPI(tags: [tag])
		builder.get("test") { _ in "test" }
		builder.post("test") { _ in "test" }

		let openAPI = routes.openAPI(info: InfoObject(title: "Test", version: "1.0.0"))
		XCTAssertNoDifference(openAPI.tags, [tag])
		XCTAssertNoDifference(
			openAPI.paths?.value.values.flatMap { $0.object?.operations.values.flatMap { $0.tags ?? [] } ?? [] },
			[tag.name, tag.name]
		)
	}

	func testGroupedOpenAPIResponse() throws {
		let routes = Routes()
		let builder = routes.groupedOpenAPIResponse(statusCode: .notFound, description: "Not found")
		builder.get("test") { _ in "test" }
		builder.post("test") { _ in "test" }

		let openAPI = routes.openAPI(info: InfoObject(title: "Test", version: "1.0.0"))

		let responses = openAPI.paths?.value.values.compactMap {
			$0.object?.operations.values.reduce(into: [:]) {
				$0.merge(
					$1.responses?.value.compactMapValues(\.object) ?? [:]
				) { _, new in new }
			}
		} ?? []

		XCTAssertNoDifference(
			responses,
			[[ResponsesObject.Key.notFound: ResponseObject(description: "Not found")]]
		)
	}

	func testExamples() throws {
		let example1 = Pet(name: "Persey", age: 2)
		let example2 = Pet(name: "Sima", age: 4)

		let routes = Routes()
		routes
			.get("pets") { _ -> [Pet] in
				[]
			}
			.openAPI(
				description: "Get all pets",
				body: .type(of: example2),
				response: .type(of: example2)
			)

		routes
			.put("pets") { _ -> [Pet] in
				[]
			}
			.openAPI(
				description: "Get all pets",
				body: .type(of: example1),
				response: .type(of: example2)
			)

		let api = routes.openAPI(info: InfoObject(title: "Pets", version: "1.0.0"))

		let simaExample = api.components?.examples?
			.first(where: { $0.key == "Pet" })?
			.value.object?.value
		XCTAssertNotNil(simaExample)
		let perseyExample = api.components?.examples?
			.first(where: { $0.key == "Pet1" })?
			.value.object?.value
		XCTAssertNotNil(perseyExample)
		Route.examples = [:]
	}
}

struct Group: WithExample, Content {

	static var example = Group()

	var id = UUID()
	var someValue = "Value"
	var accounts: [Account] = [Account()]
}

struct Account: WithExample, Content {

	static var example = Account()

	var id = UUID()
	var name = "Name"
}

struct CreateGroup: WithExample, Content {

	static var example = Self()

	var count = 10
}

struct ErrorResponse: Codable, WithExample {

	static var example = ErrorResponse()

	var error = true
	var reason = "Error"
}

struct GroupDTO: WithExample, Content {

	static var example = Self()

	var id = UUID()
	var description = "GroupDTO"
}

struct Pet: WithExample, Content, Equatable {

	var id = UUID()
	var name: String
	var age: UInt

	static let example = Pet(name: "Persey", age: 2)

	static var schema: ReferenceOr<SchemaObject> {
		.object(
			properties: [
				"id": .string(format: .uuid),
				"name": .string,
				"age": .integer(format: .int64, range: 0...),
			],
			required: ["id", "name", "age"]
		)
	}

	static var parameters: ParametersList {
		[
			.value(ParameterObject(name: "id", in: .query, required: true, schema: .string(format: .uuid))),
			.value(ParameterObject(name: "name", in: .query, required: true, schema: .string)),
			.value(ParameterObject(name: "age", in: .query, required: true, schema: .integer(format: .int64, range: 0...))),
		]
	}

	static var headers: ComponentsMap<HeaderObject> {
		[
			"id": .value(HeaderObject(required: true, schema: .string(format: .uuid))),
			"name": .value(HeaderObject(required: true, schema: .string)),
			"age": .value(HeaderObject(required: true, schema: .integer(format: .int64, range: 0...))),
		]
	}

	static var exampleObject: ReferenceOr<ExampleObject> {
		.value(
			ExampleObject(
				value: [
					"id": .string(example.id.uuidString),
					"name": .string(example.name),
					"age": .int(Int(example.age)),
				]
			)
		)
	}
}

struct PetNoExample: Content {

	var id = UUID()
	var name: String
	var age: UInt
}

struct PetQuery: WithExample {

	var filter: String?

	static let example = PetQuery(filter: "age>5")
}

private func prettyPrint(_ codable: some Encodable) {
	let encoder = JSONEncoder()
	encoder.outputFormatting = .prettyPrinted
	do {
		try print(
			String(
				data: encoder.encode(codable),
				encoding: .utf8
			) ?? ""
		)
	} catch {
		print(codable)
	}
}

enum PetID: LinkKey {}

enum GroupDTOID: LinkKey {}
