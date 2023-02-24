import Foundation

public enum ReferenceOr<Object: Codable & Equatable>: Equatable, Codable {
    
    case object
    case reference(ReferenceObject)
    
    public init(from decoder: Decoder) throws {
        
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
}
