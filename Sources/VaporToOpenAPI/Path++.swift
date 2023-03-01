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

extension Path {
    
    public init(_ path: [PathComponent]) {
        self.init(path.map { PathElement($0) })
    }
}
