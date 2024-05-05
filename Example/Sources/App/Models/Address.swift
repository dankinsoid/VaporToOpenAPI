import Foundation
import SwiftOpenAPI
import VaporToOpenAPI

/// Address
@OpenAPIDescriptable
public struct Address: Codable, WithExample {

	/// Street address
	public var street: String?
	/// City name
	public var city: String?
	/// State name
	public var state: String?
	/// Zip code
	public var zip: String?

	public static let example = Address(
		street: "437 Lytton",
		city: "Palo Alto",
		state: "CA",
		zip: "94301"
	)
}
