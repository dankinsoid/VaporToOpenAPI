import Foundation
import Vapor
import VaporToOpenAPI
import SwiftOpenAPI

public struct User: Codable, Content, Identifiable, WithExample, OpenAPIDescriptable {

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

	public static var openAPIDescription: OpenAPIDescriptionType? {
		OpenAPIDescription<CodingKeys>("User")
			.add(for: .id, "Unique identifier for the user")
			.add(for: .username, "The name that needs to be fetched. Use user1 for testing.")
			.add(for: .firstName, "User's first name")
			.add(for: .lastName, "User's last name")
			.add(for: .email, "User's email")
			.add(for: .password, "User's password")
			.add(for: .phone, "User's phone number")
			.add(for: .userStatus, "User Status")
	}
}
