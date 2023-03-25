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
					body: User.example,
					bodyType: .application(.json), .application(.xml), .application(.urlEncoded),
					response: User.example,
					responseType: .application(.json), .application(.xml)
				)

				routes.post("createWithList") { _ in
					User.example
				}
				.openAPI(
					summary: "Creates list of users with given input array",
					description: "Creates list of users with given input array",
					body: User.example,
					response: User.example,
					responseType: .application(.json), .application(.xml)
				)

				routes.get("login") { _ in
					"Success"
				}
				.openAPI(
					summary: "Logs user into the system",
					query: LoginQuery.example,
					response: String.example,
					responseType: .application(.json), .application(.xml),
					responseHeaders: Headers.XRateLimit.example, Headers.XExpiresAfter.example,
					errorDescriptions: [
						400: "Invalid username/password supplied",
					]
				)

				routes.get("logout") { _ in
					"Success"
				}
				.openAPI(
					summary: "Logs out current logged in user session",
					response: "successful operation"
				)

				routes.group(":username") { routes in
					routes.get { _ in
						User.example
					}
					.openAPI(
						summary: "Get user by user name",
						response: User.example,
						responseType: .application(.json), .application(.xml),
						errorDescriptions: [
							400: "Invalid username supplied",
							404: "User not found",
						]
					)

					routes.put { _ in
						"successful operation"
					}
					.openAPI(
						summary: "Update user",
						description: "This can only be done by the logged in user.",
						body: User.example,
						bodyType: .application(.json), .application(.xml), .application(.urlEncoded),
						response: "successful operation"
					)

					routes.delete { _ in
						"successful operation"
					}
					.openAPI(
						summary: "Delete user",
						description: "This can only be done by the logged in user.",
						response: "successful operation",
						errorDescriptions: [
							400: "Invalid username supplied",
							404: "User not found"
						]
					)
				}
			}
	}
}
