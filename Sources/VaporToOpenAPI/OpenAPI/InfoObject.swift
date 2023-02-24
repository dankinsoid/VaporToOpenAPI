import Foundation

/// The object provides metadata about the API. The metadata MAY be used by the clients if needed, and MAY be presented in editing or documentation generation tools for convenience.
public struct InfoObject: Codable, Equatable, SpecificationExtendable {
    
    /// The title of the API.
    public var title: String
    
    /// A short summary of the API.
    public var summary: String?
    
    ///  A description of the API. CommonMark syntax MAY be used for rich text representation.
    public var description: String?
    
    /// A URL to the Terms of Service for the API.
    public var termsOfService: URL?
    
    /// The contact information for the exposed API.
    public var contact: ContactObject?
    
    /// The license information for the exposed API.
    public var license: LicenseObject?
    
    /// The version of the OpenAPI document (which is distinct from the OpenAPI Specification version or the API implementation version).
    public var version: Version
}
