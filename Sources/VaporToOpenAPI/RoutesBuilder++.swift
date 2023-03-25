import Foundation
import SwiftOpenAPI
import Vapor

public extension RoutesBuilder {

	/// Group routes with OpenAPI tags
	func groupedOpenAPI(tags: [String]) -> RoutesBuilder {
		HTTPRoutesGroup(root: self) { route in
			route.openAPI(custom: \.tags, ((route.operationObject.tags ?? []) + tags).removeEquals)
		}
	}

	/// Group routes with OpenAPI tags
	func groupedOpenAPI(tags: String...) -> RoutesBuilder {
		groupedOpenAPI(tags: tags)
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
