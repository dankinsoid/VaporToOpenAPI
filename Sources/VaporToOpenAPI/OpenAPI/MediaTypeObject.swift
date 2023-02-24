import Foundation

/// Each Media Type Object provides schema and examples for the media type identified by its key.
public struct MediaTypeObject: Codable, Equatable, SpecificationExtendable {
    
    /// The schema defining the content of the request, response, or parameter.
    public var schema: SchemaObject?
    
    /// Example of the media type.  The example object SHOULD be in the correct format as specified by the media type.  The `example` field is mutually exclusive of the `examples` field.  Furthermore, if referencing a `schema` which contains an example, the `example` value SHALL <em>override</em> the example provided by the schema.
    public var example: String?
    
    /// Examples of the media type.  Each example object SHOULD  match the media type and specified schema if present.  The `examples` field is mutually exclusive of the `example` field.  Furthermore, if referencing a `schema` which contains an example, the `examples` value SHALL <em>override</em> the example provided by the schema.
    public var examples: [String: ReferenceOr<ExampleObject>]?
    
    public init(
        schema: SchemaObject? = nil,
        example: Any? = nil,
        examples: [String: ReferenceOr<ExampleObject>]? = nil
    ) {
        self.schema = schema
        self.example = example
        self.examples = examples
    }
}

