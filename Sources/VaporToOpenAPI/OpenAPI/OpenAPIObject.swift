import Foundation

/// This is the root object of the OpenAPI document.
public struct OpenAPIObject: Codable, Equatable, SpecificationExtendable {
    
    /// Version number of the OpenAPI Specification that the OpenAPI document uses. The `openapi` field SHOULD be used by tooling to interpret the OpenAPI document. This is not related to the API info.version string.
    public var openapi: Version
    
    /// Provides metadata about the API. The metadata MAY be used by tooling as required.
    public var info: InfoObject
    
    /// The default value for the $schema keyword within ```SchemaObjects``` contained within this OAS document.
    public var jsonSchemaDialect: URL?
    
    /// An array of ```ServerObject```, which provide connectivity information to a target server. If the servers property is not provided, or is an empty array, the default value would be a ```ServerObject``` with a url value of /.
    public var servers: [ServerObject]?
    
    /// The available paths and operations for the API.
    public var paths: PathsObject?
    
    /// The incoming webhooks that MAY be received as part of this API and that the API consumer MAY choose to implement. Closely related to the callbacks feature, this section describes requests initiated other than by an API call, for example by an out of band registration. The key name is a unique string to refer to each webhook, while the (optionally referenced) Path Item Object describes a request that may be initiated by the API provider and the expected responses. An [example](https://swagger.io/specification/examples/v3.1/webhook-example.yaml) is available.
    public var webhooks: [String: ReferenceOrObject]?
    
    /// An element to hold various schemas for the document.
    public var components: ComponentsObject?
    
    /// A declaration of which security mechanisms can be used across the API. The list of values includes alternative security requirement objects that can be used. Only one of the security requirement objects need to be satisfied to authorize a request. Individual operations can override this definition. To make security optional, an empty security requirement ({}) can be included in the array.
    public var security: [SecurityRequirementObject]?
    
    /// A list of tags used by the document with additional metadata. The order of the tags can be used to reflect on their order by the parsing tools. Not all tags that are used by the ```OperationObject``` must be declared. The tags that are not declared MAY be organized randomly or based on the tools' logic. Each tag name in the list MUST be unique.
    public var tags: [TagObject]?
    
    /// Additional external documentation.
    public var externalDocs: ExternalDocumentationObject?
}
