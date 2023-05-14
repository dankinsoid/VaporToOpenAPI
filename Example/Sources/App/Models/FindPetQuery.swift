import Foundation
import VaporToOpenAPI

public struct FindPetByStatusQuery: Codable, Equatable, WithExample {

	public var status: PetStatus? = .available

	public static let example = FindPetByStatusQuery()
}

public struct FindPetByTagsQuery: Codable, Equatable, WithExample {

	public var tags: [String]?

	public static let example = FindPetByTagsQuery(tags: ["Cat"])
}
