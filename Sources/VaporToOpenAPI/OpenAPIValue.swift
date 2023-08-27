import Foundation
import SwiftOpenAPI
import OpenAPIKit

public struct OpenAPIBody {

	let value: OpenAPIValue

	/// Body schema based on the type.
	///
	/// The method works fine for most types, however if the type contains non `CaseIterable` enams or the `init(from: Decoder)` contains custom validation
	/// then the schema may be generated invalid, in which case use `type(of:)` instead or implement `WithExample` protocol.
	/// - Warning: Example is not generated from the type, to get the example use `type(of:)` instead or implement `WithExample` protocol.
	public static func type(_ type: Decodable.Type) -> OpenAPIBody {
		OpenAPIBody(value: .type(type))
	}

	/// Body schema with example based on the type.
	public static func type(_ type: WithExample.Type) -> OpenAPIBody {
		OpenAPIBody(value: .example(type.example))
	}

	/// Body schema based on the example.
	public static func type(of example: Encodable) -> OpenAPIBody {
		OpenAPIBody(value: .example(example))
	}

	/// Custom body schema.
	public static func schema(_ schema: JSONSchema) -> OpenAPIBody {
		OpenAPIBody(value: .schema(schema))
	}

	/// Body schema validates the value against all the subschemas
    public static func all(of types: OpenAPIBody..., discriminator: OpenAPI.Discriminator? = nil) -> OpenAPIBody {
        OpenAPIBody(value: .allOf(types.map(\.value), discriminator: discriminator))
	}

	/// Body schema validates the value against any (one or more) of the subschemas
	public static func any(of types: OpenAPIBody..., discriminator: OpenAPI.Discriminator? = nil) -> OpenAPIBody {
		OpenAPIBody(value: .anyOf(types.map(\.value), discriminator: discriminator))
	}

	/// Body schema validates the value against exactly one of the subschemas
	public static func one(of types: OpenAPIBody..., discriminator: OpenAPI.Discriminator? = nil) -> OpenAPIBody {
		OpenAPIBody(value: .oneOf(types.map(\.value), discriminator: discriminator))
	}

	/// Body schema that does not match the subschema
	public static func not(_ type: OpenAPIBody) -> OpenAPIBody {
		OpenAPIBody(value: .not(type.value))
	}
}

public struct OpenAPIParameters {

	let value: OpenAPIValue

	/// Parameters based on the type.
	///
	/// The method works fine for most types, however if the type contains non `CaseIterable` enams or the `init(from: Decoder)` contains custom validation
	/// then parameters may be generated invalid, in which case use `type(of:)` instead or implement `WithExample` protocol.
	/// - Warning: Example is not generated from the type, to get the example use `type(of:)` instead or implement `WithExample` protocol.
	public static func type(_ type: Decodable.Type) -> OpenAPIParameters {
		OpenAPIParameters(value: .type(type))
	}

	/// Parameters with examples based on the type.
	public static func type(_ type: WithExample.Type) -> OpenAPIParameters {
		OpenAPIParameters(value: .example(type.example))
	}

	/// Parameters based on the example.
	public static func type(of example: Encodable) -> OpenAPIParameters {
		OpenAPIParameters(value: .example(example))
	}

	/// Custom parameters.
	public static func schema(_ schema: JSONSchema) -> OpenAPIParameters {
		OpenAPIParameters(value: .schema(schema))
	}

	/// Combines parameters into one.
	public static func all(of types: OpenAPIParameters...) -> OpenAPIParameters {
		all(of: types)
	}

	/// Combines parameters into one.
	static func all(of types: [OpenAPIParameters]) -> OpenAPIParameters {
		var schemas: OpenAPI.ComponentDictionary<JSONSchema> = [:]
        
		var properties: OpenAPI.Parameter.Array = []
		for type in types {
			guard let params = try? type.value.parameters(in: .query, schemas: &schemas) else {
				continue
			}
            properties += params
		}
		return OpenAPIParameters(value: .parameters(properties))
	}
}

extension OpenAPIParameters: ExpressibleByArrayLiteral {

	public init(arrayLiteral elements: OpenAPIParameters...) {
		self = .all(of: elements)
	}
}

extension OpenAPIParameters: ExpressibleByDictionaryLiteral {

	public init(dictionaryLiteral elements: (String, JSONSchema)...) {
		value = .parameters(
			elements.reduce(into: []) { result, element in
                result.append(.b(OpenAPI.Parameter(name: element.0, context: .query, schema: element.1)))
			}
		)
	}
}

