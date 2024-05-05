import Foundation
import SwiftOpenAPI
import Vapor
import VaporToOpenAPI

/// Api response body
@OpenAPIDescriptable
public struct ApiResponse: Codable, Content, WithExample {

	/// Response code
	public var code: Int32?
	/// Response type
	public var type: String?
	/// Response message
	public var message: String?

	public static var example = ApiResponse(
		code: 404,
		type: "error",
		message: "Not found"
	)
}
