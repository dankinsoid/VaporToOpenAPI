import Foundation

/// An object representing a Server.
public struct ServerObject: Codable, Equatable, SpecificationExtendable {
    
    /// A URL to the target host. This URL supports Server Variables and MAY be relative, to indicate that the host location is relative to the location where the OpenAPI document is being served. Variable substitutions will be made when a variable is named in {brackets}.
    public var url: String
    
    /// An optional string describing the host designated by the URL. CommonMark syntax MAY be used for rich text representation.
    public var description: String?
    
    /// A map between a variable name and its value. The value is used for substitution in the server's URL template.
    public variables: [String: ServerVariableObject]?
    
    public init(url: String, description: String? = nil, variables: [String : ServerVariableObject]? = nil) {
        self.url = url
        self.description = description
        self.variables = variables
    }
}
