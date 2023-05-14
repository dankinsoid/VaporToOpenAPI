import Foundation
import VaporToOpenAPI

public struct Tag: Codable, Identifiable, WithExample {
	
	public var id: Int
	public var name: String?
	
	public static let example = Tag(id: 1, name: "Dog")
}
