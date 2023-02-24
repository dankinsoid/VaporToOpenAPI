import Foundation

/// Allows referencing an external resource for extended documentation.
public struct ExternalDocumentationObject: Codable, Equatable, SpecificationExtendable {
    
    /// A description of the target documentation. CommonMark syntax MAY be used for rich text representation.
    public var description: String?
    
    ///  The URL for the target documentation.
    public var url: URL
    
    public init(description: String? = nil, url: URL) {
        self.description = description
        self.url = url
    }
}
