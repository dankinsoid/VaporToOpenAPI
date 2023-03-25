import Foundation
import Vapor

public struct ApiResponse: Codable, Content {
	
	public var code: Int32?
	public var type: String?
	public var message: String?

	public static var example = ApiResponse(
		code: 404,
		type: "error",
		message: "Not found"
	)
}
