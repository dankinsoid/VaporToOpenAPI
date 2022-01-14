//
//  File.swift
//  
//
//  Created by Данил Войдилов on 10.01.2022.
//

import Vapor

public struct RequestTypes<Content, Headers: HeadersType, Query> {
	public init() {}
	
	public static func content(_ type: Content.Type, query: Query.Type, headers: Headers.Type) -> RequestTypes {
		RequestTypes()
	}
	
	public func content<B>(_ type: B.Type) -> RequestTypes<B, Headers, Query> {
		RequestTypes<B, Headers, Query>()
	}
	
	public func query<Q>(_ type: Q.Type) -> RequestTypes<Content, Headers, Q> {
		RequestTypes<Content, Headers, Q>()
	}
	
	public func headers<H>(_ type: H.Type) -> RequestTypes<Content, H, Query> {
		RequestTypes<Content, H, Query>()
	}
}

extension RequestTypes where Content == EmptyAPIObject, Headers == EmptyAPIObject, Query == EmptyAPIObject {
	public static var empty: RequestTypes { RequestTypes() }
}

extension RequestTypes where Headers == EmptyAPIObject, Query == EmptyAPIObject {
	
	public static func content(_ type: Content.Type) -> RequestTypes {
		RequestTypes()
	}
}

extension RequestTypes where Content == EmptyAPIObject, Query == EmptyAPIObject {
	public static func headers(_ type: Headers.Type) -> RequestTypes {
		RequestTypes()
	}
}

extension RequestTypes where Content == EmptyAPIObject, Headers == EmptyAPIObject {
	public static func query(_ type: Query.Type) -> RequestTypes {
		RequestTypes()
	}
}

extension RequestTypes where Headers == EmptyAPIObject {
	
	public static func content(_ type: Content.Type, query: Query.Type) -> RequestTypes {
		RequestTypes()
	}
}

extension RequestTypes where Content == EmptyAPIObject {
	public static func query(_ type: Query.Type, headers: Headers.Type) -> RequestTypes {
		RequestTypes()
	}
}

extension RequestTypes where Query == EmptyAPIObject {
	public static func content(_ type: Content.Type, headers: Headers.Type) -> RequestTypes {
		RequestTypes()
	}
}
