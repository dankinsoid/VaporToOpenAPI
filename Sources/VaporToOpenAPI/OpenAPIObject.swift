//
//  File.swift
//  
//
//  Created by Данил Войдилов on 09.01.2022.
//

import Swiftgger
import Foundation
import VDCodable

public protocol EmptyInitable: Codable {
	init()
}

public protocol OpenAPIObject: EmptyInitable {}

extension EmptyInitable {
	public static func properties() -> [(String, (APIDataType, isOptional: Bool))] {
		guard let dict = try? DictionaryEncoder().encode(Self.init()) as? [String: Any] else {
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

extension Array: EmptyInitable where Element: Codable {}
extension Set: EmptyInitable where Element: Codable {}
extension ContiguousArray: EmptyInitable where Element: Codable {}
extension String: EmptyInitable {}
extension Data: EmptyInitable {}
extension JSON: OpenAPIObject {
	public init() {
		self = .object([:])
	}
}
