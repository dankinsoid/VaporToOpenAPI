import Foundation

public struct FindPetByStatusQuery: Codable, Equatable {

	public var status: PetStatus? = .available

	public static let example = FindPetByStatusQuery()
}

public struct FindPetByTagsQuery: Codable, Equatable {

	public var tags: [String]?

	public static let example = FindPetByTagsQuery(tags: ["Cat"])
}
