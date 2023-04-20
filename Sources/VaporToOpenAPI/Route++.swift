import SwiftOpenAPI
import Vapor

public extension Route {

	/// OpenAPI operation object
	/// - Parameters:
    ///   - customMethod: Custom route method
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
	func openAPI(
        customMethod: PathItemObject.Method? = nil,
		spec: String? = nil,
		tags: TagObject...,
		summary: String? = nil,
		description: String = "",
		operationId: String? = nil,
		externalDocs: ExternalDocumentationObject? = nil,
		query: Codable...,
		headers: Codable...,
		path: Codable...,
		cookies: Codable...,
		body: Codable? = nil,
		bodyType: MediaType...,
		response: Codable? = nil,
		responseType: MediaType...,
		responseHeaders: Codable...,
		errorResponses: [Int: Codable] = [:],
		errorDescriptions: [Int: String] = [:],
		errorType: MediaType...,
		errorHeaders: Codable...,
		links: [Link: LinkKey.Type] = [:],
		callbacks: [String: ReferenceOr<CallbackObject>]? = nil,
		deprecated: Bool? = nil,
		auth: AuthSchemeObject...,
		servers: [ServerObject]? = nil
	) -> Route {
		_openAPI(
            method: customMethod,
			spec: spec,
			tags: tags,
			summary: summary,
			description: description,
			operationId: operationId,
			externalDocs: externalDocs,
			query: query,
			headers: headers,
			path: path,
			cookies: cookies,
			body: body,
			bodyTypes: bodyType.nilIfEmpty ?? [.application(.json)],
			response: response,
			responseTypes: responseType.nilIfEmpty ?? [.application(.json)],
			responseHeaders: responseHeaders,
			errorResponses: errorResponses,
			errorDescriptions: errorDescriptions,
			errorTypes: errorType.nilIfEmpty ?? [.application(.json)],
			errorHeaders: errorHeaders,
			links: links,
			callbacks: callbacks,
			deprecated: deprecated,
			auth: auth,
			servers: servers
		)
	}

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
	private func _openAPI(
        method: PathItemObject.Method?,
		spec: String?,
		tags: [TagObject],
		summary: String?,
		description: String,
		operationId: String?,
		externalDocs: ExternalDocumentationObject?,
		query: [Codable],
		headers: [Codable],
		path: [Codable],
		cookies: [Codable],
		body: Codable?,
		bodyTypes: [MediaType],
		response: Codable?,
		responseTypes: [MediaType],
		responseHeaders: [Codable],
		errorResponses: [Int: Codable],
		errorDescriptions: [Int: String],
		errorTypes: [MediaType],
		errorHeaders: [Codable],
		links: [Link: LinkKey.Type],
		callbacks: [String: ReferenceOr<CallbackObject>]?,
		deprecated: Bool?,
		auth: [AuthSchemeObject],
		servers: [ServerObject]?
	) -> Route {
		let newTags = (self.tags + tags).removeEquals(\.name).nilIfEmpty ?? self.path.prefix(1).map { TagObject(name: $0.description) }
		return set(
			\.operationObject,
			to: OperationObject(
				tags: newTags.map(\.name),
				summary: summary,
				description: description,
				externalDocs: externalDocs,
				operationId: operationId ?? operationID,
				parameters: [
					try? query.flatMap {
						try [ReferenceOr<ParameterObject>].encode($0, in: .query, schemas: &schemas)
					},
					try? headers.flatMap {
						try [ReferenceOr<ParameterObject>].encode($0, in: .header, schemas: &schemas)
					},
					(
						try? path.flatMap {
							try [ReferenceOr<ParameterObject>].encode($0, in: .path, schemas: &schemas)
						}
					)?.nilIfEmpty ?? pathParameters,
					try? cookies.flatMap {
						try [ReferenceOr<ParameterObject>].encode($0, in: .cookie, schemas: &schemas)
					},
				]
				.flatMap { $0 ?? [] }
				.nilIfEmpty,
				requestBody: request(
					body: body,
					description: nil,
					required: true,
					types: bodyTypes,
					schemas: &schemas,
					examples: &examples
				),
				responses: responses(
					default: response,
					types: responseTypes,
					headers: responseHeaders,
					errors: errorResponses,
					descriptions: errorDescriptions,
					errorTypes: errorTypes,
					errorHeaders: errorHeaders,
					schemas: &schemas,
					examples: &examples
				),
				callbacks: callbacks,
				deprecated: deprecated,
				security: operationObject.security,
				servers: servers
			)
		)
		.description(description)
		.setNew(auth: auth)
		.set(\.specID, to: spec ?? specID)
		.set(\.links, to: links)
		.set(\.tags, to: newTags)
        .set(\.openAPIMethod, to: method)
	}

	/// Exclude route from OpenAPI specification
	@discardableResult
	func excludeFromOpenAPI() -> Route {
		set(\.excludeFromOpenApi, to: true)
	}

	/// Set OpenAPI empty security requirements
	@discardableResult
	func openAPINoAuth() -> Route {
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
	func openAPI<T>(custom keyPath: WritableKeyPath<OperationObject, T>, _ value: T) -> Route {
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
	func openAPI<T>(custom keyPath: WritableKeyPath<OperationObject, T>, _ value: (inout T) -> Void) -> Route {
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
	
	var examples: [String: ReferenceOr<ExampleObject>] {
		get { values.examples ?? [:] }
		set { set(\.examples, to: newValue) }
	}

	var auths: [AuthSchemeObject] {
		get { values.auths ?? [] }
		set { set(\.auths, to: newValue) }
	}
	
	var tags: [TagObject] {
		values.tags ?? []
	}
    
    var openAPIMethod: PathItemObject.Method {
        values.openAPIMethod ?? method.openAPI
    }

	var excludeFromOpenApi: Bool {
		values.excludeFromOpenApi ?? false
	}

	var specID: String? {
		values.specID ?? nil
	}

	var links: [Link: LinkKey.Type] {
		values.links ?? [:]
	}
}
