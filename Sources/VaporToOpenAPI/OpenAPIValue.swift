import Foundation
import SwiftOpenAPI

enum OpenAPIValue {
    
    case example(Encodable)
    case type(Decodable.Type)
    case schema(SchemaObject)
    
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
    
    func mediaTypeObject(
        schemas: inout [String: ReferenceOr<SchemaObject>],
        examples: inout [String: ReferenceOr<ExampleObject>]
    ) throws -> MediaTypeObject {
        switch self {
        case .example(let encodable):
            return try .encode(encodable, schemas: &schemas, examples: &examples)
        case .type(let decodable):
            return try .decode(decodable, schemas: &schemas)
        case .schema(let schemaObject):
            return MediaTypeObject(schemaObject: schemaObject)
        }
    }
    
    func headers(
        schemas: inout [String: ReferenceOr<SchemaObject>]
    ) throws -> [String: ReferenceOr<HeaderObject>] {
        switch self {
        case .example(let encodable):
            return try .encode(encodable, schemas: &schemas)
        case .type(let decodable):
            return try .decode(decodable, schemas: &schemas)
        case .schema(let schemaObject):
            switch schemaObject.type {
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
        case .example(let encodable):
            return try .encode(encodable, in: location, dateFormat: dateFormat, schemas: &schemas)
        case .type(let decodable):
            return try .decode(decodable, in: location, dateFormat: dateFormat, schemas: &schemas)
        case .schema(let schemaObject):
            switch schemaObject.type {
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
