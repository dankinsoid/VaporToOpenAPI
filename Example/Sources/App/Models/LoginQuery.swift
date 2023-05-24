import Foundation
import SwiftOpenAPI
import VaporToOpenAPI

public struct LoginQuery: Codable, WithExample, OpenAPIDescriptable {

	public var username: String?
	public var password: String?

	public static let example = LoginQuery(username: "Dan", password: "12345")

	public static var openAPIDescription: OpenAPIDescriptionType? {
		OpenAPIDescription<CodingKeys>()
			.add(for: .username, "Username")
			.add(for: .password, "Password")
	}
}
