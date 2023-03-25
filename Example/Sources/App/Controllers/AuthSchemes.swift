import Foundation
import VaporToOpenAPI

public extension AuthSchemeObject {

	static var petstoreAuth: AuthSchemeObject {
		.oauth2(
			.implicit(authorizationUrl: "https://petstore3.swagger.io/oauth/authorize"),
			id: "petstore_auth"
		)
	}
	
	static var petstoreApiKey: AuthSchemeObject {
		.apiKey(
			id: "api_key",
			name: "api_key"
		)
	}
}
