import Foundation
import SwiftOpenAPI
import VaporToOpenAPI

public struct UpdatePetQuery: Codable, Equatable, WithExample, OpenAPIDescriptable {

	public var name: String?
	public var status: PetStatus?

	public static var example = UpdatePetQuery(name: "Persey", status: .available)

	public static var openAPIDescription: OpenAPIDescriptionType? {
		OpenAPIDescription<CodingKeys>()
			.add(for: .name, "Updated name of the pet")
			.add(for: .status, "Updated status of the pet")
	}
}
