import SwiftOpenAPI
import Vapor

public protocol CustomContentType {

	static var contentType: MediaType { get }
}

extension View: OpenAPIType, CustomContentType {

	public static var contentType: MediaType {
		.text("html")
	}

	public static var openAPISchema: SchemaObject {
		.string
	}
}

extension String: CustomContentType {

	public static var contentType: MediaType {
		.text(.plain)
	}
}

extension Data: CustomContentType {

	public static var contentType: MediaType {
		.text("binary")
	}
}
