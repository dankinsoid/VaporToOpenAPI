import Foundation
import SwiftOpenAPI
import VaporToOpenAPI

@OpenAPIDescriptable
public struct UpdatePetQuery: Codable, Equatable, WithExample {

	/// Updated name of the pet
	public var name: String?
	/// Updated status of the pet
	public var status: PetStatus?

	public static var example = UpdatePetQuery(name: "Persey", status: .available)
}