indirect enum OpenAPIValue {

	case example(Encodable)
	case type(Decodable.Type)
	case schema(JSONSchema)
    case parameters(OpenAPI.Parameter.Array)
    case allOf([OpenAPIValue], discriminator: OpenAPI.Discriminator?)
    case anyOf([OpenAPIValue], discriminator: OpenAPI.Discriminator?)
    case oneOf([OpenAPIValue], discriminator: OpenAPI.Discriminator?)
    case not(OpenAPIValue)

	init?(_ value: Any) {
		switch value {
		case let codable as Encodable:
			self = .example(codable)
		case let withExample as WithExample.Type:
			self = .example(withExample.example)
		case let type as Decodable.Type:
			self = .type(type)
		case let schema as JSONSchema:
			self = .schema(schema)
		default:
			return nil
		}
	}

	static func params(_ array: [Any]) -> OpenAPIValue? {
		array.nilIfEmpty.map { array in
			OpenAPIParameters.all(
				of: array.compactMap { item in
					OpenAPIValue(item).map { OpenAPIParameters(value: $0) }
				}
			).value
		}
	}

	func schema(
		schemas: inout OpenAPI.ComponentDictionary<JSONSchema>
	) throws -> JSONSchema {
        switch self {
        case let .example(encodable):
            return try .encode(encodable, into: &schemas)
        case let .type(decodable):
            return try .decode(decodable, into: &schemas)
        case let .schema(schemaObject):
            return schemaObject
        case let .parameters(properties):
            return .object(
                properties: OrderedDictionary(
                    properties.compactMap { props -> (String, JSONSchema)? in
                        guard let param = props.b else { return nil }
                        return (param.schemaOrContent.a?.schema.b).map {
                            (param.name, $0)
                        }
                    }
                ) { _, new in new }
            )
        case let .oneOf(array, discriminator):
            return try .one(
                of: array.map { try $0.schema(schemas: &schemas) },
                core: .init(discriminator: discriminator)
            )
        case let .allOf(array, discriminator):
            return try .all(
                of: array.map { try $0.schema(schemas: &schemas) },
                core: .init(discriminator: discriminator)
            )
        case let .anyOf(array, discriminator):
            return try .any(
                of: array.map { try $0.schema(schemas: &schemas) },
                core: .init(discriminator: discriminator)
            )
        case let .not(value):
            return try .not(value.schema(schemas: &schemas))
        }
	}

	func content(
		schemas: inout OpenAPI.ComponentDictionary<JSONSchema>,
		examples: inout OpenAPI.ComponentDictionary<OpenAPI.Example>
	) throws -> OpenAPI.Content {
		switch self {
		case let .example(encodable):
			return try .encode(encodable, schemas: &schemas, examples: &examples)
		case .schema, .composite, .type, .parameters:
			return try OpenAPI.Content(schema: schema(schemas: &schemas))
		}
	}

	func headers(
		schemas: inout OpenAPI.ComponentDictionary<JSONSchema>
	) throws -> OpenAPI.Header.Map {
		switch self {
		case let .example(encodable):
			return try .encode(encodable, schemas: &schemas)
		case let .type(decodable):
			return try .decode(decodable, schemas: &schemas)
		case .schema, .composite:
			switch try schema(schemas: &schemas).object?.context {
			case let .object(context):
				return OrderedDictionary(
					context.properties?.map {
						(
							$0.key,
							ReferenceOr<OpenAPI.Header>.value(
								OpenAPI.Header(
									description: $0.value.object?.description,
									required: context.required?.contains($0.key) == true,
									schema: $0.value
								)
							)
						)
					} ?? []
				) { _, n in n }
			default:
				return [:]
			}
		case let .parameters(properties):
			return properties.mapValues {
				.value(
					OpenAPI.Header(
						description: $0.description,
						required: $0.required,
						schema: $0.schema,
						example: $0.example,
						examples: $0.examples
					)
				)
			}
		}
	}

	func parameters(
        in location: OpenAPI.Parameter.Context.Location,
		dateFormat: DateEncodingFormat = .default,
		schemas: inout OpenAPI.ComponentDictionary<JSONSchema>
	) throws -> OpenAPI.Parameter.Array {
		switch self {
		case let .example(encodable):
			return try .encode(encodable, in: location, dateFormat: dateFormat, schemas: &schemas)
		case let .type(decodable):
			return try .decode(decodable, in: location, dateFormat: dateFormat, schemas: &schemas)
		case .schema, .composite:
			switch try schema(schemas: &schemas).object?.context {
			case let .object(context):
				return context.properties?
					.map {
						.value(
							OpenAPI.Parameter(
								name: $0.key,
								in: location,
								description: $0.value.object?.description,
								required: location == .path || context.required?.contains($0.key) == true,
								schema: $0.value,
								example: $0.value.object?.example
							)
						)
					} ?? []
			default:
				return []
			}
		case let .parameters(parameters):
			return parameters
				.map {
					var result = $0.value
					result.context = location
					return .value(result)
				}
		}
	}
}
