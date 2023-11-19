import Foundation
import SwiftOpenAPI
import VaporToOpenAPI

@OpenAPIAutoDescriptable
/// Customer
public struct Customer: Codable, Identifiable, WithExample, OpenAPIDescriptable {

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
