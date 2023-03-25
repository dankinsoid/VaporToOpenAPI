import Foundation
import Vapor
import VaporToOpenAPI

public struct Pet: Codable, Content, Identifiable, WithExample {

	public var id: Int
	public var name: String
	public var category: Category?
	public var photoUrls: [URL]
	public var tags: [Tag]?
	public var status: PetStatus?
	
	public static let example = Pet(
		id: 10,
		name: "doggie",
		category: Category.example,
		photoUrls: [URL(string: "http://cdn.shopify.com/s/files/1/0551/9147/0147/articles/pooping-dog.jpg?v=1644826120")!],
		tags: [.example],
		status: .available
	)
}
