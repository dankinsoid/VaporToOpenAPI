import Foundation
import SwiftOpenAPI
import VaporToOpenAPI

@OpenAPIDescriptable
/// Login query
public struct LoginQuery: Codable, WithExample {

	/// Username
	public var username: String?
	/// Password
	public var password: String?

	public static let example = LoginQuery(username: "Dan", password: "12345")
}
