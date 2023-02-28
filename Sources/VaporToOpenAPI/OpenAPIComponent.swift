import Swiftgger
import Foundation
import SimpleCoders

public protocol WithExample: Codable {
    
	static var example: Self { get }
}

extension APIPrimitiveType where Self: WithExample {
    
	public static var anyExample: Codable { example }
}

public protocol OpenAPIComponentConvertable: WithExample {
    
    associatedtype OpenAPIType: OpenAPIComponent
}

extension OpenAPIComponentConvertable {
    
    static var openAPIType: OpenAPIType.Type {
        OpenAPIType.self
    }
}

public protocol OpenAPIComponent: OpenAPIComponentConvertable {
    
    override associatedtype OpenAPIType: OpenAPIComponent = Self
}

extension WithExample {
    
	public static func properties() -> [(String, (APIDataType, isOptional: Bool))] {
		guard let dict = try? DictionaryEncoder().encode(AnyEncodable(Self.example)) as? [String: Any] else {
			return []
		}
      return dict.sorted(by: { $0.key < $1.key }).compactMap { v in
			APIDataType(fromSwiftValue: v.value).map { (v.key, ($0, isOptional(v.value))) }
		}
	}
}

extension [any WithExample.Type] {
    
    public func properties() -> [(String, (APIDataType, isOptional: Bool))] {
        flatMap {
            $0.properties()
        }
        .sorted(by: { $0.0 < $1.0 })
    }
}

func isOptional(_ any: Any) -> Bool {
	(any as? OptionalProtocol) != nil
}

private protocol OptionalProtocol {}

extension Optional: OptionalProtocol {}

extension Array: WithExample where Element: Codable {
    
	public static var example: Array { Array() }
}

extension Set: WithExample where Element: Codable {
    
	public static var example: Set { Set() }
}

extension ContiguousArray: WithExample where Element: Codable {
    
	public static var example: ContiguousArray { ContiguousArray() }
}

extension String: OpenAPIObject {
    
	public static var example: String { "some string" }
}

extension Data: OpenAPIObject {
    
	public static var example: Data { Data() }
}

extension JSON: OpenAPIObject {
    
	public static var example: JSON { ["key": "value"] }
}

extension Array: OpenAPIComponentConvertable where Element: OpenAPIComponentConvertable {
    
    public typealias OpenAPIType = Element.OpenAPIType
}

extension Set: OpenAPIComponentConvertable where Element: OpenAPIComponentConvertable {
    
    public typealias OpenAPIType = Element.OpenAPIType
}

extension ContiguousArray: OpenAPIComponentConvertable where Element: OpenAPIComponentConvertable {
    
    public typealias OpenAPIType = Element.OpenAPIType
}

private struct AnyEncodable: Encodable {
    
	var any: Encodable
	
	init(_ any: Encodable) {
		self.any = any
	}
	
	func encode(to encoder: Encoder) throws {
		try any.encode(to: encoder)
	}
}
