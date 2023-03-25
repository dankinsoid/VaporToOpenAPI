import Foundation

public struct LoginQuery: Codable {

	public var username: String?
	public var password: String?

	public static let example = LoginQuery(username: "Dan", password: "12345")
}
