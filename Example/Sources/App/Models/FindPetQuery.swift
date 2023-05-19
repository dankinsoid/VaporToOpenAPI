import Foundation
import VaporToOpenAPI

public struct FindPetByStatusQuery: Codable, Equatable, WithExample {

	public var status: PetStatus? = .available

	public static let example = FindPetByStatusQuery()
}
