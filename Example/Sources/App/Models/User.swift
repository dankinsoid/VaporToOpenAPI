import Foundation
import Vapor
import VaporToOpenAPI

public struct User: Codable, Content, Identifiable, WithExample {

	public var id: Int
	public var username: String
	public var firstName: String?
	public var lastName: String?
	public var email: String?
	public var password: String?
	public var phone: String?
	public var userStatus: Int32?

	public static let example = User(
		id: 10,
		username: "theUser",
		firstName: "John",
		lastName: "James",
		email: "john@email.com",
		password: "12345",
		phone: "12345",
		userStatus: 1
	)
}
