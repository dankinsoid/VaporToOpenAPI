@_exported import SwiftOpenAPI
import Vapor

public extension Routes {

	/// Create ```OpenAPIObject```
	/// - Parameters:
	///   - spec: Specification identifier, used to group specifications
	///   - info: Provides metadata about the API. The metadata MAY be used by tooling as required.
	///   - jsonSchemaDialect: The default value for the $schema keyword within ```SchemaObjects``` contained within this OAS document.
	///   - servers: An array of ```ServerObject```, which provide connectivity information to a target server. If the servers property is not provided, or is an empty array, the default value would be a ```ServerObject``` with a url value of /.
	///   - paths: The available paths and operations for the API.
	///   - webhooks: The incoming webhooks that MAY be received as part of this API and that the API consumer MAY choose to implement.
	///   - components: An element to hold additional schemas for the document.
	///   - commonAuth: A declaration of which security mechanisms can be used across the API.
	///   - externalDocs: Additional external documentation.
	///   - errorExamples: Common error responses
	///   - errorType: Common error content type
	///   - errorHeaders: Common error headers
	///   - map: Closure to customise OpenAPI for each route
	/// - Returns: ```OpenAPIObject``` instance
	func openAPI(
		spec: String? = nil,
		info: InfoObject,
		jsonSchemaDialect: URL? = nil,
		servers: [ServerObject]? = nil,
		paths: PathsObject? = nil,
		webhooks: [String: ReferenceOr<PathItemObject>]? = nil,
		components: ComponentsObject = ComponentsObject(),
		commonAuth: [AuthSchemeObject]? = nil,
		externalDocs: ExternalDocumentationObject? = nil,
		errorExamples: [Int: Codable] = [:],
		errorDescriptions: [Int: String] = [:],
		errorType: MediaType...,
		errorHeaders: WithExample.Type...,
		map: (Route) -> Route = { $0 }
	) -> OpenAPIObject {
		let routes = all.map(map).filter { !$0.excludeFromOpenApi && $0.specID == spec }

		var openAPIObject = OpenAPIObject(
			info: info,
			jsonSchemaDialect: jsonSchemaDialect,
			servers: servers,
			paths: paths,
			webhooks: webhooks,
			components: components,
			security: securities(auth: commonAuth ?? []),
			tags: [],
			externalDocs: externalDocs
		)

		openAPIObject.addTags(routes: routes)
		openAPIObject.addPaths(routes: routes)
		openAPIObject.addSchemas(routes: routes)
		openAPIObject.addExamples(routes: routes)
		openAPIObject.addSecuritySchemes(routes: routes, commonAuth: commonAuth ?? [])
		openAPIObject.addErrors(
			errorExamples: errorExamples,
			errorDescriptions: errorDescriptions,
			errorTypes: errorType.nilIfEmpty ?? [.application(.json)],
			errorHeaders: errorHeaders
		)
		return openAPIObject
	}
}

private extension OpenAPIObject {

	mutating func addPaths(routes: [Route]) {
		if paths == nil {
			paths = PathsObject()
		}
		paths?.value.merge(
			Dictionary(
				routes.map {
					(
						Path($0.path),
						PathItemObject([$0.method.openAPI: $0.operationObject])
					)
				}
			) { f, s in
				PathItemObject(
					f.operations.merging(s.operations) { _, new in new }
				)
			}
			.mapValues(ReferenceOr.value)
		) { new, _ in new }

		addLinks(routes: routes)
	}

	mutating func addSecuritySchemes(
		routes: [Route],
		commonAuth: [AuthSchemeObject]
	) {
		if components == nil {
			components = ComponentsObject()
		}
		if components?.securitySchemes == nil {
			components?.securitySchemes = [:]
		}
		components?.securitySchemes?.merge(
			(routes.flatMap(\.auths) + commonAuth)
				.removeEquals
				.map { ($0.id, .value($0.scheme)) }
		) { n, _ in n }

		if components?.securitySchemes?.isEmpty == true {
			components?.securitySchemes = nil
		}
	}

	mutating func addSchemas(routes: [Route]) {
		addComponent(\.schemas, routes: routes, at: \.schemas)
	}
	
	mutating func addExamples(routes: [Route]) {
		addComponent(\.examples, routes: routes, at: \.examples)
	}
	
