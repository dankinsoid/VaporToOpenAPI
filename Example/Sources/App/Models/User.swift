import Foundation
import SwiftOpenAPI
import Vapor
import VaporToOpenAPI

@OpenAPIDescriptable
/// User model
public struct User: Codable, Content, Identifiable, WithExample {

	/// Unique identifier for the user
	public var id: Int
	/// The name that needs to be fetched. Use user1 for testing.
	public var username: String
	/// User's first name
	public var firstName: String?
	/// User's last name
	public var lastName: String?
	/// User's email
	public var email: String?
	/// User's password
	public var password: String?
	/// User's phone number
	public var phone: String?
	/// User Status
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
