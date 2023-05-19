import Foundation
import SwiftOpenAPI

public struct OpenAPIBody {

	let value: OpenAPIValue

	/// Body schema based on the type.
	/// The method works fine for most types, however if the type contains non `CaseIterable` enams or the `init(from: Decoder)` contains custom validation
	/// then the schema may be generated invalid, in which case use `type(of:)` instead or implement `WithExample` protocol.
	/// Warning: Example is not generated from the type, to get the example use `type(of:)` instead or implement `WithExample` protocol.
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
	public static func schema(_ schema: SchemaObject) -> OpenAPIBody {
		OpenAPIBody(value: .schema(schema))
	}

	/// Body schema validates the value against all the subschemas
	public static func all(of types: OpenAPIBody..., discriminator: DiscriminatorObject? = nil) -> OpenAPIBody {
		OpenAPIBody(value: .composite(types.map(\.value), .allOf, discriminator: discriminator))
	}

	/// Body schema validates the value against any (one or more) of the subschemas
	public static func any(of types: OpenAPIBody..., discriminator: DiscriminatorObject? = nil) -> OpenAPIBody {
		OpenAPIBody(value: .composite(types.map(\.value), .anyOf, discriminator: discriminator))
	}

	/// Body schema validates the value against exactly one of the subschemas
	public static func one(of types: OpenAPIBody..., discriminator: DiscriminatorObject? = nil) -> OpenAPIBody {
		OpenAPIBody(value: .composite(types.map(\.value), .oneOf, discriminator: discriminator))
	}

	/// Body schema that does not match the subschema
	public static func not(_ type: OpenAPIBody) -> OpenAPIBody {
		OpenAPIBody(value: .composite([type.value], .not, discriminator: nil))
	}
}

public struct OpenAPIParameters {

	let value: OpenAPIValue

	/// Parameters based on the type.
	/// The method works fine for most types, however if the type contains non `CaseIterable` enams or the `init(from: Decoder)` contains custom validation
	/// then parameters may be generated invalid, in which case use `type(of:)` instead or implement `WithExample` protocol.
	/// Warning: Example is not generated from the type, to get the example use `type(of:)` instead or implement `WithExample` protocol.
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
	public static func schema(_ schema: SchemaObject) -> OpenAPIParameters {
		OpenAPIParameters(value: .schema(schema))
	}

	/// Combines parameters into one.
	public static func all(of types: OpenAPIParameters...) -> OpenAPIParameters {
		all(of: types)
	}

	/// Combines parameters into one.
	static func all(of types: [OpenAPIParameters]) -> OpenAPIParameters {
		var schemas: [String: ReferenceOr<SchemaObject>] = [:]
		var properties: [String: ReferenceOr<SchemaObject>] = [:]
		var required: Set<String> = []
		for type in types {
			switch try? type.value.schema(schemas: &schemas).object?.type {
			case let .object(props, req, _, _):
				properties.merge(props ?? [:]) { _, new in new }
				required.formUnion(req ?? [])
			default:
				continue
			}
		}
		return OpenAPIParameters(value: .schema(.object(properties: properties, required: required)))
	}
}

extension OpenAPIParameters: ExpressibleByArrayLiteral {

	public init(arrayLiteral elements: OpenAPIParameters...) {
		self = .all(of: elements)
	}
}

extension OpenAPIParameters: ExpressibleByDictionaryLiteral {
	
	public init(dictionaryLiteral elements: (String, ReferenceOr<SchemaObject>)...) {
		self = .schema(.object(properties: Dictionary(elements) { _, new in new }))
	}
}

indirect enum OpenAPIValue {

	case example(Encodable)
	case type(Decodable.Type)
	case schema(SchemaObject)
	case composite([OpenAPIValue], CompositeType, discriminator: DiscriminatorObject?)

	init(_ value: Any) {
		switch value {
		case let codable as Encodable:
			self = .example(codable)
		case let withExample as WithExample.Type:
			self = .example(withExample.example)
		case let type as Decodable.Type:
			self = .type(type)
		case let schema as SchemaObject:
			self = .schema(schema)
		default:
			self = .schema(.any)
		}
	}

	static func params(_ array: [Any]) -> OpenAPIValue? {
		array.nilIfEmpty.map {
			OpenAPIParameters.all(of: $0.map { OpenAPIParameters(value: OpenAPIValue($0)) }).value
		}
	}

	func schema(
		schemas: inout [String: ReferenceOr<SchemaObject>]
	) throws -> ReferenceOr<SchemaObject> {
		switch self {
		case let .example(encodable):
			return try .encodeSchema(encodable, into: &schemas)
		case let .type(decodable):
			return try .decodeSchema(decodable, into: &schemas)
		case let .schema(schemaObject):
			return .value(schemaObject)
		case let .composite(array, compositeType, discriminator):
			return try .value(
				SchemaObject(
					.composite(
						compositeType,
						array.map { try $0.schema(schemas: &schemas) },
						discriminator: discriminator
					)
				)
			)
		}
	}

	func mediaTypeObject(
		schemas: inout [String: ReferenceOr<SchemaObject>],
		examples: inout [String: ReferenceOr<ExampleObject>]
	) throws -> MediaTypeObject {
		switch self {
		case let .example(encodable):
			return try .encode(encodable, schemas: &schemas, examples: &examples)
		case .schema, .composite, .type:
			return try MediaTypeObject(schema: schema(schemas: &schemas))
		}
	}

	func headers(
		schemas: inout [String: ReferenceOr<SchemaObject>]
	) throws -> [String: ReferenceOr<HeaderObject>] {
		switch self {
		case let .example(encodable):
			return try .encode(encodable, schemas: &schemas)
		case let .type(decodable):
			return try .decode(decodable, schemas: &schemas)
		case .schema, .composite:
			switch try schema(schemas: &schemas).object?.type {
			case let .object(props, required, _, _):
				return Dictionary(
					uniqueKeysWithValues: props?.map {
						(
							$0.key,
							ReferenceOr<HeaderObject>.value(
								HeaderObject(
									description: $0.value.object?.description,
									required: required?.contains($0.key) == true,
									schema: $0.value
								)
							)
						)
					} ?? []
				)
			default:
				return [:]
			}
		}
	}

	func parameters(
		in location: ParameterObject.Location,
		dateFormat: DateEncodingFormat = .default,
		schemas: inout [String: ReferenceOr<SchemaObject>]
	) throws -> [ReferenceOr<ParameterObject>] {
		switch self {
		case let .example(encodable):
			return try .encode(encodable, in: location, dateFormat: dateFormat, schemas: &schemas)
		case let .type(decodable):
			return try .decode(decodable, in: location, dateFormat: dateFormat, schemas: &schemas)
		case .schema, .composite:
			switch try schema(schemas: &schemas).object?.type {
			case let .object(props, required, _, _):
				return props?.map {
					.value(
						ParameterObject(
							name: $0.key,
							in: location,
							description: $0.value.object?.description,
							required: location == .path || required?.contains($0.key) == true,
							schema: $0.value,
							example: $0.value.object?.example
						)
					)
				} ?? []
			default:
				return []
			}
		}
	}
}
