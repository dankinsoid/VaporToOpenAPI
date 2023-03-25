import Foundation

public struct Tag: Codable, Identifiable {
	
	public var id: Int
	public var name: String?
	
	public static let example = Tag(id: 1, name: "Cats")
}
