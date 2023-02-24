import Vapor

public protocol OpenAPIContent: Codable {
	/// The default `MediaType` to use when _encoding_ content. This can always be overridden at the encode call.
	///
	/// Default implementation is `MediaType.json` for all types.
	///
	///     struct Hello: Content {
	///         static let defaultContentType = .urlEncodedForm
	///         let message = "Hello!"
	///     }
	///
	///     router.get("greeting") { req in
	///         return Hello() // message=Hello!
	///     }
	///
	///     router.get("greeting2") { req in
	///         let res = req.response()
	///         try res.content.encode(Hello(), as: .json)
	///         return res // {"message":"Hello!"}
	///     }
	///
	static var defaultContentType: HTTPMediaType { get }
}

extension String: OpenAPIContent {
	public static var defaultContentType: HTTPMediaType { .plainText }
}

extension Data: OpenAPIContent {
	public static var defaultContentType: HTTPMediaType { .binary }
}