	mutating func addComponent<T>(_ componentKeyPath: WritableKeyPath<ComponentsObject, [String: T]?>, routes: [Route], at routeKeyPath: KeyPath<Route, [String: T]>) {
		var values = components?[keyPath: componentKeyPath] ?? [:]
		values = routes.reduce(into: values) { components, route in
			components.merge(route[keyPath: routeKeyPath]) { new, _ in new }
		}
		if components == nil {
			components = ComponentsObject()
		}
		components?[keyPath: componentKeyPath] = values.nilIfEmpty
	}

	mutating func addLinks(routes: [Route]) {
		var links: [LinkKeyObject: [(Link, Route)]] = [:]
		for route in routes {
			for (link, type) in route.links {
				links[type.object, default: []].append((link, route))
			}
		}
		var linkObjects: [String: ReferenceOr<LinkObject>] = [:]
		for (id, pairs) in links {
			let sourcePairs = pairs.filter { $0.0.location.isResponse }
			let targetPairs = pairs.filter { !$0.0.location.isResponse }

			guard !sourcePairs.isEmpty, !targetPairs.isEmpty else { continue }

			for sourcePair in sourcePairs {
				var refs: [String: ReferenceOr<LinkObject>] = [:]
				for targetPair in targetPairs {
					let name = [sourcePair.0.identifier, targetPair.1.operationID, targetPair.0.identifier].map(\.upFirst).joined()
					linkObjects[name] = .value(
						LinkObject(
							operationRef: nil,
							operationId: targetPair.1.operationObject.operationId ?? targetPair.1.operationID,
							parameters: [targetPair.0.name: .expression(sourcePair.0.expression)],
							requestBody: nil,
							description: id.type.description,
							server: id.type.server
						)
					)
					refs[name] = .ref(components: \.links, name)
				}

				let path = Path(sourcePair.1.path)
				let method = sourcePair.1.method.openAPI
				guard var response = paths?[path]?[method]?.responses?[200]?.object else { continue }
				response.links = response.links ?? [:]
				response.links?.merge(refs) { _, n in n }
				paths?[path]?[method]?.responses?[200] = .value(response)
			}
		}

		guard !linkObjects.isEmpty else { return }
		if components == nil {
			components = ComponentsObject()
		}
		if components?.links == nil {
			components?.links = [:]
		}
		components?.links?.merge(linkObjects) { n, _ in n }
	}

	mutating func addErrors(
		errorExamples: [Int: Codable],
		errorDescriptions: [Int: String],
		errorTypes: [MediaType],
		errorHeaders: [WithExample.Type]
	) {
		var schemas = components?.schemas ?? [:]
		var examples = components?.examples ?? [:]
		let errors = responses(
			default: nil,
			types: [.application(.json)],
			headers: [],
			errors: errorExamples,
			descriptions: errorDescriptions,
			errorTypes: errorTypes,
			errorHeaders: errorHeaders.map { $0.example as Codable },
			schemas: &schemas,
			examples: &examples
		)
		guard let errors else { return }

		var responses = components?.responses ?? [:]
		for (key, value) in errors.value {
			let keyName = errorKey(key)
			if responses[keyName] == nil {
				responses[keyName] = value
			}
		}
		let newPaths = paths?.value.mapValues { operations in
			guard var operations = operations.object else { return operations }
			operations.operations = operations.operations.mapValues { $0.withErrors(errors) }
			return .value(operations)
		}
		if let newPaths {
			paths = PathsObject(newPaths)
		}

		if components == nil {
			components = ComponentsObject()
		}
		components?.schemas = schemas
		components?.examples = examples
		components?.responses = responses
	}

	mutating func addTags(routes: [Route]) {
		tags = routes.flatMap(\.tags).removeEquals(\.name).nilIfEmpty
	}
}

private extension OperationObject {

	func withErrors(_ errors: ResponsesObject) -> OperationObject {
		var result = self
		result.responses = result.responses ?? [:]
		for key in errors.value.keys where result.responses?[key] == nil {
			result.responses?[key] = .ref(components: \.responses, errorKey(key))
		}
		return result
	}
}

private func errorKey(_ key: ResponsesObject.Key) -> String {
	"error-code-\(key.rawValue)"
}
