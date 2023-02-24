import Foundation

/// Contact information for the exposed API.
public struct ContactObject: Codable, Equatable, SpecificationExtendable {
    
    /// The identifying name of the contact person/organization.
    public var name: String?
    
    /// The URL pointing to the contact information.
    public var url:  URL?
    
    /// The email address of the contact person/organization. This MUST be in the form of an email address.
    public var email: String?
    
    public init(
        name: String? = nil,
        url: URL? = nil,
        email: String? = nil
    ) {
        self.name = name
        self.url = url
        self.email = email
    }
}
