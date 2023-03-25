import Foundation
import SwiftOpenAPI
import Vapor

public extension PathElement {

	init(_ pathComponent: PathComponent) {
		switch pathComponent {
		case let .constant(string):
			self = .constant(string)
		case let .parameter(string):
			self = .variable(string)
		case .anything:
			self = .constant("*")
		case .catchall:
			self = .constant("**")
		}
	}
}

extension PathComponent {

	var parameterObject: ParameterObject? {
		switch self {
		case let .parameter(name):
			return ParameterObject(
				name: name,
				in: .path,
				required: true,
				schema: .string,
				example: nil
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

	var pathParameter: ReferenceOr<ParameterObject>? {
		parameterObject.map { .value($0) }
	}
}

public extension Path {

	init(_ path: [PathComponent]) {
		self.init(path.map { PathElement($0) })
	}
}
