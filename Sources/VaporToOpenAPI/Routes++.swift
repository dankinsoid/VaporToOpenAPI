import Vapor
@_exported import SwiftOpenAPI

extension Routes {
    
    /// Create ```OpenAPIObjwct```
    /// - Parameters:
    ///   - info: Provides metadata about the API. The metadata MAY be used by tooling as required.
    ///   - jsonSchemaDialect: The default value for the $schema keyword within ```SchemaObjects``` contained within this OAS document.
    ///   - servers: An array of ```ServerObject```, which provide connectivity information to a target server. If the servers property is not provided, or is an empty array, the default value would be a ```ServerObject``` with a url value of /.
    ///   - paths: The available paths and operations for the API.
    ///   - webhooks: The incoming webhooks that MAY be received as part of this API and that the API consumer MAY choose to implement. 
    ///   - components: An element to hold additional schemas for the document.
    ///   - commonAuth: A declaration of which security mechanisms can be used across the API.
    ///   - tags: A list of tags used by the document with additional metadata. 
    ///   - externalDocs: Additional external documentation.
    ///   - errorExamples: Common error responses
    ///   - errorType: Common error content type
    ///   - errorHeaders: Common error headers
    ///   - map: Closure to customise OpenAPI for each route
    /// - Returns: ```OpenAPIObject``` instance
    public func openAPI(
        info: InfoObject,
        jsonSchemaDialect: URL? = nil,
        servers: [ServerObject]? = nil,
        paths: PathsObject? = nil,
        webhooks: [String: ReferenceOr<PathItemObject>]? = nil,
        components: ComponentsObject = ComponentsObject(),
        commonAuth: [SecuritySchemeObject]? = nil,
        tags: [TagObject]? = nil,
        externalDocs: ExternalDocumentationObject? = nil,
        errorExamples: [Int: Codable] = [:],
        errorType: MediaType = .application(.json),
        errorHeaders: WithExample.Type...,
        map: (Route) -> Route = { $0 }
    ) -> OpenAPIObject {
        var schemas = components.schemas ?? [:]
        var openAPIObject = OpenAPIObject(
            info: info,
            jsonSchemaDialect: jsonSchemaDialect,
            servers: servers,
            paths: paths ?? PathsObject(),
            webhooks: webhooks,
            components: components,
            security: securities(auth: commonAuth ?? []),
            tags: tags,
            externalDocs: externalDocs
        )
        let routes = all.map(map).filter { !$0.excludeFromOpenApi }
        
        schemas = routes.reduce(into: schemas) { components, route in
            components.merge(route.schemas) { new, _ in new }
        }
        
        if let errors = responses(
            default: nil,
            type: .application(.json),
            headers: [],
            errors: errorExamples,
            errorType: errorType,
            errorHeaders: errorHeaders,
            schemas: &schemas
        ) {
            var responses = openAPIObject.components?.responses ?? [:]
            for (key, value) in errors.value {
                responses[errorKey(key)] = value
            }
            openAPIObject.components?.responses = responses
            
            for route in routes {
                route.operationObject.responses = route.operationObject.responses ?? [:]
                for key in errors.value.keys where route.operationObject.responses?[key] == nil {
                    route.operationObject.responses?[key] = .ref(components: \.responses, errorKey(key))
                }
            }
        }
        
        for route in routes {
            openAPIObject.paths?[Path(route.path)] = .value(
            		PathItemObject(
                    description: nil,
                    servers: nil,
                    parameters: nil,
                    [route.method.openAPI: route.operationObject]
                )
            )
        }
        openAPIObject.components?.schemas = schemas.nilIfEmpty
        openAPIObject.components?.securitySchemes = Dictionary(
            (routes.flatMap(\.auths) + (commonAuth ?? []))
        				.removeEquals
                .map { ($0.autoName, .value($0)) }
        ) { _, n in n }
            .nilIfEmpty
        return openAPIObject
    }
    
    private func errorKey(_ key: ResponsesObject.Key) -> String {
        "error-code-\(key.rawValue)"
    }
}

extension RoutesBuilder {
    
    public func groupedOpenAPI(
        tags: [String] = [],
        auth: [SecuritySchemeObject],
        authScopes: [String]
    ) -> RoutesBuilder {
        HTTPRoutesGroup(root: self, tags: tags, auth: auth, authScopes: authScopes)
    }
    
    public func groupedOpenAPI(
        tags: String...,
        auth: SecuritySchemeObject...,
        authScopes: [String] = []
    ) -> RoutesBuilder {
        groupedOpenAPI(tags: tags, auth: auth, authScopes: authScopes)
    }
}

extension OpenAPIObject: Content {
}

/// Groups routes
private struct HTTPRoutesGroup: RoutesBuilder {
    /// Router to cascade to.
    let root: RoutesBuilder
		let tags: [String]
    let auth: [SecuritySchemeObject]
    let authScopes: [String]
    
    /// See `HTTPRoutesBuilder`.
    func add(_ route: Route) {
        root.add(
            route
                .setNew(auth: auth, scopes: authScopes)
                .openAPI(custom: \.tags, ((route.operationObject.tags ?? []) + tags).removeEquals)
        )
    }
}
