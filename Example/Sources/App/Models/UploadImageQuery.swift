import Foundation
import VaporToOpenAPI
import SwiftOpenAPI

public struct UploadImageQuery: Codable, Equatable, WithExample, OpenAPIDescriptable {

	public var additionalMetadata: String?

	public static let example = UploadImageQuery(additionalMetadata: "png")

	public static var openAPIDescription: OpenAPIDescriptionType? {
		OpenAPIDescription<CodingKeys>()
			.add(for: .additionalMetadata, "Additional data to pass to server")
	}
}
