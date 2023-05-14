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
					body: Pet.self,
					bodyType: .application(.json), .application(.xml), .application(.urlEncoded),
					response: Pet.self,
					responseType: .application(.json), .application(.xml),
					errorDescriptions: [
						400: "Invalid ID supplied",
						404: "Pet not found",
						405: "Validation exception",
					],
					links: [
						Link(\Pet.id, in: .response): Link.PetID.self,
						Link(\Pet.id, in: .request): Link.PetID.self
					]
				)

				routes.post { _ in
					Pet.example
				}
				.openAPI(
					summary: "Add a new pet to the store",
					description: "Add a new pet to the store",
					body: Pet.self,
					bodyType: .application(.json), .application(.xml), .application(.urlEncoded),
					response: Pet.self,
					responseType: .application(.json), .application(.xml),
					errorDescriptions: [
						405: "Invalid input",
					],
					links: [
						Link(\Pet.id, in: .response): Link.PetID.self,
						Link(\Pet.id, in: .request): Link.PetID.self
					]
				)

				routes.get("findByStatus") { _ in
					[Pet.example]
				}
				.openAPI(
					summary: "Finds Pets by status",
					description: "Multiple status values can be provided with comma separated strings",
					query: FindPetByStatusQuery.self,
                    response: [Pet].self,
					responseType: .application(.json), .application(.xml),
					errorDescriptions: [
						400: "Invalid status value",
					],
					links: [
						Link(\Pet.id, in: .response): Link.PetID.self
					]
				)

				routes.get("findByTags") { _ in
					[Pet.example]
				}
				.openAPI(
					summary: "Finds Pets by tags",
					description: "Multiple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing.",
					query: FindPetByTagsQuery.self,
					response: [Pet].self,
					responseType: .application(.json), .application(.xml),
					errorDescriptions: [
						400: "Invalid tag value",
					],
					links: [
						Link(\Pet.id, in: .response): Link.PetID.self
					]
				)

				routes.get(":petId") { _ in
					Pet.example
				}
				.openAPI(
					summary: "Find pet by ID",
					description: "Returns a single pet",
					response: Pet.self,
					responseType: .application(.json), .application(.xml),
					errorDescriptions: [
						400: "Invalid ID supplied",
						404: "Pet not found",
					],
					links: [
						Link(\Pet.id, in: .path): Link.PetID.self,
						Link(\Pet.id, in: .response): Link.PetID.self
					],
					auth: .petstoreApiKey
				)

				routes.post(":petId") { _ in
					"Success update"
				}
				.openAPI(
					summary: "Updates a pet in the store with form data",
					query: UpdatePetQuery.self,
					errorDescriptions: [
						405: "Invalid input",
					],
					links: [
						Link(\Pet.id, in: .path): Link.PetID.self
					]
				)

				routes.delete(":petId") { _ in
					"Success delete"
				}
				.openAPI(
					summary: "Deletes a pet",
					errorDescriptions: [
						400: "Invalid pet value",
					],
					links: [
						Link(\Pet.id, in: .path): Link.PetID.self
					]
				)

				routes.post("uploadImage") { _ in
					ApiResponse.example
				}
				.openAPI(
					summary: "uploads an image",
					query: UploadImageQuery.self,
					body: Data.self,
					bodyType: .application(.octetStream),
					response: ApiResponse.self,
					errorDescriptions: [
						400: "Invalid pet value",
					]
				)
			}
	}
}
