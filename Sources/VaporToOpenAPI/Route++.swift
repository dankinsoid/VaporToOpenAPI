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
		content: OpenAPIObject.Type? = nil,
		query: OpenAPIObject.Type = EmptyAPIObject.self,
		headers: (OpenAPIObject & AnyHeadersType).Type = EmptyAPIObject.self,
		responses: [APIResponse] = []
	) -> Route {
		set(\.contentType, to: content)
			.set(\.queryType, to: query)
			.set(\.headersType, to: headers)
			.set(\.summary, to: summary)
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
	
	public var contentType: OpenAPIObject.Type? {
		values.contentType == EmptyAPIObject.self ? nil : values.contentType
	}
	
	public var queryType: OpenAPIObject.Type {
		values.queryType ?? EmptyAPIObject.self
	}
	
	public var headersType: (OpenAPIObject & AnyHeadersType).Type {
		values.headersType ?? EmptyAPIObject.self
	}
}
