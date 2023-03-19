import Foundation
import SwiftOpenAPI

public protocol LinkKey {
    
    static var description: String? { get }
    static var server: ServerObject? { get }
}

extension LinkKey {
    
    public static var description: String? { nil }
    public static var server: ServerObject? { nil }
    
    static var object: LinkKeyObject {
        LinkKeyObject(type: Self.self)
    }
}

struct LinkKeyObject: Hashable {
    
    var type: LinkKey.Type
    
    func hash(into hasher: inout Hasher) {
        ObjectIdentifier(type).hash(into: &hasher)
    }
    
    static func ==(_ lhs: LinkKeyObject, _ rhs: LinkKeyObject) -> Bool {
        lhs.type == rhs.type
    }
}

public struct Link: Hashable {
    
    public var name: String
    public var location: Location
    
    public var identifier: String {
        "\(location.description.components(separatedBy: ["."]).map(\.upFirst).joined())\(name.upFirst)"
    }
    
    public var expression: RuntimeExpression {
        "$\(location)#/\(name)"
    }
    
    public init(_ name: String, in location: Location) {
        self.name = name
        self.location = location
    }
    
    public init<Root: WithExample, Value: DetectableType>(_ name: WritableKeyPath<Root, Value>, in location: Location) {
        self.init(Link.name(name), in: location)
    }
    
    public enum Location: Hashable, CustomStringConvertible {
        
        case request(RequestLocation), response(ResponseLocation)
        
        public static var response: Location { .response(.body) }
        public static var request: Location { .request(.body) }
        
        public var description: String {
            switch self {
            case let .request(location): return "request.\(location.rawValue)"
            case let .response(location): return "response.\(location.rawValue)"
            }
        }
        
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
