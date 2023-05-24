import Foundation

public protocol DetectableType: Equatable {

	static func another(for value: Self) -> Self
}

extension Bool: DetectableType {

	public static func another(for value: Self) -> Self { !value }
}

extension String: DetectableType {

	public static func another(for value: Self) -> Self { value.isEmpty ? " " : "" }
}

extension Double: DetectableType {

	public static func another(for value: Self) -> Self { -value }
}

extension Float: DetectableType {

	public static func another(for value: Self) -> Self { -value }
}

extension Decimal: DetectableType {

	public static func another(for value: Self) -> Self { -value }
}

extension Int: DetectableType {

	public static func another(for value: Self) -> Self { -value }
}

extension Int8: DetectableType {

	public static func another(for value: Self) -> Self { -value }
}

extension Int16: DetectableType {

	public static func another(for value: Self) -> Self { -value }
}

extension Int32: DetectableType {

	public static func another(for value: Self) -> Self { -value }
}

extension Int64: DetectableType {

	public static func another(for value: Self) -> Self { -value }
}

extension UInt: DetectableType {

	public static func another(for value: Self) -> Self { value &+ 1 }
}

extension UInt8: DetectableType {

	public static func another(for value: Self) -> Self { value &+ 1 }
}

extension UInt16: DetectableType {

	public static func another(for value: Self) -> Self { value &+ 1 }
}

extension UInt32: DetectableType {

	public static func another(for value: Self) -> Self { value &+ 1 }
}

extension UInt64: DetectableType {

	public static func another(for value: Self) -> Self { value &+ 1 }
}

extension UUID: DetectableType {

	public static func another(for value: Self) -> Self { UUID() }
}

extension Array: DetectableType where Element: WithExample & Equatable {

	public static func another(for value: [Element]) -> [Element] {
		value.isEmpty ? [.example] : []
	}
}

extension Set: DetectableType where Element: WithExample {

	public static func another(for value: Set<Element>) -> Set<Element> {
		value.isEmpty ? [.example] : []
	}
}

extension Dictionary: DetectableType where Key: WithExample & Equatable, Value: WithExample & Equatable {

	public static func another(for value: [Key: Value]) -> [Key: Value] {
		value.isEmpty ? [.example: .example] : [:]
	}
}

extension Optional: DetectableType where Wrapped: WithExample & Equatable {

	public static func another(for value: Self) -> Self {
		value == nil ? .example : nil
	}
}
