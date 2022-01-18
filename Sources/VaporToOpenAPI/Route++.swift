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
		response: WithAnyExample.Type? = nil,
		content: WithAnyExample.Type? = nil,
		query: WithAnyExample.Type = EmptyAPIObject.self,
		headers: (WithAnyExample & AnyHeadersType).Type = EmptyAPIObject.self,
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
	
	public var contentType: WithAnyExample.Type? {
		values.contentType == EmptyAPIObject.self ? nil : values.contentType
	}
	
	public var responseCustomType: WithAnyExample.Type? {
		values.responseCustomType
	}
	
	public var queryType: WithAnyExample.Type {
		values.queryType ?? EmptyAPIObject.self
	}
	
	public var headersType: (WithAnyExample & AnyHeadersType).Type {
		values.headersType ?? EmptyAPIObject.self
	}
}

private struct HTML: OpenAPIContent, CustomStringConvertible, APIPrimitiveType, WithExample {
	static var apiDataType: APIDataType { .string }
	static var defaultContentType: HTTPMediaType { .html }
	let description = "<html>HTML text</html>"
	
	static var example: HTML { HTML() }
	
	init() {}
	
	init(from decoder: Decoder) throws {
		_ = try String(from: decoder)
	}
	
	func encode(to encoder: Encoder) throws {
		try description.encode(to: encoder)
	}
}

private struct Unknown: OpenAPIContent, WithAnyExample, APIPrimitiveType {
	static var apiDataType: APIDataType { .string }
	static var anyExample: Codable { Unknown() }
	public static var defaultContentType: HTTPMediaType { .any }
}
