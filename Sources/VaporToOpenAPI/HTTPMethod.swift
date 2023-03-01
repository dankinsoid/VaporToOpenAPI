import Vapor
import SwiftOpenAPI

extension HTTPMethod {
    
    public var openAPI: PathItemObject.Method {
        PathItemObject.Method(rawValue)
    }
}
