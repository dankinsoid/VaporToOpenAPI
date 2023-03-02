import Vapor
import SwiftOpenAPI

extension Route {
    
    @discardableResult
    public func openAPI(
        tags: [String]? = nil,
        summary: String? = nil,
        description: String,
        externalDocs: ExternalDocumentationObject? = nil,
        operationId: String? = nil,
        query: WithExample.Type...,
        headers: WithExample.Type...,
        path: WithExample.Type...,
        cookies: WithExample.Type...,
        body: WithExample.Type? = nil,
        requestType: MediaType = .application(.json),
        response: WithExample.Type? = nil,
        responseType: MediaType = .application(.json),
        responseHeaders: WithExample.Type...,
        errorResponses: [Int: WithExample.Type] = [:],
        errorType: MediaType = .application(.json),
        errorHeaders: WithExample.Type...,
        callbacks: [String: ReferenceOr<CallbackObject>]? = nil,
        deprecated: Bool? = nil,
        security: [SecurityRequirementObject]? = nil,
        servers: [ServerObject]? = nil
    ) -> Route {
        set(
            \.operationObject,
            to: OperationObject(
                tags: tags ?? self.path.prefix(1).map(\.description),
                summary: summary,
                description: description,
                externalDocs: externalDocs,
                operationId: operationId,
                parameters: [
                    try? query.flatMap {
                        try [ReferenceOr<ParameterObject>].encode($0.example, in: .query, schemas: &schemas)
                    },
                    try? headers.flatMap {
                        try [ReferenceOr<ParameterObject>].encode($0.example, in: .header, schemas: &schemas)
                    },
                    try? path.flatMap {
                        try [ReferenceOr<ParameterObject>].encode($0.example, in: .path, schemas: &schemas)
                    },
                    try? cookies.flatMap {
                        try [ReferenceOr<ParameterObject>].encode($0.example, in: .cookie, schemas: &schemas)
                    }
                ].flatMap { $0 ?? [] }.nilIfEmpty,
                requestBody: request(
                    body: body,
                    description: nil,
                    required: nil,
                    type: requestType,
                    schemas: &schemas
                ),
                responses: responses(
                    default: response,
                    type: responseType,
                    headers: responseHeaders,
                    errors: errorResponses,
                    errorType: errorType,
                    errorHeaders: errorHeaders,
                    schemas: &schemas
                ),
                callbacks: callbacks,
                deprecated: deprecated,
                security: security,
                servers: servers
             )
        )
        .description(description)
    }
    
    @discardableResult
    public func excludeFromOpenAPI() -> Route {
        set(\.excludeFromOpenApi, to: true)
    }
    
    @discardableResult
    public func openAPI<T>(custom keyPath: WritableKeyPath<OperationObject, T>, _ value: T) -> Route {
        var operation = operationObject
        operation[keyPath: keyPath] = value
        return set(\.operationObject, to: operation)
    }
    
    @discardableResult
    public func openAPI<T>(custom keyPath: WritableKeyPath<OperationObject, T>, _ value: (inout T) -> Void) -> Route {
        var operation = operationObject
        value(&operation[keyPath: keyPath])
        return set(\.operationObject, to: operation)
    }
}

extension Route {
    
    var operationObject: OperationObject {
        get {
            values.operationObject ?? OperationObject(
                description: description
            )
        }
        set {
            set(\.operationObject, to: newValue)
        }
    }
    
    var schemas: [String: ReferenceOr<SchemaObject>] {
        get { values.schemas ?? [:] }
        set { set(\.schemas, to: newValue) }
    }
    
    var excludeFromOpenApi: Bool {
        values.excludeFromOpenApi ?? false
    }
}
