import Foundation
import Vapor
import VaporToOpenAPI

public struct StoreController: RouteCollection {

	public func boot(routes: RoutesBuilder) throws {
		routes
			.group(
				tags: TagObject(
					name: "store",
					description: "Access to Petstore orders",
					externalDocs: ExternalDocumentationObject(
						description: "Find out more about our store",
						url: URL(string: "http://swagger.io")!
					)
				)
			) { routes in
				routes.get("inventory") { _ in
					["Key": 100]
				}
				.openAPI(
					summary: "Returns pet inventories by status",
					description: "Returns a map of status codes to quantities",
					response: .type([String: Int32]).self,
					auth: .petstoreApiKey
				)

				routes.group("order") { routes in
					routes.post { _ in
						Order.example
					}
					.openAPI(
						summary: "Place an order for a pet",
						description: "Place a new order in the store",
						body: .type(Order.self),
						contentType: .application(.json), .application(.xml), .application(.urlEncoded),
						response: .type(Order.self)
					)
					.response(statusCode: 405, description: "Invalid input")

					routes
						.groupedOpenAPIResponse(statusCode: 400, description: "Invalid ID supplied")
						.groupedOpenAPIResponse(statusCode: 404, description: "Order not found")
						.group(":orderId") { routes in
							routes.get { _ in
								Order.example
							}
							.openAPI(
								summary: "Find purchase order by ID",
								description: "For valid response try integer IDs with value <= 5 or > 10. Other values will generate exceptions.",
								response: .type(Order.self),
								responseContentType: .application(.xml), .application(.json)
							)

							routes.delete { _ in
								"Success delete"
							}
							.openAPI(
								summary: "Delete purchase order by ID",
								description: "For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors"
							)
						}
				}§
			}
	}
}
