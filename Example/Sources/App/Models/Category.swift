import Foundation

public struct Category: Codable, Identifiable {
	
	public var id: Int
	public var name: String?
	
	public static let example = Category(id: 1, name: "Dogs")
}
