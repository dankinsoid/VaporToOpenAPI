import Foundation
import VaporToOpenAPI
import SwiftOpenAPI

public struct Customer: Codable, Identifiable, WithExample, OpenAPIDescriptable {
	
	public var id: Int
	public var username: String
	public var address: [Address]
	
	public static let example = Customer(
		id: 100000,
		username: "fehguy",
		address: [.example]
	)

	public static var openAPIDescription: OpenAPIDescriptionType? {
		OpenAPIDescription<CodingKeys>("Customer")
			.add(for: .id, "Customer identifier")
			.add(for: .username, "Customer username")
			.add(for: .address, "Customer address")
	}
}
