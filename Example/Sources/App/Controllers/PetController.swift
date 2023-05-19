import Foundation
import Vapor
import VaporToOpenAPI

struct PetController: RouteCollection {

	// MARK: Internal

	func boot(routes: RoutesBuilder) throws {
		routes
			.groupedOpenAPI(auth: .petstoreAuth.scopes("write:pets", "read:pets"))
			.group(
				tags: TagObject(
					name: "pet",
					description: "Everything about your Pets",
					externalDocs: ExternalDocumentationObject(
						description: "Find out more",
						url: URL(string: "http://swagger.io")!
					)
				)
			) { routes in
				routes.put { _ in
					Pet.example
				}
				.openAPI(
					summary: "Update an existing pet",
					description: "Update an existing pet by Id",
					body: .type(Pet.self),
					contentType: .application(.json), .application(.xml), .application(.urlEncoded),
					response: .type(Pet.self),
					responseContentType: .application(.json), .application(.xml),
					links: [
						Link(\Pet.id, in: .response): Link.PetID.self,
						Link(\Pet.id, in: .request): Link.PetID.self,
					]
				)
				.response(statusCode: 400, description: "Invalid ID supplied")
				.response(statusCode: 404, description: "Pet not found")
				.response(statusCode: 405, description: "Validation exception")

				routes.post { _ in
					Pet.example
				}
				.openAPI(
					summary: "Add a new pet to the store",
					description: "Add a new pet to the store",
					body: .type(Pet.self),
					contentType: .application(.json), .application(.xml), .application(.urlEncoded),
					response: .type(Pet.self),
					responseContentType: .application(.json), .application(.xml),
					links: [
						Link(\Pet.id, in: .response): Link.PetID.self,
						Link(\Pet.id, in: .request): Link.PetID.self,
					]
				)
				.response(statusCode: 405, description: "Invalid input")

				routes.get("findByStatus") { _ in
					[Pet.example]
				}
				.openAPI(
					summary: "Finds Pets by status",
					description: "Multiple status values can be provided with comma separated strings",
					query: .type(FindPetByStatusQuery.self),
					response: .type([Pet].self),
					responseContentType: .application(.json), .application(.xml),
					links: [
						Link(\Pet.id, in: .response): Link.PetID.self,
					]
				)
				.response(statusCode: 400, description: "Invalid status value")

				routes.get("findByTags") { _ in
					[Pet.example]
				}
				.openAPI(
					summary: "Finds Pets by tags",
					description: "Multiple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing.",
					query: ["tags": .array(of: .string)],
					response: .type([Pet].self),
					responseContentType: .application(.json), .application(.xml),
					errorDescriptions: [
						400: "Invalid tag value",
					],
					links: [
						Link(\Pet.id, in: .response): Link.PetID.self,
					]
				)
				.response(statusCode: 400, description: "Invalid tag value")

				routes.get(":petId") { _ in
					Pet.example
				}
				.openAPI(
					summary: "Find pet by ID",
					description: "Returns a single pet",
					response: .type(Pet.self),
					responseContentType: .application(.json), .application(.xml),
					links: [
						Link(\Pet.id, in: .path): Link.PetID.self,
						Link(\Pet.id, in: .response): Link.PetID.self,
					],
					auth: .petstoreApiKey
				)
				.response(statusCode: 400, description: "Invalid ID supplied")
				.response(statusCode: 404, description: "Pet not found")

				routes.post(":petId") { _ in
					"Success update"
				}
				.openAPI(
					summary: "Updates a pet in the store with form data",
					query: .type(UpdatePetQuery.self),
					links: [
						Link(\Pet.id, in: .path): Link.PetID.self,
					]
				)
				.response(statusCode: 405, description: "Invalid input")

				routes.delete(":petId") { _ in
					"Success delete"
				}
				.openAPI(
					summary: "Deletes a pet",
					links: [
						Link(\Pet.id, in: .path): Link.PetID.self,
					]
				)
				.response(statusCode: 400, description: "Invalid pet value")

				routes.post("uploadImage") { _ in
					ApiResponse.example
				}
				.openAPI(
					summary: "uploads an image",
					query: .type(UploadImageQuery.self),
					body: .type(Data.self),
					contentType: .application(.octetStream),
					response: .type(ApiResponse.self)
				)
				.response(statusCode: 400, description: "Invalid pet value")
			}
	}
}
