import Foundation

/// An object representing a Server Variable for server URL template substitution.
public struct ServerVariableObject: Codable, Equatable, SpecificationExtendable {
    
    /// An enumeration of string values to be used if the substitution options are from a limited set. The array MUST NOT be empty.
    public var `enum`: [String]
    
    /// The default value to use for substitution, which SHALL be sent if an alternate value is not supplied. Note this behavior is different than the Schema Object's treatment of default values, because in those cases parameter values are optional. If the enum is defined, the value MUST exist in the enum's values.
    public var `default`: String
    
    ///     An optional description for the server variable. CommonMark syntax MAY be used for rich text representation.
    public var description: String?
    
    public init(enum: [String], default: String, description: String? = nil) {
        self.enum = `enum`
        self.default = `default`
        self.description = description
    }
}
