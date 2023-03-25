import Foundation
import Vapor
import VaporToOpenAPI

struct OpenAPIController: RouteCollection {

	// MARK: Internal

	func boot(routes: RoutesBuilder) throws {
	
		// generate OpenAPI documentation
		routes.get("swagger", "swagger.json") { req in
			let result = req.application.routes.openAPI(
				info: InfoObject(
					title: "Swagger Petstore - OpenAPI 3.0",
					description: "This is a sample Pet Store Server based on the OpenAPI 3.0.1 specification.  You can find out more about\nSwagger at [http://swagger.io](http://swagger.io). In the third iteration of the pet store, we've switched to the design first approach!\nYou can now help us improve the API whether it's by making changes to the definition itself or to the code.\nThat way, with time, we can improve the API in general, and expose some of the new features in OAS3.\n\nSome useful links:\n- [The Pet Store repository](https://github.com/swagger-api/swagger-petstore)\n- [The source API definition for the Pet Store](https://github.com/swagger-api/swagger-petstore/blob/master/src/main/resources/openapi.yaml)",
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
				servers: ["/api/v3"],
				tags: [
					TagObject(
						name: "pet",
						description: "Everything about your Pets",
						externalDocs: ExternalDocumentationObject(
							description: "Find out more",
							url: URL(string: "http://swagger.io")!
						)
					),
					TagObject(
						name: "store",
						description: "Access to Petstore orders",
						externalDocs: ExternalDocumentationObject(
							description: "Find out more about our store",
							url: URL(string: "http://swagger.io")!
						)
					),
					TagObject(
						name: "user"
					)
				],
				externalDocs: ExternalDocumentationObject(
					description: "Find out more about Swagger",
					url: URL(string: "http://swagger.io")!
				)
			)
			let encoder = JSONEncoder()
			encoder.outputFormatting = .prettyPrinted
			try print(String(data: encoder.encode(result), encoding: .utf8)!)
			return result
		}
		.excludeFromOpenAPI()
	}
}
