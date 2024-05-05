import Foundation
import SwiftOpenAPI
import VaporToOpenAPI

@OpenAPIDescriptable
/// Customer
public struct Customer: Codable, Identifiable, WithExample {

	/// Customer identifier
	public var id: Int
	/// Customer username
	public var username: String
	/// Customer addresses list
	public var address: [Address]

	public static let example = Customer(
		id: 100_000,
		username: "fehguy",
		address: [.example]
	)
}
