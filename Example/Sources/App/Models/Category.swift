import Foundation
import SwiftOpenAPI
import VaporToOpenAPI

@OpenAPIAutoDescriptable
/// Category
public struct Category: Codable, Identifiable, WithExample, OpenAPIDescriptable {

    /// Unique identifier for the category
	public var id: Int
    /// Category name
	public var name: String?

	public static let example = Category(id: 1, name: "Dogs")
}
