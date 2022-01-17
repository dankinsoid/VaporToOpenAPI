//
//  File.swift
//  
//
//  Created by Данил Войдилов on 09.01.2022.
//

import Swiftgger
import Foundation
import VDCodable

public protocol WithAnyExample: Codable {
	static var anyExample: Codable { get }
}

public protocol WithExample: WithAnyExample {
	static var example: Self { get }
}

extension WithAnyExample where Self: WithExample {
	public static var anyExample: Codable { example }
}

extension APIPrimitiveType where Self: WithExample {
	public static var anyExample: Codable { example }
}

public protocol AnyOpenAPIObject: WithAnyExample {}
public protocol OpenAPIObject: AnyOpenAPIObject, WithExample {}

extension WithAnyExample {
	public static func properties() -> [(String, (APIDataType, isOptional: Bool))] {
		guard let dict = try? DictionaryEncoder().encode(AnyEncodable(Self.anyExample)) as? [String: Any] else {
			return []
		}
		return dict.compactMap { v in
			APIDataType(fromSwiftValue: v.value).map { (v.key, ($0, isOptional(v.value))) }
		}
	}
}

func isOptional(_ any: Any) -> Bool {
	(any as? OptionalProtocol) != nil
}

private protocol OptionalProtocol {}

extension Optional: OptionalProtocol {}

extension Array: WithAnyExample where Element: Codable {
	public static var anyExample: Codable { Array() }
}
extension Set: WithAnyExample where Element: Codable {
	public static var anyExample: Codable { Set() }
}
extension ContiguousArray: WithAnyExample where Element: Codable {
	public static var anyExample: Codable { ContiguousArray() }
}
extension String: WithAnyExample {
	public static var anyExample: Codable { "some string" }
}
extension Data: WithAnyExample {
	public static var anyExample: Codable { Data() }
}
extension JSON: WithAnyExample {
	public static var anyExample: Codable { ["key": "value"] as JSON }
}

extension Array: AnyOpenAPIObject where Element: AnyOpenAPIObject {}
extension Set: AnyOpenAPIObject where Element: AnyOpenAPIObject {}
extension ContiguousArray: AnyOpenAPIObject where Element: AnyOpenAPIObject {}

private struct AnyEncodable: Encodable {
	var any: Encodable
	
	init(_ any: Encodable) {
		self.any = any
	}
	
	func encode(to encoder: Encoder) throws {
		try any.encode(to: encoder)
	}
}
