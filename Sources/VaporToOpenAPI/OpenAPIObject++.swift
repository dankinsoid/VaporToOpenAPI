import SwiftOpenAPI
import Vapor

extension OpenAPIObject: Content {}

extension WithSpecExtensions: AsyncResponseEncodable where Wrapped: Content {
}

extension WithSpecExtensions: AsyncRequestDecodable where Wrapped: Content {
}

extension WithSpecExtensions: ResponseEncodable where Wrapped: Content {
}

extension WithSpecExtensions: RequestDecodable where Wrapped: Content {
}

extension WithSpecExtensions: Content where Wrapped: Content {}
