import Foundation
import SwiftOpenAPI
import VaporToOpenAPI

@OpenAPIAutoDescriptable
public struct UploadImageQuery: Codable, Equatable, WithExample, OpenAPIDescriptable {

    /// Additional data to pass to server
	public var additionalMetadata: String?

	public static let example = UploadImageQuery(additionalMetadata: "png")
}
