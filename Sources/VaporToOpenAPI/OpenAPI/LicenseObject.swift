import Foundation

/// License information for the exposed API.
public struct LicenseObject: Codable, Equatable, SpecificationExtendable {
    
    /// The license name used for the API.
    public var name: String
    
    /// An SPDX license expression for the API. The identifier field is mutually exclusive of the url field.
    public var identifier: String?
    
    /// A URL to the license used for the API. This MUST be in the form of a URL. The url field is mutually exclusive of the identifier field.
    public var url: URL?

    public init(name: String, identifier: String? = nil, url: URL? = nil) {
        self.name = name
        self.identifier = identifier
        self.url = url
    }
}
