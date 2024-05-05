import Foundation
import SwiftOpenAPI
import VaporToOpenAPI

@OpenAPIDescriptable
/// Category
public struct Category: Codable, Identifiable, WithExample {

	/// Unique identifier for the category
	public var id: Int
	/// Category name
	public var name: String?

	public static let example = Category(id: 1, name: "Dogs")
}
