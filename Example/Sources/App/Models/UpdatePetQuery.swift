import Foundation

public struct UpdatePetQuery: Codable, Equatable {

	public var name: String?
	public var status: PetStatus?

	public static var example = UpdatePetQuery(name: "Persey", status: .available)
}
