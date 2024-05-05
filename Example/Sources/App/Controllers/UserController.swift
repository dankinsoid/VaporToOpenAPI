import Foundation
import Vapor
import VaporToOpenAPI

struct UserController: RouteCollection {

	// MARK: Internal

	func boot(routes: RoutesBuilder) throws {
		routes
			.group("user") { routes in
				routes.post { _ in
					User.example
				}
				.openAPI(
					summary: "Create user",
					description: "This can only be done by the logged in user.",
					body: .type(User.self),
					contentType: .application(.json), .application(.xml), .application(.urlEncoded),
					response: .type(User.self),
					responseContentType: .application(.json), .application(.xml)
				)

				routes.post("createWithList") { _ in
					User.example
				}
				.openAPI(
					summary: "Creates list of users with given input array",
					description: "Creates list of users with given input array",
					body: .type(User.self),
					response: .type(User.self),
					responseContentType: .application(.json), .application(.xml)
				)

				routes.get("login") { _ in
					"Success"
				}
				.openAPI(
					summary: "Logs user into the system",
					query: .type(LoginQuery.self),
					response: .type(String.self),
					responseContentType: .application(.json), .application(.xml),
					responseHeaders: .all(of: .type(Headers.XRateLimit.self), .type(Headers.XExpiresAfter.self))
				)
				.response(statusCode: 400, description: "Invalid username/password supplied")

				routes.get("logout") { _ in
					"Success"
				}
				.openAPI(
					summary: "Logs out current logged in user session"
				)
				.response(description: "successful operation")

				routes.group(":username") { routes in
					routes.get { _ in
						User.example
					}
					.openAPI(
						summary: "Get user by user name",
						response: .type(User.self),
						responseContentType: .application(.json), .application(.xml)
					)
					.response(statusCode: .badRequest, description: "Invalid username supplied")
					.response(statusCode: .notFound, description: "User not found")

					routes.put { _ in
						"successful operation"
					}
					.openAPI(
						summary: "Update user",
						description: "This can only be done by the logged in user.",
						body: .type(User.self),
						contentType: .application(.json), .application(.xml), .application(.urlEncoded),
						response: .type(of: "successful operation")
					)

					routes.delete { _ in
						"successful operation"
					}
					.openAPI(
						summary: "Delete user",
						description: "This can only be done by the logged in user.",
						response: .type(of: "successful operation")
					)
					.response(statusCode: .badRequest, description: "Invalid username supplied")
					.response(statusCode: .notFound, description: "User not found")
				}
			}
	}
}
