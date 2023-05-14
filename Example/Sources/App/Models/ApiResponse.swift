import Foundation
import Vapor
import VaporToOpenAPI
import SwiftOpenAPI

public struct ApiResponse: Codable, Content, WithExample, OpenAPIDescriptable {
	
	public var code: Int32?
	public var type: String?
	public var message: String?

	public static var example = ApiResponse(
		code: 404,
		type: "error",
		message: "Not found"
	)

	public static var openAPIDescription: OpenAPIDescriptionType? {
		OpenAPIDescription<CodingKeys>("ApiResponse")
			.add(for: .code, "Response code")
			.add(for: .type, "Response type")
			.add(for: .message, "Response message")
	}
}
