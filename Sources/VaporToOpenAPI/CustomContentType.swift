import SwiftOpenAPI
import Vapor

public protocol CustomContentType {

    static var contentType: OpenAPI.ContentType { get }
}

extension View: OpenAPIType, CustomContentType {

	public static var contentType:  OpenAPI.ContentType {
        .html
	}

	public static var openAPISchema: JSONSchema {
		.string
	}
}

extension String: CustomContentType {

	public static var contentType: OpenAPI.ContentType {
        .anyText
	}
}
