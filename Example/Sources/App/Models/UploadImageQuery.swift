import Foundation

public struct UploadImageQuery: Codable, Equatable {

	public var additionalMetadata: String?

	public static let example = UploadImageQuery(additionalMetadata: "png")
}
