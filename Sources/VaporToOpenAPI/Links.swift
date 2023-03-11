import Foundation
import SwiftOpenAPI

public protocol LinkableParameterKey {
}

public struct Link: Hashable {
    
    public var name: String
    public var location: Location?
    
    public init(_ name: String, in location: Location? = nil) {
        self.name = name
        self.location = location
    }
    
    public init<Root: WithExample, Value: DetectableType>(_ name: WritableKeyPath<Root, Value>, in location: Location? = nil) {
        self.init(Link.name(name), in: location)
    }
    
    public enum Location: Hashable {
        
        case request(RequestLocation), response(ResponseLocation)
        
        public static var response: Location { .response(.body) }
        public static var request: Location { .request(.body) }
        
        var isResponse: Bool {
            if case .response = self { return true }
            return false
        }
    }
    
    public enum RequestLocation: String {
        
        case query, header, path, cookie, body
    }
    
    public enum ResponseLocation: String {
        
        case header, cookie, body
    }
    
    private static func name<Root: WithExample, Value: DetectableType>(_ name: WritableKeyPath<Root, Value>) -> String {
        if let result = cache[name] { return result }
        var example = Root.example
        let value1 = (try? AnyValue.encode(example)) ?? [:]
        example[keyPath: name] = Value.another(for: example[keyPath: name])
        let value2 = (try? AnyValue.encode(example)) ?? [:]
        let key = value1.firstDifferentKey(with: value2)
        cache[name] = key
        return key
    }
    
    private static var cache: [AnyKeyPath: String] = [:]
}
