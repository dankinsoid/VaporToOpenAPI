import Foundation

/// Describes the operations available on a single path. A Path Item MAY be empty, due to ACL constraints. The path itself is still exposed to the documentation viewer but they will not know which operations and parameters are available.
public struct PathItemObject: Codable, Equatable, SpecificationExtendable {
    
    /// String summary, intended to apply to all operations in this path.
    public var summary: String?
    
    /// String description, intended to apply to all operations in this path. CommonMark syntax MAY be used for rich text representation.
    public var description: String?
    
    /// A definition of a GET operation on this path.
    public var get: OperationObject?
    
    /// A definition of a PUT operation on this path.
    public var put: OperationObject?
    
    /// A definition of a POST operation on this path.
    public var post: OperationObject?
    
    /// A definition of a DELETE operation on this path.
    public var delete: OperationObject?
    
    /// A definition of a OPTIONS operation on this path.
    public var options: OperationObject?
    
    /// A definition of a HEAD operation on this path.
    public var head: OperationObject?
    
    /// A definition of a PATCH operation on this path.
    public var patch: OperationObject?
    
    /// A definition of a TRACE operation on this path.
    public var trace: OperationObject?
    
    /// An alternative server array to service all operations in this path.
    public var servers: [ServerObject]
    
    /// A list of parameters that are applicable for all the operations described under this path. These parameters can be overridden at the operation level, but cannot be removed there. The list MUST NOT include duplicated parameters. A unique parameter is defined by a combination of a name and location. The list can use the Reference Object to link to parameters that are defined at the OpenAPI Object's components/parameters.
    public var parameters: [ReferenceOr<ParameterObject>]
    
    public init(summary: String? = nil, description: String? = nil, get: OperationObject? = nil, put: OperationObject? = nil, post: OperationObject? = nil, delete: OperationObject? = nil, options: OperationObject? = nil, head: OperationObject? = nil, patch: OperationObject? = nil, trace: OperationObject? = nil, servers: [ServerObject], parameters: [ReferenceOr<ParameterObject>]) {
        self.summary = summary
        self.description = description
        self.get = get
        self.put = put
        self.post = post
        self.delete = delete
        self.options = options
        self.head = head
        self.patch = patch
        self.trace = trace
        self.servers = servers
        self.parameters = parameters
    }
}
