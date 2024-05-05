import Foundation
import SwiftOpenAPI

public protocol LinkKey {

	static var description: String? { get }
	static var server: ServerObject? { get }
}

public extension LinkKey {

	static var description: String? { nil }
	static var server: ServerObject? { nil }

	internal static var object: LinkKeyObject {
		LinkKeyObject(type: Self.self)
	}
}

struct LinkKeyObject: Hashable {

	var type: LinkKey.Type

	func hash(into hasher: inout Hasher) {
		ObjectIdentifier(type).hash(into: &hasher)
	}

	static func == (_ lhs: LinkKeyObject, _ rhs: LinkKeyObject) -> Bool {
		lhs.type == rhs.type
	}
}

public struct Link: Hashable {

	public var name: String
	public var location: Location

	public var identifier: String {
		"\(location.description).\(name)".components(separatedBy: ["."]).map(\.upFirst).joined()
	}

	public var expression: RuntimeExpression {
		"$\(location)#/\(name)"
	}

	public init(_ name: String, in location: Location) {
		self.name = name
		self.location = location
	}

	@available(*, deprecated, message: "Use init with string instead")
	public init<T: WithExample>(_ name: WritableKeyPath<T, some DetectableType>, in location: Location) {
		self.init(T.codingKey(for: name), in: location)
	}

	public enum Location: Hashable, CustomStringConvertible {

		case request(RequestLocation), response(ResponseLocation)

		public static var response: Location { .response(.body) }
		public static var request: Location { .request(.body) }
		public static var path: Location { .request(.path) }
		public static var query: Location { .request(.query) }

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
}
