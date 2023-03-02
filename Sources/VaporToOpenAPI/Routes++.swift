import Vapor
@_exported import SwiftOpenAPI

extension Routes {
    
    public func openAPI(
        info: InfoObject,
        jsonSchemaDialect: URL? = nil,
        servers: [ServerObject]? = nil,
        paths: PathsObject? = nil,
        webhooks: [String: ReferenceOr<PathItemObject>]? = nil,
        components: ComponentsObject = ComponentsObject(),
        security: [SecurityRequirementObject]? = nil,
        tags: [TagObject]? = nil,
        externalDocs: ExternalDocumentationObject? = nil,
        errorExamples: [Int: WithExample.Type] = [:],
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
            security: security,
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
        return openAPIObject
    }
    
    private func errorKey(_ key: ResponsesObject.Key) -> String {
        "error-code-\(key.rawValue)"
    }
}
