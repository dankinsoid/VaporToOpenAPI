//
//  File.swift
//  
//
//  Created by Данил Войдилов on 09.01.2022.
//

import Vapor
import Swiftgger

extension Route {
	@discardableResult
	public func openAPI(
		summary: String = "",
		description: String = "",
		response: EmptyInitable.Type? = nil,
		content: EmptyInitable.Type? = nil,
		query: EmptyInitable.Type = EmptyAPIObject.self,
		headers: (EmptyInitable & AnyHeadersType).Type = EmptyAPIObject.self,
		responses: [APIResponse] = []
	) -> Route {
		set(\.contentType, to: content)
			.set(\.queryType, to: query)
			.set(\.headersType, to: headers)
			.set(\.summary, to: summary)
			.set(\.responseCustomType, to: response)
			.description(description)
	}
}

extension Route {
	
	public var summary: String {
		values.summary ?? ""
	}
	
	@discardableResult
	public func summary(_ value: String) -> Route {
		set(\.summary, to: value)
	}
	
	public var responses: [APIResponse] {
		values.responses ?? []
	}
	
	public var openAPIRequestType: Decodable.Type? {
		contentType ?? (requestType == Request.self ? nil : requestType as? Decodable.Type)
	}
	
	public var openAPIResponseType: Any.Type {
		let type = responseCustomType ?? (responseType as? EventLoopType.Type)?.valueType ?? responseType
		if type == View.self {
			return HTML.self
		} else if type == Response.self {
			return Unknown.self
		} else {
			return type
		}
	}
	
	public var contentType: EmptyInitable.Type? {
		values.contentType == EmptyAPIObject.self ? nil : values.contentType
	}
	
	public var responseCustomType: EmptyInitable.Type? {
		values.responseCustomType
	}
	
	public var queryType: EmptyInitable.Type {
		values.queryType ?? EmptyAPIObject.self
	}
	
	public var headersType: (EmptyInitable & AnyHeadersType).Type {
		values.headersType ?? EmptyAPIObject.self
	}
}

private struct HTML: OpenAPIContent, CustomStringConvertible, OpenAPIObject {
	static var defaultContentType: HTTPMediaType { .html }
	let description = "<html>HTML text</html>"
	
	init() {}
	
	init(from decoder: Decoder) throws {
		_ = try String(from: decoder)
	}
	
	func encode(to encoder: Encoder) throws {
		try description.encode(to: encoder)
	}
}

private struct Unknown: OpenAPIContent, EmptyInitable {
	public static var defaultContentType: HTTPMediaType { .any }
}
