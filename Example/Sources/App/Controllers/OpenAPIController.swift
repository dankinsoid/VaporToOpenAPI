import Foundation
import Vapor
import VaporToOpenAPI

struct OpenAPIController: RouteCollection {

	// MARK: Internal

	func boot(routes: RoutesBuilder) throws {

		// generate OpenAPI documentation
		routes.get("swagger", "swagger.json") { req in
			req.application.routes.openAPI(
				info: InfoObject(
					title: "Swagger Petstore - OpenAPI 3.0",
					description: "This is a sample Pet Store Server based on the OpenAPI 3.0.1 specification.",
					termsOfService: URL(string: "http://swagger.io/terms/"),
					contact: ContactObject(
						email: "apiteam@swagger.io"
					),
					license: LicenseObject(
						name: "Apache 2.0",
						url: URL(string: "http://www.apache.org/licenses/LICENSE-2.0.html")
					),
					version: Version(1, 0, 17)
				),
				externalDocs: ExternalDocumentationObject(
					description: "Find out more about Swagger",
					url: URL(string: "http://swagger.io")!
				)
			)
		}
		.excludeFromOpenAPI()

		routes.stoplightDocumentation(
			"stoplight",
			openAPIPath: "/swagger/swagger.json"
		)
	}
}
