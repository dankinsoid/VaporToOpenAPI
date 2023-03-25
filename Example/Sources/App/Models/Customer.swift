import Foundation

public struct Customer: Codable, Identifiable {
	
	public var id: Int
	public var username: String
	public var address: [Address]
	
	public static let example = Customer(
		id: 100000,
		username: "fehguy",
		address: [.example]
	)
}
