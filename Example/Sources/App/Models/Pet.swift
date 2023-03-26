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
		photoUrls: [URL(string: "https://en.wikipedia.org/wiki/File:Snoop_Dogg_2019_by_Glenn_Francis.jpg")!],
		tags: [.example],
		status: .available
	)
}
