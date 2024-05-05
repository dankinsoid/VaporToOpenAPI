import SwiftOpenAPI
import Vapor

public extension Route {

	/// OpenAPI documentation for route
	/// - Parameters:
	///   - customMethod: Custom route method
	///   - spec: Specification identifier, used to group specifications
	///   - tags: A list of tags for API documentation control. Tags can be used for logical grouping of operations by resources or any other qualifier.
	///   - summary: A short summary of what the operation does.
	///   - description: A verbose explanation of the operation behavior. CommonMark syntax MAY be used for rich text representation.
	///   - operationId: Unique string used to identify the operation. The id MUST be unique among all operations described in the API. The operationId value is case-sensitive. Tools and libraries MAY use the operationId to uniquely identify an operation, therefore, it is RECOMMENDED to follow common programming naming conventions.
	///   - externalDocs: Additional external documentation for this operation.
	///   - query: Query parameters.
	///   - headers: Request headers.
	///   - path: Path parameters.
	///   - cookies: Cookie parameters.
	///   - body: Request body.
	///   - contentType: Request body content type.
	///   - response: Response body.
	///   - responseContentType: Response body content type.
	///   - responseHeaders: Response headers.
	///   - responseDescription: Response description.
	///   - statusCode: Response status code.
	///   - links: [Links](https://swagger.io/docs/specification/links).
	///   - callbacks: A map of possible out-of band callbacks related to the parent operation. The key is a unique identifier for the Callback Object. Each value in the map is a Callback Object that describes a request that may be initiated by the API provider and the expected responses. The key value used to identify the callback object is an expression, evaluated at runtime, that identifies a URL to use for the callback operation.
	///   - deprecated: Declares this operation to be deprecated. Usage of the declared operation should be refrained. Default value is false.
	///   - auth: Security requirements.
	///   - servers: An alternative ```ServerObject``` to service this operation.
	///   - extensions: Specification extensions.
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
		query: OpenAPIParameters? = nil,
		headers: OpenAPIParameters? = nil,
		path: OpenAPIParameters? = nil,
		cookies: OpenAPIParameters? = nil,
		body: OpenAPIBody? = nil,
		contentType: MediaType...,
		response: OpenAPIBody? = nil,
		responseContentType: MediaType...,
		responseHeaders: OpenAPIParameters? = nil,
		responseDescription: String? = nil,
		statusCode: ResponsesObject.Key = 200,
		links: [Link: LinkKey.Type] = [:],
		callbacks: [String: ReferenceOr<CallbackObject>]? = nil,
		deprecated: Bool? = nil,
		auth: AuthSchemeObject...,
		servers: [ServerObject]? = nil,
		extensions: SpecificationExtensions = [:]
	) -> Route {
		_openAPI(
			method: customMethod,
			spec: spec,
			tags: tags,
			summary: summary,
			description: description,
			operationId: operationId,
			externalDocs: externalDocs,
			query: query?.value,
			headers: headers?.value,
			path: path?.value,
			cookies: cookies?.value,
			body: body?.value,
			bodyTypes: contentType,
			response: response?.value,
			responseContentType: responseContentType,
			responseHeaders: responseHeaders?.value,
			responseDescription: responseDescription,
			statusCode: statusCode,
			links: links,
			callbacks: callbacks,
			deprecated: deprecated,
			auth: auth,
			servers: servers,
			extensions: extensions
		)
	}

	/// Additional response for OpenAPI operation
	/// - Parameters:
	///  - statusCode: Response status code
	///  - body: Response body.
	///  - contentType: Response body content type
	///  - headers: Response headers
	///  - description: Response description
	@discardableResult
	func response(
		statusCode: ResponsesObject.Key = 200,
		body: OpenAPIBody? = nil,
		contentType: MediaType...,
		headers: OpenAPIParameters? = nil,
		description: String? = nil
	) -> Route {
		_response(
			spec: specID,
			statusCode: statusCode,
			body: body?.value,
			contentTypes: contentType,
			headers: headers?.value,
			description: description
		)
	}

	/// OpenAPI operation object
	/// - Parameters:
	///   - customMethod: Custom route method
	///   - spec: Specification identifier, used to group specifications
	///   - tags: A list of tags for API documentation control. Tags can be used for logical grouping of operations by resources or any other qualifier.
	///   - summary: A short summary of what the operation does.
	///   - description: A verbose explanation of the operation behavior. CommonMark syntax MAY be used for rich text representation.
	///   - externalDocs: Additional external documentation for this operation.
	///   - query: Query parameters. `Encodable` example, `Decodable.Type`, `WithExample.Type` and `SchemaObject` are allowed
	///   - headers: Request headers. `Encodable` example, `Decodable.Type`, `WithExample.Type` and `SchemaObject` are allowed
	///   - path: Path parameters. `Encodable` example, `Decodable.Type`, `WithExample.Type` and `SchemaObject` are allowed
	///   - cookies: Cookie parameters. `Encodable` example, `Decodable.Type`, `WithExample.Type` and `SchemaObject` are allowed
	///   - body: Request body. `Encodable` example, `Decodable.Type`, `WithExample.Type` and `SchemaObject` are allowed
	///   - bodyType: Request body content type
	///   - response: Response body. `Encodable` example, `Decodable.Type`, `WithExample.Type` and `SchemaObject` are allowed
	///   - responseType: Response body content type
	///   - responseHeaders: Response headers
	///   - errorResponses: Error responses example. `Encodable` example, `Decodable.Type`, `WithExample.Type` and `SchemaObject` are allowed
	///   - errorType: Error response content type
	///   - errorHeaders: Error response headers. `Encodable` example, `Decodable.Type`, `WithExample.Type` and `SchemaObject` are allowed
	///   - callbacks: A map of possible out-of band callbacks related to the parent operation. The key is a unique identifier for the Callback Object. Each value in the map is a Callback Object that describes a request that may be initiated by the API provider and the expected responses. The key value used to identify the callback object is an expression, evaluated at runtime, that identifies a URL to use for the callback operation.
	///   - deprecated: Declares this operation to be deprecated. Usage of the declared operation should be refrained. Default value is false.
	///   - auth: Security requirements
	///   - authScopes: Security scopes
	///   - servers: An alternative ```ServerObject``` to service this operation.
	/// - Returns: ```Route``` instance
	@_disfavoredOverload
	@available(*, deprecated, message: "Use new `openAPI` and `response` methods")
	@discardableResult
	func openAPI(
		customMethod: PathItemObject.Method? = nil,
		spec: String? = nil,
		tags: TagObject...,
		summary: String? = nil,
		description: String = "",
		operationId: String? = nil,
		externalDocs: ExternalDocumentationObject? = nil,
		query: Any...,
		headers: Any...,
		path: Any...,
		cookies: Any...,
		body: Any? = nil,
		bodyType: MediaType...,
		response: Any? = nil,
		responseType: MediaType...,
		responseHeaders: Any...,
		successStatusCode: ResponsesObject.Key = 200,
		errorResponses: [Int: Any] = [:],
		errorDescriptions: [Int: String] = [:],
		errorType: MediaType...,
		errorHeaders: Any...,
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
			query: OpenAPIValue.params(query),
			headers: OpenAPIValue.params(headers),
			path: OpenAPIValue.params(path),
			cookies: OpenAPIValue.params(cookies),
			body: body.flatMap { OpenAPIValue($0) },
			bodyTypes: bodyType,
			response: response.flatMap { OpenAPIValue($0) },
			responseContentType: responseType,
			responseHeaders: OpenAPIValue.params(responseHeaders),
			responseDescription: successStatusCode.intValue.flatMap { errorDescriptions[$0] },
			statusCode: successStatusCode,
			links: links,
			callbacks: callbacks,
			deprecated: deprecated,
			auth: auth,
			servers: servers,
			extensions: [:]
		)
		.openAPI(custom: \.responses) { value in
			value = responses(
				current: value,
				responses: errorResponses.mapKeys(ResponsesObject.Key.code) { OpenAPIValue($0) }.compactMapValues { $0 },
				descriptions: errorDescriptions.mapKeys(ResponsesObject.Key.code),
				types: errorResponses.mapKeys(ResponsesObject.Key.code) { _ in errorType },
				headers: OpenAPIValue.params(errorHeaders).map { headers in
					errorResponses.mapKeys(ResponsesObject.Key.code) { _ in headers }
				} ?? [:],
				schemas: &schemas[spec, default: [:]],
				examples: &Route.examples[spec, default: [:]]
			)
		}
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

	func _openAPI(
		method: PathItemObject.Method?,
		spec: String?,
		tags: [TagObject],
		summary: String?,
		description: String,
		operationId: String?,
		externalDocs: ExternalDocumentationObject?,
		query: OpenAPIValue?,
		headers: OpenAPIValue?,
		path: OpenAPIValue?,
		cookies: OpenAPIValue?,
		body: OpenAPIValue?,
		bodyTypes: [MediaType],
		response: OpenAPIValue?,
		responseContentType: [MediaType],
		responseHeaders: OpenAPIValue?,
		responseDescription: String?,
		statusCode: ResponsesObject.Key,
		links: [Link: LinkKey.Type],
		callbacks: [String: ReferenceOr<CallbackObject>]?,
		deprecated: Bool?,
		auth: [AuthSchemeObject],
		servers: [ServerObject]?,
		extensions: SpecificationExtensions
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
					try? query?.parameters(in: .query, schemas: &schemas[spec, default: [:]]),
					try? headers?.parameters(in: .header, schemas: &schemas[spec, default: [:]]),
					(try? path?.parameters(in: .path, schemas: &schemas[spec, default: [:]]))?.nilIfEmpty ?? pathParameters,
					try? cookies?.parameters(in: .cookie, schemas: &schemas[spec, default: [:]]),
				]
				.flatMap { $0 ?? [] }
				.nilIfEmpty,
				requestBody: request(
					body: body,
					description: nil,
					required: true,
					types: bodyTypes,
					schemas: &schemas[spec, default: [:]],
					examples: &Route.examples[spec, default: [:]]
				),
				responses: operationObject.responses,
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
		.openAPI(custom: \.specificationExtensions) {
			$0 = SpecificationExtensions(fields: extensions.fields.merging($0?.fields ?? [:]) { new, _ in new })
			if $0?.fields.isEmpty == true {
				$0 = nil
			}
		}
		._response(
			spec: spec,
			statusCode: statusCode,
			body: response,
			contentTypes: responseContentType.nilIfEmpty ?? response.map { [self.responseContentType(for: $0)] } ?? [],
			headers: responseHeaders,
			description: responseDescription
		)
	}

	func _response(
		spec: String?,
		statusCode: ResponsesObject.Key = 200,
		body: OpenAPIValue? = nil,
		contentTypes: [MediaType],
		headers: OpenAPIValue? = nil,
		description: String? = nil
	) -> Route {
		openAPI(custom: \.responses) { value in
			value = responses(
				current: value,
				responses: body.map { [statusCode: $0] } ?? [:],
				descriptions: description.map { [statusCode: $0] } ?? [:],
				types: [statusCode: contentTypes],
				headers: headers.map { [statusCode: $0] } ?? [:],
				schemas: &schemas[spec, default: [:]],
				examples: &Route.examples[spec, default: [:]]
			)
		}
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

	var pathParameters: ParametersList {
		path.compactMap(\.pathParameter)
	}

	var operationObject: OperationObject {
		get {
			values.operationObject ?? OperationObject(
				tags: tags.map(\.name).nilIfEmpty ?? path.prefix(1).map(\.description),
				description: description
			)
		}
		set {
			set(\.operationObject, to: newValue)
		}
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

	var bodyResponseType: Any.Type {
		(responseType as? EventLoopType.Type)?.valueType ?? responseType
	}

	var schemas: [String?: ComponentsMap<SchemaObject>] {
		get {
			values.schemas ?? [nil: [:]]
		}
		set {
			values.schemas = newValue
		}
	}

	var openAPIResponseType: OpenAPIValue? {
		switch bodyResponseType {
		case let withExample as WithExample.Type:
			return .example(withExample.example)
		case let openAPIType as OpenAPIType.Type:
			return .schema(openAPIType.openAPISchema)
		case _ as Response.Type:
			return nil
		case _ as Request.Type:
			return nil
		case let decodable as Decodable.Type:
			return .type(decodable)
		default:
			return nil
		}
	}

	var defaultResponseContentType: MediaType {
		responseContentType(for: bodyResponseType)
	}

	func responseContentType(for value: OpenAPIValue) -> MediaType {
		switch value {
		case let .type(type):
			return responseContentType(for: type)
		case let .example(value):
			return responseContentType(for: Swift.type(of: value))
		case let .schema(object):
			switch object.context {
			case .array, .object:
				return .application(.json)
			case nil:
				return .any
			case let .composition(context):
				let schemas = context.allOf ?? context.anyOf ?? context.oneOf ?? context.not.map { [$0] } ?? []
				return responseContentType(for: schemas.compactMap(\.object).map { .schema($0) })
			case .string, .boolean, .integer, .number:
				switch object.format {
				case "html":
					return .text(.html)
				default:
					return .text(.plain)
				}
			}
		case let .composite(values, _, _):
			return responseContentType(for: values)
		case .parameters:
			return .application(.json)
		}
	}

	func responseContentType(for values: [OpenAPIValue]) -> MediaType {
		guard !values.isEmpty else {
			return .any
		}
		let type = responseContentType(for: values[0])
		var i = 1
		while i < values.count, responseContentType(for: values[i]) == type {
			i += 1
		}
		return i == values.count ? type : .any
	}

	func responseContentType(for type: Any.Type) -> MediaType {
		switch type {
		case let custom as CustomContentType.Type:
			return custom.contentType
		default:
			return .application(.json)
		}
	}
}

extension Route {

	static var examples: [String?: ComponentsMap<ExampleObject>] = [nil: [:]]
}
