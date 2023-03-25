import Foundation

public struct Address: Codable {
	
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
}
