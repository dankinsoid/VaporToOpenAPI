import SwiftOpenAPI
import Vapor

public extension HTTPMethod {

    var openAPI: OpenAPI.HttpMethod {
        OpenAPI.HttpMethod(rawValue: rawValue.uppercased()) ?? .post
	}
}
