import Foundation
import Vapor
import SwiftOpenAPI

extension RoutesBuilder {

    /// Group routes with OpenAPI tags
    public func groupedOpenAPI(tags: [String]) -> RoutesBuilder {
        HTTPRoutesGroup(root: self) { route in
            route.openAPI(custom: \.tags, ((route.operationObject.tags ?? []) + tags).removeEquals)
        }
    }

    /// Group routes with OpenAPI tags
    public func groupedOpenAPI(tags: String...) -> RoutesBuilder {
        groupedOpenAPI(tags: tags)
    }

    /// Group routes with OpenAPI security requirements
    public func groupedOpenAPI(
        auth: [AuthSchemeObject],
        authScopes: [String] = []
    ) -> RoutesBuilder {
        HTTPRoutesGroup(root: self) { route in
            route.setNew(auth: auth, scopes: authScopes)
        }
    }

    /// Group routes with OpenAPI security requirements
    public func groupedOpenAPI(
        auth: AuthSchemeObject...,
        authScopes: [String] = []
    ) -> RoutesBuilder {
        groupedOpenAPI(auth: auth, authScopes: authScopes)
    }
    
    /// Group routes with OpenAPI specification identifier
    public func groupedOpenAPI(spec: String) -> RoutesBuilder {
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
