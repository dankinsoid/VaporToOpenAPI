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
	public func openAPI() -> Route {
		self
	}
}

extension Route {
	
	public var summary: String {
		values.summary ?? ""
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
	
	public var headersType: OpenAPIObject.Type {
		values.headersType ?? EmptyAPIObject.self
	}
}
