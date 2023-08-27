import Foundation
import SwiftOpenAPI
import Vapor

extension PathComponent {

    var parameter: OpenAPI.Parameter? {
		switch self {
		case let .parameter(name):
            return OpenAPI.Parameter(
                name: name,
                context: .path,
                schema: .string
            )
		default:
			return nil
		}
	}

	var name: String {
		switch self {
		case let .constant(string):
			return string
		case let .parameter(string):
			return "by\(string.upFirst)"
		case .anything:
			return "_"
		case .catchall:
			return "__"
		}
	}
}

public extension OpenAPI.Path {

	init(_ path: [PathComponent]) {
        self.init(
            path.map {
                switch $0 {
                case let .parameter(name):
                    return "{\(name)}"
                case let .constant(string):
                    return string
                case .anything:
                    return "*"
                case .catchall:
                    return "**"
                }
            }
        )
	}
}
