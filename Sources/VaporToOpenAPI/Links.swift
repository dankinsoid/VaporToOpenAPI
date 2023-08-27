import Foundation
import SwiftOpenAPI
import OpenAPIKit

public protocol LinkKey {

	static var description: String? { get }
    static var server: OpenAPI.Server? { get }
}

public extension LinkKey {

	static var description: String? { nil }
	static var server: OpenAPI.Server? { nil }

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

    public var expression: OpenAPI.RuntimeExpression {
        switch location {
        case .request(let requestLocation):
            switch requestLocation {
            case .query:
                return .request(.query(name: name))
            case .header:
                return .request(.header(name: name))
            case .path:
                return .request(.path(name: name))
            case .body:
                return .request(.body(.component(name: name)))
            }
        case .response(let responseLocation):
            switch responseLocation {
            case .header:
                return .request(.header(name: name))
            case .body:
                return .request(.body(.component(name: name)))
            }
        }
	}

	public init(_ name: String, in location: Location) {
		self.name = name
		self.location = location
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

		case query, header, path, body
	}

	public enum ResponseLocation: String {

		case header, body
	}
}
