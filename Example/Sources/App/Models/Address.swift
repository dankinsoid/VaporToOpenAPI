import Foundation
import VaporToOpenAPI
import SwiftOpenAPI

public struct Address: Codable, WithExample, OpenAPIDescriptable {
	
	public var street: String?
	public var city: String?
	public var state: String?
	public var zip: String?
	
	public static let example = Address(
		street: "437 Lytton",
		city: "Palo Alto",
		state: "CA",
		zip: "94301"
	)

	public static var openAPIDescription: OpenAPIDescriptionType? {
		OpenAPIDescription<CodingKeys>("Address")
			.add(for: .street, "Street address")
			.add(for: .city, "City name")
			.add(for: .state, "State name")
			.add(for: .zip, "Zip code")
	}
}
