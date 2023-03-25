import SwiftOpenAPI
import Vapor

public extension HTTPMethod {

	var openAPI: PathItemObject.Method {
		PathItemObject.Method(rawValue)
	}
}
