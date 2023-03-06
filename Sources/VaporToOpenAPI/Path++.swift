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
    
    var pathParameter: ReferenceOr<ParameterObject>? {
        switch self {
        case .parameter(let name):
            return .value(
                ParameterObject(
                    name: name,
                    in: .path,
                    required: true,
                    schema: .string,
                    example: nil
                )
            )
        default:
            return nil
        }
    }
}

extension Path {
    
    public init(_ path: [PathComponent]) {
        self.init(path.map { PathElement($0) })
    }
}

extension Route {
    
    var pathParameters: [ReferenceOr<ParameterObject>] {
        path.compactMap(\.pathParameter)
    }
}
