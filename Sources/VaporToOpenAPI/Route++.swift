import Vapor
import SwiftOpenAPI

extension Route {

    /// OpenAPI operation object
    /// - Parameters:
    ///   - spec: Specification identifier, used to group specifications
    ///   - tags: A list of tags for API documentation control. Tags can be used for logical grouping of operations by resources or any other qualifier.
    ///   - summary: A short summary of what the operation does.
    ///   - description: A verbose explanation of the operation behavior. CommonMark syntax MAY be used for rich text representation.
    ///   - externalDocs: Additional external documentation for this operation.
    ///   - query: Query parameters
    ///   - headers: Request headers
    ///   - path: Path parameters
    ///   - cookies: Cookie parameters
    ///   - body: Request body
    ///   - bodyType: Request body content type
    ///   - response: Response body
    ///   - responseType: Response body content type
    ///   - responseHeaders: Response headers
    ///   - errorResponses: Error responses example
    ///   - errorType: Error response content type
    ///   - errorHeaders: Error response headers
    ///   - callbacks: A map of possible out-of band callbacks related to the parent operation. The key is a unique identifier for the Callback Object. Each value in the map is a Callback Object that describes a request that may be initiated by the API provider and the expected responses. The key value used to identify the callback object is an expression, evaluated at runtime, that identifies a URL to use for the callback operation.
    ///   - deprecated: Declares this operation to be deprecated. Usage of the declared operation should be refrained. Default value is false.
    ///   - auth: Security requirements
    ///   - authScopes: Security scopes
    ///   - servers: An alternative ```ServerObject``` to service this operation.
    /// - Returns: ```Route``` instance
    @discardableResult
    public func openAPI(
        spec: String? = nil,
        tags: [String]? = nil,
        summary: String? = nil,
        description: String = "",
        externalDocs: ExternalDocumentationObject? = nil,
        query: WithExample.Type...,
        headers: WithExample.Type...,
        path: WithExample.Type...,
        cookies: WithExample.Type...,
        body: WithExample.Type? = nil,
        bodyType: MediaType = .application(.json),
        response: WithExample.Type? = nil,
        responseType: MediaType = .application(.json),
        responseHeaders: WithExample.Type...,
        errorResponses: [Int: Codable] = [:],
        errorType: MediaType = .application(.json),
        errorHeaders: WithExample.Type...,
        callbacks: [String: ReferenceOr<CallbackObject>]? = nil,
        deprecated: Bool? = nil,
        auth: SecuritySchemeObject...,
        authScopes: [String] = [],
        servers: [ServerObject]? = nil
    ) -> Route {
        set(
            \.operationObject,
            to: OperationObject(
                tags: ((operationObject.tags ?? []) + (tags ?? self.path.prefix(1).map(\.description.upFirst))).removeEquals,
                summary: summary,
                description: description,
                externalDocs: externalDocs,
                operationId: operationID,
                parameters: [
                    try? query.flatMap {
                        try [ReferenceOr<ParameterObject>].encode($0.example, in: .query, schemas: &schemas)
                    },
                    try? headers.flatMap {
                        try [ReferenceOr<ParameterObject>].encode($0.example, in: .header, schemas: &schemas)
                    },
                    (
                        try? path.flatMap {
                            try [ReferenceOr<ParameterObject>].encode($0.example, in: .path, schemas: &schemas)
                        }
                    )?.nilIfEmpty ?? pathParameters,
                    try? cookies.flatMap {
                        try [ReferenceOr<ParameterObject>].encode($0.example, in: .cookie, schemas: &schemas)
                    }
                ]
                    .flatMap { $0 ?? [] }
                    .nilIfEmpty,
                requestBody: request(
                    body: body,
                    description: nil,
                    required: true,
                    type: bodyType,
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
                security: operationObject.security,
                servers: servers
             )
        )
        .description(description)
        .setNew(auth: auth, scopes: authScopes)
        .set(\.specID, to: spec ?? specID)
    }

    /// Exclude route from OpenAPI specification
    @discardableResult
    public func excludeFromOpenAPI() -> Route {
        set(\.excludeFromOpenApi, to: true)
    }

    /// Set OpenAPI empty security requirements
    @discardableResult
    public func openAPINoAuth() -> Route {
        set(\.auths, to: [])
            .openAPI(custom: \.security, nil)
    }

    /// Customize OpenAPI operation
    ///
    /// - Parameters:
    ///   - keyPath: Key path to property
    ///   - value: Property value
    /// - Returns: ```Route``` instance
    @discardableResult
    public func openAPI<T>(custom keyPath: WritableKeyPath<OperationObject, T>, _ value: T) -> Route {
        var operation = operationObject
        operation[keyPath: keyPath] = value
        return set(\.operationObject, to: operation)
    }

    /// Customize OpenAPI operation
    ///
    /// - Parameters:
    ///   - keyPath: Key path to property
    ///   - value: Closure to modify property value
    /// - Returns: ```Route``` instance
    @discardableResult
    public func openAPI<T>(custom keyPath: WritableKeyPath<OperationObject, T>, _ value: (inout T) -> Void) -> Route {
        var operation = operationObject
        value(&operation[keyPath: keyPath])
        return set(\.operationObject, to: operation)
    }
}

extension Route {

    /// OpenAPI operation ID
    public var operationID: String {
        "\(method.rawValue.lowercased())\(path.map(\.name.upFirst).joined())"
    }

    /// OpenAPI operation reference
    public var operationRef: String {
        "#paths/\(Path(path).stringValue.replacingOccurrences(of: "/", with: "~1"))/\(method.rawValue.lowercased())"
    }
   
    var pathParameters: [ReferenceOr<ParameterObject>] {
        path.compactMap(\.pathParameter)
    }
    
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
    
    var auths: [SecuritySchemeObject] {
        get { values.auths ?? [] }
        set { set(\.auths, to: newValue) }
    }
    
    var excludeFromOpenApi: Bool {
        values.excludeFromOpenApi ?? false
    }
    
    var specID: String? {
        values.specID ?? nil
    }
}
