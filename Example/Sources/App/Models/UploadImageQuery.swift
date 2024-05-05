import Foundation
import SwiftOpenAPI
import VaporToOpenAPI

@OpenAPIDescriptable
public struct UploadImageQuery: Codable, Equatable, WithExample {

	/// Additional data to pass to server
	public var additionalMetadata: String?

	public static let example = UploadImageQuery(additionalMetadata: "png")
}
