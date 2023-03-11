import Foundation
import SwiftOpenAPI
import Vapor

extension PathElement {
    
    public init(_ pathComponent: PathComponent) {
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
        case .parameter(let name):
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
        case .constant(let string), .parameter(let string):
            return string
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

extension Path {
    
    public init(_ path: [PathComponent]) {
        self.init(path.map { PathElement($0) })
    }
}
