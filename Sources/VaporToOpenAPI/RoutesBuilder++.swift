import Foundation
import SwiftOpenAPI
import Vapor

public extension RoutesBuilder {

	/// Group routes with OpenAPI tags
	func groupedOpenAPI(tags: [TagObject]) -> RoutesBuilder {
		HTTPRoutesGroup(root: self) { route in
			route.set(\.tags, to: (route.tags + tags).removeEquals(\.name))
		}
	}

	/// Group routes with OpenAPI tags
	func groupedOpenAPI(tags: TagObject...) -> RoutesBuilder {
		groupedOpenAPI(tags: tags)
	}

	/// Group routes with OpenAPI response
	func groupedOpenAPIResponse(
		statusCode: ResponsesObject.Key = 200,
		body: OpenAPIBody? = nil,
		contentType: MediaType...,
		headers: OpenAPIParameters? = nil,
		description: String? = nil
	) -> RoutesBuilder {
		HTTPRoutesGroup(root: self) { route in
			route._response(
				statusCode: statusCode,
				body: body?.value,
				contentTypes: contentType,
				headers: headers?.value,
				description: description
			)
		}
	}

	/// Group routes with OpenAPI server
	func groupedOpenAPI(server: ServerObject) -> RoutesBuilder {
		HTTPRoutesGroup(root: self) { route in
			route.openAPI(custom: \.servers) { servers in
				servers = (servers ?? []) + [server]
			}
		}
	}

	/// Creates a new Router that will automatically prepend the supplied tags as path components.
	func group(tags: [TagObject], configure: (RoutesBuilder) throws -> Void) rethrows {
		try groupedOpenAPI(tags: tags)
			.group(tags.map { .constant($0.name) }, configure: configure)
	}

	/// Creates a new Router that will automatically prepend the supplied tags as path components.
	func group(tags firsTag: TagObject, _ otherTags: TagObject..., configure: (RoutesBuilder) throws -> Void) rethrows {
		try group(tags: [firsTag] + otherTags, configure: configure)
	}

	/// Group routes with OpenAPI security requirements
	func groupedOpenAPI(
		auth: [AuthSchemeObject]
	) -> RoutesBuilder {
		HTTPRoutesGroup(root: self) { route in
			route.setNew(auth: auth)
		}
	}

	/// Group routes with OpenAPI security requirements
	func groupedOpenAPI(
		auth: AuthSchemeObject...
	) -> RoutesBuilder {
		groupedOpenAPI(auth: auth)
	}

	/// Group routes with OpenAPI specification identifier
	func groupedOpenAPI(spec: String) -> RoutesBuilder {
		HTTPRoutesGroup(root: self) { route in
			route.set(\.specID, to: spec)
		}
	}
}

/// Groups routes
private struct HTTPRoutesGroup: RoutesBuilder {
	/// Router to cascade to.
	let root: RoutesBuilder
	let map: (Route) -> Route

	/// See `HTTPRoutesBuilder`.
	func add(_ route: Route) {
		root.add(map(route))
	}
}
