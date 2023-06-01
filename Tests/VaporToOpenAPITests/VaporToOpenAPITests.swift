import CustomDump
import SwiftOpenAPI
import Vapor
@testable import VaporToOpenAPI
import XCTest

final class VDTests: XCTestCase {

	func tests() throws {
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
		prettyPrint(api)
		XCTAssertEqual(authenticated.all.count, api.paths?.value.values.flatMap { $0.object?.operations ?? [:] }.count ?? 0)
	}

	func testOpenAPIBodyDecodable() throws {
		var schemas: [String: ReferenceOr<SchemaObject>] = [:]
		var examples: [String: ReferenceOr<ExampleObject>] = [:]
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
		var schemas: [String: ReferenceOr<SchemaObject>] = [:]
		var examples: [String: ReferenceOr<ExampleObject>] = [:]

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
						"age": .integer(format: .int32),
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
				.value(ParameterObject(name: "age", in: .query, required: true, schema: .integer(format: .int32), example: .int(Int(Pet.example.age)))),
				.value(ParameterObject(name: "id", in: .query, required: true, schema: .string(format: .uuid), example: .string(Pet.example.id.uuidString))),
				.value(ParameterObject(name: "name", in: .query, required: true, schema: .string, example: .string(Pet.example.name))),
			]
		)
		schemas = [:]

		// Test headers
		let headers = try body.value.headers(schemas: &schemas)
		XCTAssertNoDifference(
			headers,
			[
				"age": .value(HeaderObject(required: true, schema: .integer(format: .int32), example: .int(Int(Pet.example.age)))),
				"id": .value(HeaderObject(required: true, schema: .string(format: .uuid), example: .string(Pet.example.id.uuidString))),
				"name": .value(HeaderObject(required: true, schema: .string, example: .string(Pet.example.name))),
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
		var schemas: [String: ReferenceOr<SchemaObject>] = [:]
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
		var schemas: [String: ReferenceOr<SchemaObject>] = [:]
		let parameters: OpenAPIParameters = .all(of: .type(Pet.self), .type(ErrorResponse.self))
		let params = try parameters.value.parameters(in: .query, schemas: &schemas)
		XCTAssertNoDifference(
			params,
			[
				.value(ParameterObject(name: "age", in: .query, required: true, schema: .integer(format: .int32), example: .int(Int(Pet.example.age)))),
				.value(ParameterObject(name: "error", in: .query, required: true, schema: .boolean, example: .bool(ErrorResponse.example.error))),
				.value(ParameterObject(name: "id", in: .query, required: true, schema: .string(format: .uuid), example: .string(Pet.example.id.uuidString))),
				.value(ParameterObject(name: "name", in: .query, required: true, schema: .string, example: .string(Pet.example.name))),
				.value(ParameterObject(name: "reason", in: .query, required: true, schema: .string, example: .string(ErrorResponse.example.reason))),
			]
		)
	}

	static var allTests = [
		("tests", tests),
	]
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
				"age": .integer(format: .int32),
			],
			required: ["id", "name", "age"]
		)
	}

	static var parameters: [ReferenceOr<ParameterObject>] {
		[
			.value(ParameterObject(name: "age", in: .query, required: true, schema: .integer(format: .int32))),
			.value(ParameterObject(name: "id", in: .query, required: true, schema: .string(format: .uuid))),
			.value(ParameterObject(name: "name", in: .query, required: true, schema: .string)),
		]
	}

	static var headers: [String: ReferenceOr<HeaderObject>] {
		[
			"age": .value(HeaderObject(required: true, schema: .integer(format: .int32))),
			"id": .value(HeaderObject(required: true, schema: .string(format: .uuid))),
			"name": .value(HeaderObject(required: true, schema: .string)),
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
