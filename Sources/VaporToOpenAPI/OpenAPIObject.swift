import Swiftgger
import Foundation
import VDCodable

public protocol WithExample: Codable {
    
	static var example: Self { get }
}

extension APIPrimitiveType where Self: WithExample {
    
	public static var anyExample: Codable { example }
}

public protocol OpenAPIObjectConvertable: WithExample {
    
    associatedtype OpenAPIType: OpenAPIObject
}

extension OpenAPIObjectConvertable {
    
    static var openAPIType: OpenAPIType.Type {
        OpenAPIType.self
    }
}

public protocol OpenAPIObject: OpenAPIObjectConvertable {
    
    override associatedtype OpenAPIType: OpenAPIObject = Self
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

extension String: WithExample {
    
	public static var example: String { "some string" }
}

extension Data: WithExample {
    
	public static var example: Data { Data() }
}

extension JSON: WithExample {
    
	public static var example: JSON { ["key": "value"] }
}

extension Array: OpenAPIObjectConvertable where Element: OpenAPIObjectConvertable {
    
    public typealias OpenAPIType = Element.OpenAPIType
}

extension Set: OpenAPIObjectConvertable where Element: OpenAPIObjectConvertable {
    
    public typealias OpenAPIType = Element.OpenAPIType
}

extension ContiguousArray: OpenAPIObjectConvertable where Element: OpenAPIObjectConvertable {
    
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
