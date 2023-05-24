import Foundation
import SwiftOpenAPI
import VaporToOpenAPI

public struct Category: Codable, Identifiable, WithExample, OpenAPIDescriptable {

	public var id: Int
	public var name: String?

	public static let example = Category(id: 1, name: "Dogs")

	public static var openAPIDescription: OpenAPIDescriptionType? {
		OpenAPIDescription<CodingKeys>("Category")
			.add(for: .id, "Unique identifier for the category")
			.add(for: .name, "Category name")
	}
}
