import Vapor
import SwiftOpenAPI

extension Routes {
    
    public func openAPI(
        info: InfoObject,
        jsonSchemaDialect: URL? = nil,
        servers: [ServerObject]? = nil,
        paths: PathsObject? = nil,
        webhooks: [String: ReferenceOr<PathItemObject>]? = nil,
        components: ComponentsObject? = nil,
        security: [SecurityRequirementObject]? = nil,
        tags: [TagObject]? = nil,
        externalDocs: ExternalDocumentationObject? = nil,
        map: (Route) -> Route = { $0 }
    ) -> OpenAPIObject {
        var openAPIObject = OpenAPIObject(
            info: info,
            jsonSchemaDialect: jsonSchemaDialect,
            servers: servers,
            paths: paths ?? PathsObject(),
            webhooks: webhooks,
            components: components ?? ComponentsObject(),
            security: security,
            tags: tags,
            externalDocs: externalDocs
        )
        let routes = all.map(map).filter { !$0.excludeFromOpenApi }
        
        openAPIObject.components?.schemas = routes.reduce(into: components?.schemas ?? [:]) { components, route in
            components.merge(route.schemas) { new, _ in new }
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
        return openAPIObject
    }
}
