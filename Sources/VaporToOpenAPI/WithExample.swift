import Foundation

public protocol WithExample: Codable {

	static var example: Self { get }
}

extension Array: WithExample where Element: WithExample {

	public static var example: Array { [.example] }
}

extension Set: WithExample where Element: WithExample {

	public static var example: Set { [.example] }
}

extension ContiguousArray: WithExample where Element: WithExample {

	public static var example: ContiguousArray { [.example] }
}

extension String: WithExample {

	public static var example: String { "some string" }
}

extension Data: WithExample {

	public static var example: Data { Data() }
}

extension Int: WithExample {

	public static var example: Self { 1 }
}

extension Int8: WithExample {

	public static var example: Self { 1 }
}

extension Int16: WithExample {

	public static var example: Self { 1 }
}

extension Int32: WithExample {

	public static var example: Self { 1 }
}

extension Int64: WithExample {

	public static var example: Self { 1 }
}

extension UInt: WithExample {

	public static var example: Self { 1 }
}

extension UInt8: WithExample {

	public static var example: Self { 1 }
}

extension UInt16: WithExample {

	public static var example: Self { 1 }
}

extension UInt32: WithExample {

	public static var example: Self { 1 }
}

extension UInt64: WithExample {

	public static var example: Self { 1 }
}

extension Bool: WithExample {

	public static var example: Self { true }
}

extension Float: WithExample {

	public static var example: Self { 1 }
}

extension Double: WithExample {

	public static var example: Self { 1 }
}

extension Decimal: WithExample {

	public static var example: Self { 1 }
}

extension UUID: WithExample {

	public static let example = UUID()
}
