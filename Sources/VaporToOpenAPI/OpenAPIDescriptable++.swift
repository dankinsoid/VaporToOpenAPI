import Foundation
import SwiftOpenAPI

@dynamicMemberLookup
public struct KeyPathOpenAPIDescription<Base: WithExample>: OpenAPIDescriptionType {
    
    public var openAPISchemeDescription: String?
    public var schemePropertyDescriptions: [String: String]
    
    public init(_ openAPISchemeDescription: String? = nil) {
        self.openAPISchemeDescription = openAPISchemeDescription
        self.schemePropertyDescriptions = [:]
    }
    
    public subscript<T: DetectableType>(dynamicMember keyPath: WritableKeyPath<Base, T>) -> Property {
        Property(base: self, keyPath: Base.codingKey(for: keyPath))
    }
    
    public struct Property {
        
        let base: KeyPathOpenAPIDescription
        let keyPath: String
        
        public func callAsFunction(_ description: String) -> KeyPathOpenAPIDescription {
            var result = base
            result.schemePropertyDescriptions[keyPath] = description
            return result
        }
    }
}

extension OpenAPIDescriptable where Self: WithExample {
    
    public typealias Description = KeyPathOpenAPIDescription<Self>
}
