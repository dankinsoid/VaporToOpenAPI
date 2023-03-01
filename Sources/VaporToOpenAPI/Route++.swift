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
        requestBody: WithExample.Type? = nil,
        response: WithExample.Type? = nil,
        errorResponses: [Int: WithExample.Type] = [:],
        callbacks: [String: ReferenceOr<CallbackObject>]? = nil,
        deprecated: Bool? = nil,
        security: [SecurityRequirementObject]? = nil,
        servers: [ServerObject]? = nil
    ) -> Route {
        set(
            \.operationObject,
            to: OperationObject(
                tags: tags,
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
                ].flatMap { $0 ?? [] },
                requestBody: requestBody.flatMap {
                    try? .value(
                        RequestBodyObject(
                            description: nil,
                            content: [
                                .application(.json): .encode($0.example, schemas: &schemas)
                            ],
                            required: nil
                        )
                    )
                },
                responses: ResponsesObject(
                    (
                        response.flatMap {
                            try? [
                                .default: .value(
                                    ResponseObject(
                                        description: String(describing: $0),
                                        headers: nil,
                                        content: [
                                            .application(.json): .encode($0.example, schemas: &schemas)
                                        ],
                                        links: nil
                                    )
                                )
                            ]
                        } ?? [:]
                    ).merging(
                        Dictionary(
                            errorResponses.compactMap {
                                try? (
                                    ResponsesObject.Key.code($0.key),
                                    .value(
                                        ResponseObject(
                                            description: "",
                                            headers: nil,
                                            content: [
                                                .application(.json): .encode($0.value.example, schemas: &schemas)
                                            ],
                                            links: nil
                                        )
                                    )
                                )
                            }
                        ) { _, new in new }
                    ) { _, new in new }
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
        values.operationObject ?? OperationObject(
        		description: description
        )
    }
    
    var schemas: [String: ReferenceOr<SchemaObject>] {
        get { values.schemas ?? [:] }
        set { set(\.schemas, to: newValue) }
    }
    
    var excludeFromOpenApi: Bool {
        values.excludeFromOpenApi ?? false
    }
}
