//
//  File.swift
//  
//
//  Created by Данил Войдилов on 09.01.2022.
//

import Swiftgger
import Foundation
import VDCodable

extension OpenAPIObject {
	public static func properties(flat: Bool = false) -> [(String, (APIDataType, isOptional: Bool))] {
		guard let dict = try? DictionaryEncoder().encode(Self.init()) as? [String: Any] else {
			return []
		}
		return dict.compactMap { v in
			APIDataType(fromSwiftValue: v.value).map { (v.key, ($0, isOptional(v.value))) }
		}
	}
}

private func isOptional(_ any: Any) -> Bool {
	(any as? OptionalProtocol) != nil
}

private protocol OptionalProtocol {}

extension Optional: OptionalProtocol {}

extension Array: OpenAPIObject where Element: OpenAPIObject {}
extension Set: OpenAPIObject where Element: OpenAPIObject {}
extension ContiguousArray: OpenAPIObject where Element: OpenAPIObject {}
